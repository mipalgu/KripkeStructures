struct UppaalAssignmentExpression: Hashable, Codable, Sendable {

    var lhs: String

    var rhs: String

    var modelRepresentation: String {
        return lhs + " := " + rhs
    }

    init(lhs: String, rhs: String) {
        self.lhs = lhs
        self.rhs = rhs
    }

}
