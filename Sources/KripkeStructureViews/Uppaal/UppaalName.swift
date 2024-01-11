struct UppaalName: Hashable, Codable, Sendable {

    var name: String

    var x: Int

    var y: Int

    var modelRepresentation: String {
        "<name x=\"\(x)\" y=\"\(y)\">\(name)</name>"
    }

    init(name: String, x: Int = 0, y: Int = 0) {
        self.name = name
        self.x = x
        self.y = y
    }

}
