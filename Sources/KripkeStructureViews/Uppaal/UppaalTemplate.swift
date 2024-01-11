struct UppaalTemplate: Hashable, Codable, Sendable {

    var name: UppaalName

    var initialLocation: String

    var locations: [UppaalLocation]

    var transitions: [UppaalTransition]

    var modelRepresentation: String {
        // swiftint:disable:next line_length
        "<template>\(name.modelRepresentation)\(locations.map(\.modelRepresentation).joined())<init ref=\"\(initialLocation)\"/>\(transitions.map(\.modelRepresentation).joined())</template>"
    }

    init(
        name: UppaalName,
        initialLocation: String = "",
        locations: [UppaalLocation] = [],
        transitions: [UppaalTransition] = []
    ) {
        self.name = name
        self.initialLocation = initialLocation
        self.locations = locations
        self.transitions = transitions
    }

}
