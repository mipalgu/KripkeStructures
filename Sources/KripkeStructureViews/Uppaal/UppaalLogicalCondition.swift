import KripkeStructure

enum UppaalLogicalCondition: Hashable, Codable, Sendable {

    case equal(String, String)

    case notEqual(String, String)

    case greaterThan(String, String)

    case greaterThanEqual(String, String)

    case lessThan(String, String)

    case lessThanEqual(String, String)

    indirect case and(UppaalLogicalCondition, UppaalLogicalCondition)

    indirect case or(UppaalLogicalCondition, UppaalLogicalCondition)

    indirect case not(UppaalLogicalCondition)

    var modelRepresentation: String {
        switch self {
        case .equal(let lhs, let rhs):
            return lhs + " == " + rhs
        case .notEqual(let lhs, let rhs):
            return lhs + " != " + rhs
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
        case .not(let condition):
            return "!" + condition.modelRepresentation
        }
    }

    init<T>(lhs: String, constraint: Constraint<T>, format: (T) -> String = { "\($0)" }) {
        switch constraint {
        case .equal(let value):
            self = .equal(lhs, format(value))
        case .notEqual(let value):
            self = .notEqual(lhs, format(value))
        case .lessThan(let value):
            self = .lessThan(lhs, format(value))
        case .lessThanEqual(let value):
            self = .lessThanEqual(lhs, format(value))
        case .greaterThan(let value):
            self = .greaterThan(lhs, format(value))
        case .greaterThanEqual(let value):
            self = .greaterThanEqual(lhs, format(value))
        case .and(let p, let q):
            let newP = UppaalLogicalCondition(lhs: lhs, constraint: p, format: format)
            let newQ = UppaalLogicalCondition(lhs: lhs, constraint: q, format: format)
            self = .and(newP, newQ)
        case .or(let p, let q):
            let newP = UppaalLogicalCondition(lhs: lhs, constraint: p, format: format)
            let newQ = UppaalLogicalCondition(lhs: lhs, constraint: q, format: format)
            self = .or(newP, newQ)
        case .implies(let p, let q):
            let newP = UppaalLogicalCondition(lhs: lhs, constraint: p, format: format)
            let newQ = UppaalLogicalCondition(lhs: lhs, constraint: q, format: format)
            self = .or(.not(newP), newQ)
        case .not(let constraint):
            self = .not(UppaalLogicalCondition(lhs: lhs, constraint: constraint, format: format))
        }
    }
    
}
