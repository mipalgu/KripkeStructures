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

    var simpleStructureIdentifier: String {
        readableName + "-simple"
    }

    var simpleStructure: InMemoryKripkeStructure {
        get throws {
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
                    isInitial: true,
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
                    constraint: .equal(value: 3),
                    resetClock: true,
                    takeSnapshot: true,
                    time: 5,
                    target: states[1].properties
                )
            )
            return try InMemoryKripkeStructure(identifier: simpleStructureIdentifier, states: states)
        }
    }

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

}
