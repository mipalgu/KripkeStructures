struct UppaalTemplate: Hashable, Codable, Sendable {

    var initialLocation: String

    var locations: [UppaalLocation]

    var transitions: [UppaalTransition]

    init(
        initialLocation: String = "",
        locations: [UppaalLocation] = [],
        transitions: [UppaalTransition] = []
    ) {
        self.initialLocation = initialLocation
        self.locations = locations
        self.transitions = transitions
    }

}
