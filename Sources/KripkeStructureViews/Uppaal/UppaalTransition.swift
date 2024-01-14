import Graphs

struct UppaalTransition: ConnectionProtocol, Hashable, Codable, Sendable {

    typealias Node = UppaalLocation

    var source: String

    var target: String

    var distance: Double

    var guardLabel: UppaalGuardLabel?

    var assignmentLabel: UppaalAssignmentLabel?

    var lhs: String {
        source
    }

    var modelRepresentation: String {
        // swiftlint:disable:next line_length
        "<transition><source ref=\"\(source)\"/><target ref=\"\(target)\"/>\(guardLabel?.modelRepresentation ?? "")\(assignmentLabel?.modelRepresentation ?? "")</transition>"
    }

    var rhs: String {
        target
    }

    init(
        source: String,
        target: String,
        distance: Double = 1000,
        guardLabel: UppaalGuardLabel? = nil,
        assignmentLabel: UppaalAssignmentLabel? = nil
    ) {
        self.source = source
        self.target = target
        self.distance = distance
        self.guardLabel = guardLabel
        self.assignmentLabel = assignmentLabel
    }

}
