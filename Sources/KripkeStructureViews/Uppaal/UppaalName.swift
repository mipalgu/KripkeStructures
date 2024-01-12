import Foundation

struct UppaalName: Hashable, Codable, Sendable, ExpressibleByStringLiteral {

    private var actualName: String

    var name: String {
        get {
            actualName
        } set {
            let name = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
            actualName = (name.isEmpty || (name.first?.isLetter).map({ !$0 }) ?? true) ? "l" + name : name
        }
    }

    var x: Int

    var y: Int

    var modelRepresentation: String {
        "<name x=\"\(x)\" y=\"\(y)\">\(name)</name>"
    }

    init(stringLiteral value: String) {
        self.init(name: value)
    }

    init(name: String, x: Int = 0, y: Int = 0) {
        let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        self.actualName = (name.isEmpty || (name.first?.isLetter).map({ !$0 }) ?? true) ? "l" + name : name
        self.x = x
        self.y = y
    }

}
