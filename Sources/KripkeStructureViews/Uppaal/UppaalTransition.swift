struct UppaalTransition: Hashable, Codable, Sendable {

    var source: String

    var target: String

    var guardLabel: String

    var assignmentLabel: String

    init(source: String, target: String, guardLabel: String = "", assignmentLabel: String = "") {
        self.source = source
        self.target = target
        self.guardLabel = guardLabel
        self.assignmentLabel = assignmentLabel
    }

}
