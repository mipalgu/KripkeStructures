import KripkeStructure
import XCTest

@testable import KripkeStructureViews

final class UppaalKripkeStructureViewTests: KripkeStructureViewTestCase {

    func test_createsViewWithoutCrashing() throws {
        let view = try UppaalKripkeStructureView(identifier: "simple")
        try view.generate(store: simpleStructure("simple"), usingClocks: true)
    }

    func test_createsComplexViewWithoutCrashing() throws {
        let view = try UppaalKripkeStructureView(identifier: "simple")
        try view.generate(store: complexStructure("complex"), usingClocks: true)
    }

}
