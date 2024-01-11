struct UppaalAssignmentLabel: Hashable, Codable, Sendable {

    var assignments: [UppaalAssignmentExpression]

    var x: Int

    var y: Int

    var modelRepresentation: String {
        // swiftlint:disable:next line_length
        "<label kind=\"assignment\" x=\"\(x)\" y=\"\(y)\">\(assignments.sorted { $0.lhs < $1.lhs }.map(\.modelRepresentation).joined(separator: ", "))</label>"
    }

    init(assignments: [UppaalAssignmentExpression] = [], x: Int = 0, y: Int = 0) {
        self.assignments = assignments
        self.x = x
        self.y = y
    }

}
