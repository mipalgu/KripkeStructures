struct UppaalInvariantLabel: Hashable, Codable, Sendable {

    var condition: UppaalLogicalCondition

    var x: Int

    var y: Int

    var modelRepresentation: String {
        "<label kind=\"invariant\" x=\"\(x)\" y=\"\(y)\">\(condition.modelRepresentation)</label>"
    }

    init(condition: UppaalLogicalCondition, x: Int = 0, y: Int = 0) {
        self.condition = condition
        self.x = x
        self.y = y
    }

}
