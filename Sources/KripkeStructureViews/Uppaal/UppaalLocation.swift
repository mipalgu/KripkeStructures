import Graphs

struct UppaalLocation: NodeProtocol, Hashable, Codable, Sendable {

    var id: String

    var name: UppaalName?

    var type: UppaalLocationType

    var invariant: UppaalInvariantLabel?

    var x: Int {
        didSet {
            name?.x = x
            invariant?.x = x
        }
    }

    var y: Int {
        didSet {
            if y > Int.max - 20 {
                name?.y = Int.max
            } else {
                name?.y = y + 20
            }
            if y < Int.min + 30 {
                invariant?.y = Int.min
            } else {
                invariant?.y = y - 30
            }
        }
    }

    var mass: Double = 1

    var force: Point2D = 0

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
