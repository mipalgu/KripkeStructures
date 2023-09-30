final class KripkeStatePropertySingleValueDecodingContainer: SingleValueDecodingContainer {

    let codingPath: [CodingKey]

    let property: KripkeStateProperty

    init(codingPath: [CodingKey], property: KripkeStateProperty) {
        self.codingPath = codingPath
        self.property = property
    }

    func decodeNil() -> Bool {
        guard case .Optional(let value) = property.type, value == nil else {
            return false
        }
        return true
    }

    func decode(_ type: Bool.Type) throws -> Bool {
        guard case .Bool = property.type, let value = property.value as? Bool else {
            throw DecodingError.typeMismatch(
                Bool.self,
                DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: "Cannot decode value of type Bool for value \(property.value)."
                )
            )
        }
        return value
    }

    func decode(_ type: Double.Type) throws -> Double {
        guard case .Double = property.type, let value = property.value as? Double else {
            throw DecodingError.typeMismatch(
                Double.self,
                DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: "Cannot decode value of type Double for value \(property.value)."
                )
            )
        }
        return value
    }

    func decode(_ type: Float.Type) throws -> Float {
        guard case .Float = property.type, let value = property.value as? Float else {
            throw DecodingError.typeMismatch(
                Float.self,
                DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: "Cannot decode value of type Float for value \(property.value)."
                )
            )
        }
        return value
    }

    func decode(_ type: Int.Type) throws -> Int {
        guard case .Int = property.type, let value = property.value as? Int else {
            throw DecodingError.typeMismatch(
                Int.self,
                DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: "Cannot decode value of type Int for value \(property.value)."
                )
            )
        }
        return value
    }

    func decode(_ type: Int8.Type) throws -> Int8 {
        guard case .Int8 = property.type, let value = property.value as? Int8 else {
            throw DecodingError.typeMismatch(
                Int8.self,
                DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: "Cannot decode value of type Int8 for value \(property.value)."
                )
            )
        }
        return value
    }

    func decode(_ type: Int16.Type) throws -> Int16 {
        guard case .Int16 = property.type, let value = property.value as? Int16 else {
            throw DecodingError.typeMismatch(
                Int16.self,
                DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: "Cannot decode value of type Int16 for value \(property.value)."
                )
            )
        }
        return value
    }

    func decode(_ type: Int32.Type) throws -> Int32 {
        guard case .Int32 = property.type, let value = property.value as? Int32 else {
            throw DecodingError.typeMismatch(
                Int32.self,
                DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: "Cannot decode value of type Int32 for value \(property.value)."
                )
            )
        }
        return value
    }

    func decode(_ type: Int64.Type) throws -> Int64 {
        guard case .Int = property.type, let value = property.value as? Int64 else {
            throw DecodingError.typeMismatch(
                Int64.self,
                DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: "Cannot decode value of type Int64 for value \(property.value)."
                )
            )
        }
        return value
    }

    func decode(_ type: String.Type) throws -> String {
        guard case .String = property.type, let value = property.value as? String else {
            throw DecodingError.typeMismatch(
                String.self,
                DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: "Cannot decode value of type String for value \(property.value)."
                )
            )
        }
        return value
    }

    func decode(_ type: UInt.Type) throws -> UInt {
        guard case .UInt = property.type, let value = property.value as? UInt else {
            throw DecodingError.typeMismatch(
                UInt.self,
                DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: "Cannot decode value of type UInt for value \(property.value)."
                )
            )
        }
        return value
    }

    func decode(_ type: UInt8.Type) throws -> UInt8 {
        guard case .UInt8 = property.type, let value = property.value as? UInt8 else {
            throw DecodingError.typeMismatch(
                UInt8.self,
                DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: "Cannot decode value of type UInt8 for value \(property.value)."
                )
            )
        }
        return value
    }

    func decode(_ type: UInt16.Type) throws -> UInt16 {
        guard case .UInt16 = property.type, let value = property.value as? UInt16 else {
            throw DecodingError.typeMismatch(
                UInt16.self,
                DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: "Cannot decode value of type UInt16 for value \(property.value)."
                )
            )
        }
        return value
    }

    func decode(_ type: UInt32.Type) throws -> UInt32 {
        guard case .UInt32 = property.type, let value = property.value as? UInt32 else {
            throw DecodingError.typeMismatch(
                UInt32.self,
                DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: "Cannot decode value of type UInt32 for value \(property.value)."
                )
            )
        }
        return value
    }

    func decode(_ type: UInt64.Type) throws -> UInt64 {
        guard case .UInt64 = property.type, let value = property.value as? UInt64 else {
            throw DecodingError.typeMismatch(
                UInt64.self,
                DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: "Cannot decode value of type UInt64 for value \(property.value)."
                )
            )
        }
        return value
    }

    func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
        fatalError("nyi")
    }

}
