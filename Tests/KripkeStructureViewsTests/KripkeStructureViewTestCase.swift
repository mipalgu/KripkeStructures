import Foundation
import KripkeStructure
import XCTest

class KripkeStructureViewTestCase: XCTestCase {

    var readableName: String {
#if os(macOS)
        self.name.dropFirst(2).dropLast().components(separatedBy: .whitespacesAndNewlines).joined(separator: "_")
#else
        self.name.components(separatedBy: .whitespacesAndNewlines).joined(separator: "_")
#endif
    }

    var originalPath: String!

    var testFolder: URL!

    override func setUpWithError() throws {
        let fm = FileManager.default
        originalPath = fm.currentDirectoryPath
        let filePath = URL(fileURLWithPath: #filePath, isDirectory: false)
        testFolder = filePath
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("kripke_structures", isDirectory: true)
            .appendingPathComponent(readableName, isDirectory: true)
        _ = try? fm.removeItem(atPath: testFolder.path)
        try fm.createDirectory(at: testFolder, withIntermediateDirectories: true)
        fm.changeCurrentDirectoryPath(testFolder.path)
    }

    override func tearDownWithError() throws {
        let fm = FileManager.default
        fm.changeCurrentDirectoryPath(originalPath)
    }

    func simpleStructure(_ identifier: String) throws -> InMemoryKripkeStructure {
        let states = [
            KripkeState(
                isInitial: true,
                properties: KripkeStatePropertyList(
                    properties: [
                        "value": KripkeStateProperty(type: .Bool, value: false as Any)
                    ]
                )
            ),
            KripkeState(
                isInitial: false,
                properties: KripkeStatePropertyList(
                    properties: [
                        "value": KripkeStateProperty(type: .Bool, value: true as Any)
                    ]
                )
            )
        ]
        states[0].addEdge(
            KripkeEdge(
                clockName: "c0",
                constraint: .lessThanEqual(value: 3),
                resetClock: true,
                takeSnapshot: true,
                time: 5,
                target: states[1].properties
            )
        )
        states[1].addEdge(
            KripkeEdge(
                clockName: "c0",
                constraint: .lessThanEqual(value: 3),
                resetClock: true,
                takeSnapshot: true,
                time: 5,
                target: states[0].properties
            )
        )
        return try InMemoryKripkeStructure(identifier: identifier, states: states)
    }

    func complexStructure(_ identifier: String) throws -> InMemoryKripkeStructure {
        func plist(
            b: Bool,
            i: Int,
            i8: Int8,
            i16: Int16,
            i32: Int32,
            i64: Int64,
            u: UInt,
            u8: UInt8,
            u16: UInt16,
            u32: UInt32,
            u64: UInt64,
            str: String,
            o: Bool?,
            arr: [Bool],
            c: Person
        ) -> KripkeStatePropertyList {
            func collapsePerson(_ person: Person) -> KripkeStatePropertyList {
                let friendProperties = person.friends.map {
                    let plist = collapsePerson(Person(friend: $0))
                    return KripkeStateProperty(type: .Compound(plist), value: $0)
                }
                let bestFriend = KripkeStateProperty(
                    type: .Optional(
                        person.bestFriend.map {
                            KripkeStateProperty(
                                type: .Compound(collapsePerson(Person(friend: $0))),
                                value: $0
                            )
                        }
                    ),
                    value: person.bestFriend as Any
                )
                let plist = KripkeStatePropertyList(
                    properties: [
                        "name": KripkeStateProperty(type: .String, value: person.name),
                        "age": KripkeStateProperty(type: .Int, value: person.age),
                        "friends": KripkeStateProperty(
                            type: .Collection(friendProperties),
                            value: person.friends
                        ),
                        "bestFriend": bestFriend
                    ]
                )
                return plist
            }
            return KripkeStatePropertyList(
                properties: [
                    "b": KripkeStateProperty(type: .Bool, value: b),
                    "i": KripkeStateProperty(type: .Int, value: i),
                    "i8": KripkeStateProperty(type: .Int8, value: i8),
                    "i16": KripkeStateProperty(type: .Int16, value: i16),
                    "i32": KripkeStateProperty(type: .Int32, value: i32),
                    "i64": KripkeStateProperty(type: .Int64, value: i64),
                    "u": KripkeStateProperty(type: .UInt, value: u),
                    "u8": KripkeStateProperty(type: .UInt8, value: u8),
                    "u16": KripkeStateProperty(type: .UInt16, value: u16),
                    "u32": KripkeStateProperty(type: .UInt32, value: u32),
                    "u64": KripkeStateProperty(type: .UInt64, value: u64),
                    "str": KripkeStateProperty(type: .String, value: str),
                    "o": KripkeStateProperty(
                        type: .Optional(o.map { KripkeStateProperty(type: .Bool, value: $0) }),
                        value: o as Any
                    ),
                    "arr": KripkeStateProperty(
                        type: .Collection(arr.map { KripkeStateProperty(type: .Bool, value: $0) }),
                        value: arr
                    ),
                    "c": KripkeStateProperty(type: .Compound(collapsePerson(c)), value: c)
                ]
            )
        }
        let states = [
            KripkeState(
                isInitial: true,
                properties: plist(
                    b: false,
                    i: -1,
                    i8: -20,
                    i16: -300,
                    i32: -4000,
                    i64: -50_000,
                    u: 1,
                    u8: 20,
                    u16: 300,
                    u32: 4000,
                    u64: 50_000,
                    str: "Hello",
                    o: .none,
                    arr: [false, true],
                    c: Person(
                        name: "Bob",
                        age: 21,
                        friends: [Friend(name: "Bill", age: 22)],
                        bestFriend: nil
                    )
                )
            ),
            KripkeState(
                isInitial: false,
                properties: plist(
                    b: true,
                    i: -2,
                    i8: -30,
                    i16: -400,
                    i32: -5000,
                    i64: -60_000,
                    u: 2,
                    u8: 30,
                    u16: 400,
                    u32: 5000,
                    u64: 60_000,
                    str: "World!",
                    o: true,
                    arr: [true, true, false],
                    c: Person(
                        name: "Bill",
                        age: 23,
                        friends: [Friend(name: "Bob", age: 18)],
                        bestFriend: Friend(name: "Bob", age: 18)
                    )
                )
            )
        ]
        states[0].addEdge(
            KripkeEdge(
                clockName: "c0",
                constraint: .lessThanEqual(value: 3),
                resetClock: true,
                takeSnapshot: true,
                time: 5,
                target: states[1].properties
            )
        )
        states[1].addEdge(
            KripkeEdge(
                clockName: "c0",
                constraint: .lessThanEqual(value: 10),
                resetClock: true,
                takeSnapshot: true,
                time: 5,
                target: states[0].properties
            )
        )
        return try InMemoryKripkeStructure(identifier: identifier, states: states)
    }

}
