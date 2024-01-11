struct UppaalLocation: Hashable, Codable, Sendable {

    var id: String

    var name: UppaalName?

    var type: UppaalLocationType

    var invariant: UppaalInvariantLabel?

    var x: Int

    var y: Int

    var modelRepresentation: String {
        // swiftlint:disable:next line_length
        "<location id=\"\(id)\" x=\"\(x)\" y=\"\(y)\">\(name?.modelRepresentation ?? "")\(invariant?.modelRepresentation ?? "")\(type.modelRepresentation)</location>"
    }

    init(
        id: String,
        name: UppaalName? = nil,
        type: UppaalLocationType = .normal,
        invariant: UppaalInvariantLabel? = nil,
        x: Int = 0,
        y: Int = 0
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.invariant = invariant
        self.x = x
        self.y = y
    }

}
