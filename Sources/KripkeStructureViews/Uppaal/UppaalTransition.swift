struct UppaalTransition: Hashable, Codable, Sendable {

    var source: String

    var target: String

    var guardLabel: UppaalGuardLabel?

    var assignmentLabel: UppaalAssignmentLabel?

    var modelRepresentation: String {
        // swiftlint:disable:next line_length
        "<transition><source ref=\"\(source)\"/><target ref=\"\(target)\"/>\(guardLabel?.modelRepresentation ?? "")\(assignmentLabel?.modelRepresentation ?? "")</transition>"
    }

    init(
        source: String,
        target: String,
        guardLabel: UppaalGuardLabel? = nil,
        assignmentLabel: UppaalAssignmentLabel? = nil
    ) {
        self.source = source
        self.target = target
        self.guardLabel = guardLabel
        self.assignmentLabel = assignmentLabel
    }

}
