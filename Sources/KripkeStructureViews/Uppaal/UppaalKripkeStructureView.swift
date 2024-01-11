import IO
import KripkeStructure

#if os(macOS)
import Darwin
#else
import Glibc
#endif

public final class UppaalKripkeStructureView: KripkeStructureView {

    fileprivate let identifier: String

    fileprivate let outputStreamFactory: OutputStreamFactory
    
    fileprivate var stream: OutputStream!
    
    private var clocks: Set<String> = Set()
    
    private var usingClocks: Bool = false

    private var store: KripkeStructure! = nil

    public init(
        identifier: String,
        outputStreamFactory: OutputStreamFactory = FileOutputStreamFactory()
    ) throws {
        self.identifier = identifier
        self.outputStreamFactory = outputStreamFactory
    }

    public func generate(store: KripkeStructure, usingClocks: Bool) throws {
        try self.reset(usingClocks: usingClocks)
        self.store = store
        try self.finish()
    }

    private func reset(usingClocks: Bool) throws {
        self.clocks = ["c"]
        self.usingClocks = usingClocks
        self.stream = self.outputStreamFactory.make(id: self.identifier + ".xml")
        self.store = nil
    }

    private func finish() throws {
        defer { self.stream.close() }
        self.stream.flush()
        var template = UppaalTemplate(name: UppaalName(name: self.store.identifier))
        try self.createInitial(&template)
        try self.createLocations(&template)
        try self.createTransitions(&template)
        let model = UppaalModel(globalDeclarations: "", templates: [template])
        self.stream.write(model.modelRepresentation)
        self.stream.flush()
    }

    private func createInitial(_ template: inout UppaalTemplate) throws {
        let id = "initial"
        template.initialLocation = id
        template.locations.append(UppaalLocation(id: id, name: UppaalName(name: id), type: .committed))
        if try nil == self.store.initialStates.first(where: { _ in true }) {
            return
        }
        let initials = try self.store.initialStates.lazy.map {
            let stateID = try self.store.id(for: $0.properties)
            let props = self.extract(from: $0.properties)
            let assignments = props.map {
                UppaalAssignmentExpression(lhs: $0, rhs: $1)
            }
            let assignmentLabel = UppaalAssignmentLabel(assignments: assignments)
            let transition = UppaalTransition(
                source: id,
                target: "id\(stateID)",
                assignmentLabel: assignmentLabel
            )
            return transition
        }
        template.transitions.append(contentsOf: initials)
    }

    private func createLocations(_ template: inout UppaalTemplate) throws {
        for state in try self.store.states {
            let stateID = try self.store.id(for: state.properties)
            let id = "id\(stateID)"
            let location = UppaalLocation(id: id, name: UppaalName(name: id), type: .committed)
            template.locations.append(location)
        }
    }

    private func createTransitions(_ template: inout UppaalTemplate) throws {
        for state in try self.store.states where !state.edges.isEmpty {
            let stateID = try self.store.id(for: state.properties)
            let sourceID = "id\(stateID)"
            let stateProps = self.extract(from: state.properties)
            let startingCondition: UppaalLogicalCondition?
            if let (key, value) = stateProps.first {
                startingCondition = stateProps.dropFirst().map {
                    UppaalLogicalCondition.equal($0, $1)
                }.reduce(UppaalLogicalCondition.equal(key, value)) {
                    UppaalLogicalCondition.and($0, $1)
                }
            } else {
                startingCondition = nil
            }
            for edge in state.edges {
                let targetStateID = try self.store.id(for: edge.target)
                let targetID = "id\(targetStateID)"
                let props = self.extract(from: edge.target)
                let assignments = props.map {
                    UppaalAssignmentExpression(lhs: $0, rhs: $1)
                }
                let assignmentLabel = UppaalAssignmentLabel(assignments: assignments)
                guard usingClocks else {
                    let transition = UppaalTransition(
                        source: sourceID,
                        target: targetID,
                        guardLabel: startingCondition.map { UppaalGuardLabel(condition: $0) },
                        assignmentLabel: assignmentLabel
                    )
                    template.transitions.append(transition)
                    continue
                }
                let syncID = sourceID + "sync" + targetID
                let syncLocation = UppaalLocation(id: syncID, name: UppaalName(name: syncID))
                template.locations.append(syncLocation)
                let edgeCondition: UppaalLogicalCondition?
                if self.usingClocks, let referencingClock = edge.clockName, let constraint = edge.constraint {
                    let syncCondition = UppaalLogicalCondition(lhs: referencingClock, constraint: constraint)
                    edgeCondition = startingCondition.map { .and($0, syncCondition) } ?? syncCondition
                } else {
                    edgeCondition = startingCondition
                }
                let syncTransition = UppaalTransition(
                    source: sourceID,
                    target: syncID,
                    guardLabel: edgeCondition.map { UppaalGuardLabel(condition: $0) },
                    assignmentLabel: assignmentLabel
                )
                template.transitions.append(syncTransition)
                let transitionGuard = UppaalGuardLabel(condition: .equal("syn", "\(edge.time)"))
                let transitionAssignment = UppaalAssignmentLabel(assignments: [
                    UppaalAssignmentExpression(lhs: "syn", rhs: "0")
                ])
                let transition = UppaalTransition(
                    source: syncID,
                    target: targetID,
                    guardLabel: transitionGuard,
                    assignmentLabel: transitionAssignment
                )
                template.transitions.append(transition)
            }
        }
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
