final class KripkeStatePropertyUnkeyedDecodingContainer: UnkeyedDecodingContainer {

    var codingPath: [CodingKey]

    private let properties: [KripkeStateProperty]

    var currentIndex = 0

    var count: Int? {
        properties.count
    }

    var isAtEnd: Bool {
        currentIndex >= properties.count
    }

    convenience init(codingPath: [CodingKey], property: KripkeStateProperty) throws {
        guard case .Collection(let properties) = property.type else {
            guard property.type == .EmptyCollection else {
                // swiftlint:disable line_length
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(
                        codingPath: codingPath,
                        debugDescription: "Attempting to create nested unkeyed container for non-collection value \(property.value)"
                    )
                )
                // swiftlint:enable line_length
            }
            self.init(codingPath: codingPath, properties: [])
            return
        }
        self.init(codingPath: codingPath, properties: properties)
    }

    init(codingPath: [CodingKey], properties: [KripkeStateProperty]) {
        self.codingPath = codingPath
        self.properties = properties
    }

    private func performProperty<T>(
        _ action: (KripkeStateProperty) throws -> T
    ) throws -> T {
        guard currentIndex < properties.count else {
            throw DecodingError.dataCorruptedError(in: self, debugDescription: "Index out of bounds.")
        }
        let property = properties[currentIndex]
        currentIndex += 1
        return try action(property)
    }

    private func perform<T>(
        _ action: (KripkeStatePropertySingleValueDecodingContainer) throws -> T
    ) throws -> T {
        try performProperty {
            let decoder = KripkeStatePropertySingleValueDecodingContainer(
                codingPath: codingPath,
                property: $0
            )
            return try action(decoder)
        }
    }

    func decodeNil() throws -> Bool {
        try perform { $0.decodeNil() }
    }

    func decode(_ type: Bool.Type) throws -> Bool {
        try perform { try $0.decode(type) }
    }

    func decode(_ type: Double.Type) throws -> Double {
        try perform { try $0.decode(type) }
    }

    func decode(_ type: Float.Type) throws -> Float {
        try perform { try $0.decode(type) }
    }

    func decode(_ type: Int.Type) throws -> Int {
        try perform { try $0.decode(type) }
    }

    func decode(_ type: Int8.Type) throws -> Int8 {
        try perform { try $0.decode(type) }
    }

    func decode(_ type: Int16.Type) throws -> Int16 {
        try perform { try $0.decode(type) }
    }

    func decode(_ type: Int32.Type) throws -> Int32 {
        try perform { try $0.decode(type) }
    }

    func decode(_ type: Int64.Type) throws -> Int64 {
        try perform { try $0.decode(type) }
    }

    func decode(_ type: String.Type) throws -> String {
        try perform { try $0.decode(type) }
    }

    func decode(_ type: UInt.Type) throws -> UInt {
        try perform { try $0.decode(type) }
    }

    func decode(_ type: UInt8.Type) throws -> UInt8 {
        try perform { try $0.decode(type) }
    }

    func decode(_ type: UInt16.Type) throws -> UInt16 {
        try perform { try $0.decode(type) }
    }

    func decode(_ type: UInt32.Type) throws -> UInt32 {
        try perform { try $0.decode(type) }
    }

    func decode(_ type: UInt64.Type) throws -> UInt64 {
        try perform { try $0.decode(type) }
    }

    func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
        fatalError("nyi")
    }

    func nestedContainer<NestedKey>(
        keyedBy type: NestedKey.Type
    ) throws -> KeyedDecodingContainer<NestedKey> where NestedKey: CodingKey {
        fatalError("nyi")
    }

    func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        try performProperty { property in
            guard case .Collection(let properties) = property.type else {
                guard property.type == .EmptyCollection else {
                    // swiftlint:disable line_length
                    throw DecodingError.dataCorruptedError(
                        in: self,
                        debugDescription: "Attempting to create nested unkeyed container for non-collection value \(property.value)"
                    )
                    // swiftlint:enable line_length
                }
                let container = KripkeStatePropertyUnkeyedDecodingContainer(
                    codingPath: codingPath,
                    properties: []
                )
                return container
            }
            return KripkeStatePropertyUnkeyedDecodingContainer(codingPath: codingPath, properties: properties)
        }
    }

    func superDecoder() throws -> Decoder {
        fatalError("nyi")
    }

}
