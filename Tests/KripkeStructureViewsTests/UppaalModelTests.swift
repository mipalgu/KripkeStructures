import XCTest

@testable import KripkeStructureViews

final class UppaalModelTests: XCTestCase {

    func test_simpleModelModelRepresentation() {
        let locations = [UppaalLocation(id: "id0", name: "id0"), UppaalLocation(id: "id1", name: "id1")]
        let transitions = [UppaalTransition(source: "id0", target: "id1")]
        let template = UppaalTemplate(
            name: "SomeTemplate",
            initialLocation: "id0",
            locations: locations,
            transitions: transitions
        )
        let model = UppaalModel(globalDeclarations: "", templates: [template])
        let expected = """
        <?xml version="1.0" encoding="utf-8"?><!DOCTYPE nta PUBLIC '-//Uppaal Team//DTD Flat System 1.1//EN' 'http://www.it.uu.se/research/group/darts/uppaal/flat-1_1.dtd'>
        <nta><declaration></declaration><template><name x="0" y="0">SomeTemplate</name><location id="id0" x="0" y="0"><name x="0" y="0">id0</name></location><location id="id1" x="0" y="0"><name x="0" y="0">id1</name></location><init ref="id0"/><transition><source ref="id0"/><target ref="id1"/></transition></template><system>SomeTemplateProcess = SomeTemplate();\("\n")
        system SomeTemplateProcess;</system></nta>
        """
        XCTAssertEqual(model.modelRepresentation, expected)
    }

}
