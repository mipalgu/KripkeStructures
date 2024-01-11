enum UppaalType: Hashable, Codable, Sendable {

    case bool
    
    case int

    case clock

    case chan

    case scalar(Int)

    case typedef(String)

    indirect case record(String, [String: UppaalType])

    indirect case array(UppaalType, Int)

    var typeStr: String {
        switch self {
        case .bool:
            return "bool"
        case .int:
            return "int"
        case .clock:
            return "clock"
        case .chan:
            return "chan"
        case .scalar:
            return "scalar"
        case .typedef(let name):
            return name
        case .record(let name, _):
            return name
        case .array(let elementType, _):
            return elementType.typeStr
        }
    }

    var arrayCounts: [Int] {
        switch self {
        case .array(let innerType, let count):
            return [count] + innerType.arrayCounts
        default:
            return []
        }
    }

    func variableDeclaration(
        label: String,
        prefix pre: String = "",
        includeTypedef: ( String) -> Bool = { _ in true }
    ) -> String? {
        switch self {
        case .bool, .int, .clock, .chan:
            return pre + typeStr + " " + label + ";"
        case .scalar(let count):
            return pre + "scalar " + label + "[\(count)]" + ";"
        case .typedef(let type):
            guard includeTypedef(type) else {
                return nil
            }
            return pre + type + " " + label + ";"
        case .record(_, let types):
            let variableDeclarations = types.compactMap {
                guard
                    let declaration = $1.variableDeclaration(
                        label: $0,
                        prefix: pre + "  ",
                        includeTypedef: includeTypedef
                    )
                else {
                    return nil
                }
                return pre + "  " + declaration
            }.joined(separator: "\n") 
            return pre + "struct\n{" + variableDeclarations + "\n" + pre + "} " + label + ";"
        case .array:
            return typeStr + " " + label + arrayCounts.map { "[\($0)]" }.joined() + ";"
        }
    }

    func typedefDeclaration(
        aliasing innerType: UppaalType,
        prefix pre: String = "",
        includeTypedef: (String) -> Bool = { _ in true }
    ) -> String? {
        guard case .typedef(let label) = self else {
            return nil
        }
        switch innerType {
        case .bool, .int, .clock, .chan:
            return pre + "typedef " + innerType.typeStr + " " + label + ";"
        case .scalar(let count):
            return pre + "typedef scalar[\(count)] " + label + ";"
        case .typedef(let name):
            guard includeTypedef(name) else {
                return nil
            }
            return pre + "typedef " + name + " " + label + ";"
        case .record(_, let types):
            let variableDeclarations = types.compactMap {
                $1.variableDeclaration(label: $0, prefix: pre + "  ", includeTypedef: includeTypedef).map {
                    pre + $0
                }
            }.joined(separator: "\n")
            return pre + "typedef struct\n{\n" + variableDeclarations  + "\n" + pre + "} " + label + ";"
        case .array:
            return pre
                + "typedef "
                + innerType.typeStr
                + " "
                + label
                + innerType.arrayCounts.map { "[\($0)]" }.joined()
                + ";"
        }
    }

}
