struct UppaalModel: Hashable, Codable, Sendable {

    var globalDeclarations: String

    var templates: [UppaalTemplate]

    init(globalDeclarations: String = "", templates: [UppaalTemplate] = []) {
        self.globalDeclarations = globalDeclarations
        self.templates = templates
    }

}
