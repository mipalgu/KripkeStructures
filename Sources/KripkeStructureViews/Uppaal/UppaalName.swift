struct UppaalName: Hashable, Codable, Sendable, ExpressibleByStringLiteral {

    var name: String

    var x: Int

    var y: Int

    var modelRepresentation: String {
        "<name x=\"\(x)\" y=\"\(y)\">\(name)</name>"
    }

    init(stringLiteral value: String) {
        self.init(name: value)
    }

    init(name: String, x: Int = 0, y: Int = 0) {
        self.name = name
        self.x = x
        self.y = y
    }

}
