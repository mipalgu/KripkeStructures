struct UppaalLocation: Hashable, Codable, Sendable {

    var id: String

    var name: String

    var type: UppaalLocationType

    var x: Int

    var y: Int

    init(id: String, name: String, type: UppaalLocationType = .normal, x: Int = 0, y: Int = 0) {
        self.id = id
        self.name = name
        self.type = type
        self.x = x
        self.y = y
    }

}
