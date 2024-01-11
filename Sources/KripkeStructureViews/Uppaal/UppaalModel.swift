struct UppaalModel: Hashable, Codable, Sendable {

    var globalDeclarations: String

    var templates: [UppaalTemplate]

    var modelRepresentation: String {
        // swiftlint:disable:next line_length
        let head = "<?xml version=\"1.0\" encoding=\"utf-8\"?><!DOCTYPE nta PUBLIC '-//Uppaal Team//DTD Flat System 1.1//EN' 'http://www.it.uu.se/research/group/darts/uppaal/flat-1_1.dtd'>\n<nta>"
        let declarations = "<declaration>" + globalDeclarations + "</declaration>"
        let templatesDefinition = templates.map(\.modelRepresentation).joined()
        let systemContent = templates.sorted { $0.name.name < $1.name.name }.map {
            $0.name.name + "Process = " + $0.name.name + "();"
        }.joined(separator: "\n")
        let systemTail = "system " + templates.map { $0.name.name + "Process" }.joined(separator: ", ") + ";"
        let systemDefinition = "<system>\(systemContent)\n\n\(systemTail)</system>"
        let tail = "</nta>"
        return head + declarations + templatesDefinition + systemDefinition + tail
    }

    init(globalDeclarations: String = "", templates: [UppaalTemplate] = []) {
        self.globalDeclarations = globalDeclarations
        self.templates = templates
    }

}
