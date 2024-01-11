enum UppaalLocationType: String, Hashable, Codable, Sendable, CaseIterable {

    case normal

    case urgent

    case committed

    var modelRepresentation: String {
        switch self {
        case .normal:
            return ""
        default:
            return "<" + rawValue + "/>"
        }
    }

}
