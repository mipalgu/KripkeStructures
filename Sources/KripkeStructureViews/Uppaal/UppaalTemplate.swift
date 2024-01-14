import Collections
import Graphs

struct UppaalTemplate: GraphProtocol, Hashable, Codable, Sendable {

    typealias Node = UppaalLocation

    typealias Connection = UppaalTransition

    typealias NodeCollection = OrderedDictionary<String, UppaalLocation>.Values

    typealias ConnectionCollection = [UppaalTransition]

    var name: UppaalName

    var initialLocation: String

    var locations: OrderedDictionary<String, UppaalLocation>

    var transitions: [UppaalTransition]

    var modelRepresentation: String {
        // swiftint:disable:next line_length
        "<template>\(name.modelRepresentation)\(nodes.map(\.modelRepresentation).joined())<init ref=\"\(initialLocation)\"/>\(transitions.map(\.modelRepresentation).joined())</template>"
    }

    var nodes: OrderedDictionary<String, UppaalLocation>.Values {
        locations.values
    }

    var connections: [UppaalTransition] {
        transitions
    }

    init(
        name: UppaalName,
        initialLocation: String = "",
        locations: [UppaalLocation] = [],
        transitions: [UppaalTransition] = []
    ) {
        self.name = name
        self.initialLocation = initialLocation
        self.locations = OrderedDictionary(uniqueKeysWithValues: locations.map { ($0.id, $0) })
        self.transitions = transitions
    }

    mutating func adjustLabels() {
        for index in transitions.indices {
            guard
                let source = node( transitions[index].source),
                let target = node( transitions[index].target)
            else {
                continue
            }
            let labels = target.point + ((source.point - target.point) / 2.0)
            transitions[index].guardLabel?.x = Int(labels.x.rounded())
            transitions[index].guardLabel?.y = Int(labels.y.rounded() - 15)
            transitions[index].assignmentLabel?.x = Int(labels.x.rounded())
            transitions[index].assignmentLabel?.y = Int(labels.y.rounded() + 15)
        }
    }

    func node(_ id: String) -> UppaalLocation? {
        locations[id]
    }

    func nodes(after id: String) -> OrderedDictionary<String, UppaalLocation>.Values.SubSequence? {
        guard let startingIndex = locations.index(forKey: id) else {
            return nil
        }
        let nodes = nodes
        return nodes[startingIndex.advanced(by: 1)..<nodes.endIndex]
    }

    mutating func replace(node id: String, with node: UppaalLocation) {
        guard let index = locations.index(forKey: id) else {
            return
        }
        locations.values[index] = node
    }

}
