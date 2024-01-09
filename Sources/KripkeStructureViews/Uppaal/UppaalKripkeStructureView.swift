import IO
import KripkeStructure

#if os(macOS)
import Darwin
#else
import Glibc
#endif

import SQLite

public final class UppaalKripkeStructureView: KripkeStructureView {
    
    private struct DB {

        private let db: Connection

        private let properties: PropertiesTable

        private let values: ValuesTable

        var propertyNames: AnySequence<String> {
            AnySequence { () -> AnyIterator<String> in
                let iterator = self.properties.properties.makeIterator()
                return AnyIterator {
                    iterator.next().map(\.1)
                }
            }
        }

        var propertyValues: AnySequence<(String, AnySequence<String>)> {
            AnySequence { () -> AnyIterator<(String, AnySequence<String>)> in
                let iterator = self.properties.properties.makeIterator()
                return AnyIterator {
                    guard let (id, name) = iterator.next() else {
                        return nil
                    }
                    return (name, values.values(forProperty: id))
                }
            }
        }

        init(db: Connection) {
            self.db = db
            self.properties = PropertiesTable(db: db)
            self.values = ValuesTable(db: db)
        }

        func insertIfNotExists(property: String, value: String) throws {
            let id = try properties.insertIfNotExists(property: property)
            try values.insertIfNotExists(value: value, forProperty: id)
        }

        func reset() throws {
            try values.reset()
            try properties.reset()
        }

    }

    private struct PropertiesTable {

        private let db: Connection

        private let table: Table = Table("Properties")

        private let id: Expression<Int64> = Expression<Int64>("id")

        private let name: Expression<String> = Expression<String>("name")

        var properties: AnySequence<(Int64, String)> {
            AnySequence { () -> AnyIterator<(Int64, String)> in
                let results = try! db.prepare(table.select(id, name).order(name.asc))
                let iterator = results.makeIterator()
                return AnyIterator {
                    iterator.next().map { try! ($0.get(id), $0.get(name))  }
                }
            }
        }

        init(db: Connection) {
            self.db = db
        }

        @discardableResult
        func insertIfNotExists(property: String) throws -> Int64 {
            var id: Int64 = -1
            try db.transaction {
                if let row = try db.pluck(table.select(self.id).where(name == property)) {
                    id = try row.get(self.id)
                    return
                }
                id = try db.run(table.insert([
                    name <- property
                ]))
            }
            return id
        }

        func reset() throws {
            try db.run(table.drop(ifExists: true))
            try db.run(table.create { t in
                t.column(id, primaryKey: .autoincrement)
                t.column(name, unique: true)
            })
        }

    }

    private struct ValuesTable {

        private let db: Connection

        private let table: Table = Table("Values")

        private let id: Expression<Int64> = Expression<Int64>("id")

        private let value: Expression<String> = Expression<String>("value")

        private let property: Expression<Int64> = Expression<Int64>("property")

        init(db: Connection) {
            self.db = db
        }

        @discardableResult
        func insertIfNotExists(value valueStr: String, forProperty propertyId: Int64) throws -> Int64 {
            var id: Int64 = -1
            try db.transaction {
                if let row = try db.pluck(table.select(self.id).where(value == valueStr && property == propertyId)) {
                    id = try row.get(self.id)
                    return
                }
                id = try db.run(table.insert([
                    value <- valueStr,
                    property <- propertyId
                ]))
            }
            return id
        }

        func reset() throws {
            try db.run(table.drop(ifExists: true))
            try db.run(table.create { t in
                t.column(id, primaryKey: .autoincrement)
                t.column(value)
                t.column(property)
                t.foreignKey(
                    property,
                    references: Table("Properties"), Expression<Int64>("id"),
                    update: .cascade,
                    delete: .cascade
                )
            })
            try db.run(table.createIndex(value, property, unique: true))
        }

        func values(forProperty propertyId: Int64) -> AnySequence<String> {
            AnySequence<String> { () -> AnyIterator<String> in
                let results = try! db.prepare(table.select(value).where(property == propertyId).order(value.asc))
                let iterator = results.makeIterator()
                return AnyIterator {
                    iterator.next().map { try! $0.get(value)  }
                }
            }
        }

    }

    fileprivate let identifier: String

    fileprivate let outputStreamFactory: OutputStreamFactory
    
    fileprivate var stream: OutputStream!
    
    private var clocks: Set<String> = Set()
    
    private var usingClocks: Bool = false

    fileprivate var firstState: KripkeState?

    private let db: DB

    private var store: KripkeStructure! = nil

    public init(
        identifier: String,
        outputStreamFactory: OutputStreamFactory = FileOutputStreamFactory()
    ) throws {
        self.identifier = identifier
        self.outputStreamFactory = outputStreamFactory
        let name = identifier.components(separatedBy: .whitespacesAndNewlines).joined(separator: "-")
        let db = try Connection("\(name).uppaal.sqlite3")
        self.db = DB(db: db)
        try self.db.reset()
    }

    public func generate(store: KripkeStructure, usingClocks: Bool) throws {
        try self.reset(usingClocks: usingClocks)
        self.store = store
        try self.commit(states: store.states)
        try self.finish()
    }

    private func reset(usingClocks: Bool) throws {
        self.clocks = ["c"]
        self.usingClocks = usingClocks
        self.stream = self.outputStreamFactory.make(id: self.identifier + ".xml")
        try self.db.reset()
        self.firstState = nil
        self.store = nil
    }

    private func commit<S: Sequence>(states: S) throws where S.Iterator.Element == KripkeState {
        var iterator = states.makeIterator()
        guard let first = iterator.next() else {
            return
        }
        self.firstState = first
        try self.commit(state: first)
        while let state = iterator.next() {
            try self.commit(state: state)
        }
    }

    private func commit(state: KripkeState) throws {
        state.edges.lazy.compactMap { $0.clockName }.forEach {
            let clockName = self.convert(label: $0)
            self.clocks.insert(clockName)
        }
        let props = self.extract(from: state.properties)
        for (key, value) in props {
            try self.db.insertIfNotExists(property: key, value: value)
        }
    }

    private func finish() throws {
        defer { self.stream.close() }
        self.stream.flush()
        if self.usingClocks {
            self.stream.write("@TIME_DOMAIN continuous\n\n")
        }
        self.stream.write("MODULE main\n\n")
        var outputStream: TextOutputStream = self.stream
        self.createPropertiesList(usingStream: &outputStream)
        try self.createInitial(usingStream: &outputStream)
        try self.createTransitions(writingTo: &outputStream)
        self.stream.flush()
    }

    fileprivate func createPropertiesList(usingStream stream: inout TextOutputStream) {
        if self.usingClocks {
            stream.write("VAR sync: real;\n")
            stream.write("INVAR sync >= 0;\n\n")
            stream.write("VAR c: clock;\n")
            stream.write("INVAR c >= 0;\n")
            stream.write("INVAR c <= sync;\n\n")
            self.clocks.lazy.filter { $0 != "c" }.sorted().forEach {
                stream.write("VAR \($0): real;\n")
                stream.write("VAR \($0)-time: clock;\n")
                stream.write("INVAR \($0)-time >= c;\n\n")
            }
        }
        stream.write("VAR status: {\n")
        stream.write("    \"error\",\n")
        stream.write("    \"executing\",\n")
        stream.write("    \"finished\",\n")
        stream.write("    \"waiting\"\n")
        stream.write("};\n\n")
        for (property, values) in self.db.propertyValues {
            guard let first = values.first(where: { _ in true }) else {
                stream.write("\(property) : {};\n\n")
                return
            }
            stream.write("VAR \(property) : {\n")
            stream.write("    " + first)
            values.dropFirst().forEach {
                stream.write(",\n    " + $0)
            }
            stream.write("\n};\n\n")
        }
    }

    fileprivate func createInitial(usingStream stream: inout TextOutputStream) throws {
        if try nil == self.store.initialStates.first(where: { _ in true }) {
            stream.write("INIT();\n")
            return
        }
        let allClocks = self.usingClocks ? self.clocks.sorted() : []
        stream.write("INIT\n")
        let initials = try self.store.initialStates.lazy.map {
            var props = self.extract(from: $0.properties)
            if self.usingClocks {
                props["sync"] = "0"
                props["c"] = "0"
                allClocks.lazy.filter { $0 != "c" }.forEach {
                    props[$0] = "0"
                    props[$0 + "-time"] = "0"
                }
            }
            props["status"] = "\"executing\""
            return "(" + self.createConditions(of: props) { $0 + "\n    & " + $1 } + ")"
        }.sorted().combine("") { $0 + "\n| " + $1 }
        stream.write(initials + ";")
        stream.write("\n\n")
    }

    fileprivate func createTransitions(
        writingTo outputStream: inout TextOutputStream
    ) throws {
        let cases = try self.store.states.lazy.compactMap { (state) -> String? in
            guard let content = self.createCase(of: state) else {
                return nil
            }
            return content
        }
        for str in cases.sorted() {
            outputStream.write(str)
            outputStream.write("\n")
        }
        try self.store.acceptingStates.forEach {
            let props = self.extract(from: $0.properties)
            let conditions = self.createAcceptingTansition(for: props)
            outputStream.write(conditions + "\n\n")
        }
        if self.usingClocks {
            outputStream.write(self.createWaitCase() + "\n\n")
        }
        outputStream.write(self.createFinishCase() + "\n\n")
        outputStream.write("TRANS status = \"error\" -> next(status) = \"error\";\n\n")
    }

    fileprivate func createCase(of state: KripkeState) -> String? {
        if state.edges.isEmpty {
            return nil
        }
        var cases: [String: Set<String>] = [:]
        cases.reserveCapacity(state.edges.count)
        var urgentCases: [String: Set<String>] = [:]
        urgentCases.reserveCapacity(state.edges.count)
        let sourceProps = self.extract(from: state.properties)
        state.edges.forEach { edge in
            var constraints: [String: ClockConstraint] = [:]
            if self.usingClocks, let referencingClock = edge.clockName, let constraint = edge.constraint {
                let clockName = self.convert(label: referencingClock)
                constraints[clockName] = constraint
            }
            
            let targetProps = self.extract(from: edge.target)
            var newCases: [String: String] = [:]
            newCases.reserveCapacity(2)
            if self.usingClocks {
                var sourceProps = sourceProps
                sourceProps["status"] = "\"executing\""
                let conditions = self.createConditions(of: sourceProps, constraints: constraints)
                newCases[conditions] = self.createEffect(from: ["status": "\"waiting\""], duration: edge.time)
                sourceProps["status"] = "\"waiting\""
                let executingCondition = self.createConditions(of: sourceProps, constraints: constraints)
                var targetProps = targetProps
                targetProps["c"] = "0"
                targetProps["sync"] = "0"
                targetProps["status"] = "\"executing\""
                newCases[executingCondition] = self.createEffect(from: targetProps, clockName: edge.clockName, resetClock: edge.resetClock, readTime: edge.takeSnapshot)
            } else {
                let conditions = self.createConditions(of: sourceProps, constraints: constraints)
                newCases[conditions] = self.createEffect(from: targetProps)
            }
            for (conditions, effect) in newCases {
                if nil == cases[conditions] {
                    cases[conditions] = [effect]
                } else {
                    cases[conditions]?.insert(effect)
                }
            }
            /*let transition = "TRANS " + conditions + "\n    -> " + effect
            return transition + ";\n"*/
        }
        func combine(label: String) -> (String, Set<String>) -> String? {
            return { (condition, effects) in
                let effect = effects.sorted().lazy.map { "(" + $0 + ")" }.combine("") { $0 + "\n    | " + $1  }
                if effect.isEmpty {
                    return nil
                }
                return label + " " + condition + "\n    -> (" + effect + ");\n"
            }
        }
        let transitions = cases.compactMap(combine(label: "TRANS"))
        let urgentTransitions = urgentCases.compactMap(combine(label: "URGENT"))
        let combined = (transitions + urgentTransitions).sorted().combine("") { $0 + "\n" + $1 }
        return combined.isEmpty ? nil : combined
    }
    
    private func createWaitCase() -> String {
        let condition = "TRANS c < sync & status != \"finished\""
        let mandatory = ["next(status) = status"]
        let extras = self.usingClocks ? ["next(sync) = sync", "next(c) = sync"] : []
        let clockNames = self.clocks.subtracting(["c"])
        let fullList = (Array(self.db.propertyNames) + Array(clockNames)) + clockNames.subtracting(["c"]).map { $0 + "-time" }
        let effects = fullList.sorted().map { "next(" + $0 + ") = " + $0 } + extras + mandatory
        let effectList = effects.combine("") { $0 + "\n    & " + $1 }
        return condition + "\n    -> " + effectList + ";"
    }
    
    private func createFinishCase() -> String {
        let condition = "TRANS status = \"finished\""
        let mandatory = ["next(status) = status"]
        let extras = self.usingClocks ? ["next(sync) = sync", "next(c) = c"] : []
        let clockNames = self.clocks.subtracting(["c"])
        let fullList = (Array(self.db.propertyNames) + Array(clockNames)) + clockNames.subtracting(["c"]).map { $0 + "-time" }
        let effects = fullList.sorted().map { "next(" + $0 + ") = " + $0 } + extras + mandatory
        let effectList = effects.combine("") { $0 + "\n    & " + $1 }
        return condition + "\n    -> " + effectList + ";"
    }
    
    private func createAcceptingTansition(for props: [String: String]) -> String {
        let condition = self.createConditions(of: props)
        let effect = self.createAcceptingEffect(for: props)
        return "TRANS " + condition + "\n    -> " + effect + ";"
    }
    
    private func createAcceptingEffect(for props: [String: String]) -> String {
        var targetProps = Dictionary<String, String>(minimumCapacity: props.count + self.clocks.count)
        props.forEach {
            targetProps[$0.0] = $0.0
        }
        if self.usingClocks {
            targetProps["c"] = "c"
            self.clocks.lazy.filter { $0 != "c" }.forEach {
                targetProps[$0] = $0
                targetProps[$0 + "-time"] = $0 + "-time"
            }
        }
        targetProps["status"] = "\"finished\""
        return self.createEffect(from: targetProps)
    }

    fileprivate func createConditions(of props: [String: String], constraints: [String: ClockConstraint] = [:], combine: (String, String) -> String = { $0 + " & " + $1 }) -> String {
        var props = props
        if self.usingClocks, nil == props["c"] {
            props["c"] = "sync"
        }
        if nil == props["status"] {
            props["status"] = "\"executing\""
        }
        let propValues = props.sorted { $0.key <= $1.key }.map { $0 + " = " + $1 }
        let constraintValues = constraints.sorted { $0.key <= $1.key }.map { "(" + self.expression(for: $1.reduced, referencing: $0) + ")" }
        return (propValues + constraintValues).combine("", combine)
    }
    
    private func expression(for constraint: ClockConstraint, referencing label: String) -> String {
        return constraint.expression(referencing: label, equal: { $0 + "=" + $1 }, and: { $0 + " & " + $1 }, or: { $0 + " | " + $1 })
    }

    fileprivate func createEffect(from props: [String: String], clockName: String? = nil, resetClock: Bool = false, duration: UInt? = nil, readTime: Bool = false, forcePC: String? = nil) -> String {
        var props = props
        if nil == props["status"] {
            props["status"] = "\"executing\""
        }
        if self.usingClocks {
            if nil == props["c"] {
                props["c"] = "0"
            }
            if let rawClockName = clockName {
                let clockName = self.convert(label: rawClockName)
                if resetClock {
                    props[clockName + "-time"] = "0"
                }
                if readTime {
                    props[clockName] = resetClock ? "0" : clockName + "-time"
                }
            }
            if let duration = duration {
                props["sync"] = "\(duration)"
            } else {
                props["sync"] = props["sync"] ?? "sync"
            }
        }
        let allKeys: Set<String>
        if self.usingClocks {
            allKeys = Set(self.db.propertyNames).union(self.clocks).union(Set(self.clocks.lazy.filter { $0 != "c" }.map { $0 + "-time" }))
        } else {
            allKeys = Set(self.db.propertyNames)
        }
        let missingKeys = allKeys.subtracting(Set(props.keys))
        missingKeys.forEach {
            props[$0] = $0
        }
        return props.sorted { $0.key <= $1.key }.lazy.map {
            if let newPC = forcePC, $0.key == "pc" {
                return "next(pc)=" + newPC
            }
            return "next(" + $0.key + ")=" + $0.value
        }.combine("") { $0 + "\n    & " + $1}
    }

    private func convert(label: String) -> String {
        guard let first = label.first else {
            return ""
        }
        var str = ""
        if (first < "a" || first > "z") && (first < "A" || first > "Z") {
            str += "_"
        }
        str += self.formatString(label)
        return str
    }

    private func formatString(_ str: String) -> String {
        return str.lazy.map {
            if $0 == "." {
                return "."
            }
            if ($0 < "a" || $0 > "z")
                && ($0 < "A" || $0 > "Z")
                && ($0 < "0" || $0 > "9")
            {
                return ""
            }
            return "\($0)"
        }.joined()
    }

    public func extract(from list: KripkeStatePropertyList) -> [String: String] {
        let dict: Ref<[String: String]> = Ref(value: [:])
        self.convert(list, properties: dict)
        return dict.value
    }

    fileprivate func convert(
        _ list: KripkeStatePropertyList,
        properties: Ref<[String: String]>,
        prepend: String? = nil
    ) {
        let preLabel = prepend.map { $0 + "." } ?? ""
        list.forEach { (key, property) in
            let label = self.convert(label: preLabel + key)
            self.convert(property, properties: properties, label: label)
        }
    }

    fileprivate func convert(_ property: KripkeStateProperty, properties: Ref<[String: String]>, label: String) {
        switch property.type {
        case .Bool:
            properties.value[label] = "\(property.value as! Bool)"
        case .Int:
            self.convert(integer: property.value as! Int, properties: properties, label: label)
        case .Int8:
            self.convert(integer: property.value as! Int8, properties: properties, label: label)
        case .Int16:
            self.convert(integer: property.value as! Int16, properties: properties, label: label)
        case .Int32:
            self.convert(integer: property.value as! Int32, properties: properties, label: label)
        case .Int64:
            self.convert(integer: property.value as! Int64, properties: properties, label: label)
        case .UInt:
            self.convert(integer: property.value as! UInt, properties: properties, label: label)
        case .UInt8:
            self.convert(integer: property.value as! UInt8, properties: properties, label: label)
        case .UInt16:
            self.convert(integer: property.value as! UInt16, properties: properties, label: label)
        case .UInt32:
            self.convert(integer: property.value as! UInt32, properties: properties, label: label)
        case .UInt64:
            self.convert(integer: property.value as! UInt64, properties: properties, label: label)
        case .Float, .Double:
            fatalError("Floats and Doubles are not yet implemented.")
#if (arch(i386) || arch(x86_64)) && !os(Windows) && !os(Android)
        case .Float80:
            fatalError("Float80 is not yet implemented.")
#endif
        case .String:
            let str = property.value as! String
            let cString = Array(str.utf8CString)
            let props = cString.map { KripkeStateProperty(type: .Int8, value: Int8($0)) }
            let collection = KripkeStateProperty(type: .Collection(props), value: props)
            self.convert(collection, properties: properties, label: label)
        case .Optional(let property):
            switch property {
            case .none:
                self.convert(
                    KripkeStateProperty(
                        type: .Compound(
                            KripkeStatePropertyList(properties: [
                                "hasValue": KripkeStateProperty(type: .Bool, value: false as Any)
                            ])
                        ),
                        value: ["hasValue": false as Any]
                    ),
                    properties: properties,
                    label: label
                )
            case .some(let prop):
                self.convert(
                    KripkeStateProperty(
                        type: .Compound(
                            KripkeStatePropertyList(properties: [
                                "hasValue": KripkeStateProperty(type: .Bool, value: true as Any),
                                "value": prop
                            ])
                        ),
                        value: [
                            "hasValue": true as Any,
                            "value": prop.value
                        ]
                    ),
                    properties: properties,
                    label: label
                )
            }
        case .EmptyCollection:
            return
        case .Collection(let props):
            for (index, property) in props.enumerated() {
                self.convert(
                    property,
                    properties: properties,
                    label: label + "[\(index)]"
                )
            }
        case .Compound(let list):
            self.convert(list, properties: properties, prepend: label)
        }
    }

    private func convert<I: SignedInteger>(
        integer value: I,
        properties: Ref<[String: String]>,
        label: String
    ) {
        if MemoryLayout<I>.size <= 4 {
            properties.value[label] = "\(properties.value)"
        } else {
            guard let value = Int(exactly: value) else {
                fatalError("Cannot encapsulate value '\(value)' within an Int.")
            }
            let bitPattern = UInt(bitPattern: value)
            self.convert(bitPattern: bitPattern, properties: properties, label: label)
        }
    }

    private func convert<I: UnsignedInteger>(
        integer value: I,
        properties: Ref<[String: String]>,
        label: String
    ) {
        if MemoryLayout<I>.size < 4 {
            properties.value[label] = "\(properties.value)"
            return
        } else {
            guard let bitPattern = UInt(exactly: value) else {
                fatalError("Cannot encapsulate value '\(value)' within a UInt.")
            }
            self.convert(bitPattern: bitPattern, properties: properties, label: label)
        }
    }

    private func convert(bitPattern: UInt, properties: Ref<[String: String]>, label: String) {
        let totalBytes = MemoryLayout<Int>.size
        var dict: [String: UInt8] = [:]
        dict.reserveCapacity(totalBytes)
        for byteNumber in 0..<totalBytes {
            dict["b\(byteNumber)"] = UInt8((bitPattern >> (8 * byteNumber)) & UInt(UInt8.max))
        }
        let plist = KripkeStatePropertyList(
            properties: dict.mapValues { KripkeStateProperty(type: .UInt8, value: $0) }
        )
        self.convert(
            KripkeStateProperty(
                type: .Compound(plist),
                value: dict
            ),
            properties: properties,
            label: label
        )
    }

}
