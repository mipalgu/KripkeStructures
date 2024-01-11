enum UppaalLogicalCondition: Hashable, Codable, Sendable {

    case equal(String, String)

    case greaterThan(String, String)

    case greaterThanEqual(String, String)

    case lessThan(String, String)

    case lessThanEqual(String, String)

    indirect case and(UppaalLogicalCondition, UppaalLogicalCondition)

    indirect case or(UppaalLogicalCondition, UppaalLogicalCondition)

    var modelRepresentation: String {
        switch self {
        case .equal(let lhs, let rhs):
            return lhs + " == " + rhs
        case .greaterThan(let lhs, let rhs):
            return lhs + " &gt; " + rhs
        case .greaterThanEqual(let lhs, let rhs):
            return lhs + " &gt;= " + rhs
        case .lessThan(let lhs, let rhs):
            return lhs + " &lt; " + rhs
        case .lessThanEqual(let lhs, let rhs):
            return lhs + " &lt;= " + rhs
        case .and(let lhs, let rhs):
            return lhs.modelRepresentation + " &amp;&amp; " + rhs.modelRepresentation
        case .or(let lhs, let rhs):
            return lhs.modelRepresentation + " || " + rhs.modelRepresentation
        }
    }
    
}
