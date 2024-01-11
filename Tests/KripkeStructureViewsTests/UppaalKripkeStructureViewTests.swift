import KripkeStructure
import XCTest

@testable import KripkeStructureViews

final class UppaalKripkeStructureViewTests: KripkeStructureViewTestCase {

    func test_createsViewWithoutCrashing() throws {
        let view = try UppaalKripkeStructureView(identifier: "simple")
        try view.generate(store: simpleStructure("simple"), usingClocks: true)
    }

    func test_createsComplexViewWithoutCrashing() throws {
        let view = try UppaalKripkeStructureView(identifier: "complex")
        try view.generate(store: complexStructure("complex"), usingClocks: true)
    }

    func test_createsStrViewWithoutCrashing() throws {
        let view = try UppaalKripkeStructureView(identifier: "str")
        try view.generate(store: strStructure("str"), usingClocks: true)
    }

}
