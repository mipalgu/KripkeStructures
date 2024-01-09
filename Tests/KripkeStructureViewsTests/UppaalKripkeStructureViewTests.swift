import KripkeStructure
import XCTest

@testable import KripkeStructureViews

final class UppaalKripkeStructureViewTests: KripkeStructureViewTestCase {

    func test_createsViewWithoutCrashing() throws {
        let view = try UppaalKripkeStructureView(identifier: simpleStructureIdentifier)
        try view.generate(store: simpleStructure, usingClocks: true)
    }

}
