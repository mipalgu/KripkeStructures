final class KripkeStatePropertyKeyedDecodingContainer<Key>: KeyedDecodingContainerProtocol
where Key: CodingKey {

    var codingPath: [CodingKey]

    private let plist: KripkeStatePropertyList

    var allKeys: [Key] {
        plist.properties.keys.compactMap(Key.init)
    }

    init(codingPath: [CodingKey], plist: KripkeStatePropertyList) {
        self.codingPath = codingPath
        self.plist = plist
    }

    private func performProperty<T>(forKey key: Key, action: (KripkeStateProperty) throws -> T) throws -> T {
        guard let property = plist.properties[key.stringValue] else {
            throw DecodingError.keyNotFound(
                key,
                DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: "Key \(key.stringValue) not found int property list."
                )
            )
        }
        return try action(property)
    }

    private func perform<T>(
        forKey key: Key,
        action: (KripkeStatePropertySingleValueDecodingContainer) throws -> T
    ) throws -> T {
        try performProperty(forKey: key) { property in
            let decoder = KripkeStatePropertySingleValueDecodingContainer(
                codingPath: codingPath + [key],
                property: property
            )
            return try action(decoder)
        }
    }

    func contains(_ key: Key) -> Bool {
        plist.properties.keys.contains(key.stringValue)
    }

    func decodeNil(forKey key: Key) throws -> Bool {
        try perform(forKey: key) { $0.decodeNil() }
    }

    func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
        try perform(forKey: key) { try $0.decode(type) }
    }

    func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
        try perform(forKey: key) { try $0.decode(type) }
    }

    func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
        try perform(forKey: key) { try $0.decode(type) }
    }

    func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
        try perform(forKey: key) { try $0.decode(type) }
    }

    func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
        try perform(forKey: key) { try $0.decode(type) }
    }

    func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
        try perform(forKey: key) { try $0.decode(type) }
    }

    func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
        try perform(forKey: key) { try $0.decode(type) }
    }

    func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
        try perform(forKey: key) { try $0.decode(type) }
    }

    func decode(_ type: String.Type, forKey key: Key) throws -> String {
        try perform(forKey: key) { try $0.decode(type) }
    }

    func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
        try perform(forKey: key) { try $0.decode(type) }
    }

    func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
        try perform(forKey: key) { try $0.decode(type) }
    }

    func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
        try perform(forKey: key) { try $0.decode(type) }
    }

    func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
        try perform(forKey: key) { try $0.decode(type) }
    }

    func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
        try perform(forKey: key) { try $0.decode(type) }
    }

    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
        try perform(forKey: key) { try $0.decode(type) }
    }

    func nestedContainer<NestedKey>(
        keyedBy type: NestedKey.Type,
        forKey key: Key
    ) throws -> KeyedDecodingContainer<NestedKey> where NestedKey: CodingKey {
        try performProperty(forKey: key) { property in
            guard case .Compound(let plist) = property.type else {
                // swiftlint:disable line_length
                throw DecodingError.dataCorruptedError(
                    forKey: key,
                    in: self,
                    debugDescription: "Cannot convert property to compound property type when creating nested container."
                )
                // swiftlint:enable line_length
            }
            let container = KripkeStatePropertyKeyedDecodingContainer<NestedKey>(
                codingPath: codingPath + [key],
                plist: plist
            )
            return KeyedDecodingContainer(container)
        }
    }

    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        try performProperty(forKey: key) { property in
            guard case .Collection(let properties) = property.type else {
                guard property.type == .EmptyCollection else {
                    // swiftlint:disable line_length
                    throw DecodingError.dataCorruptedError(
                        forKey: key,
                        in: self,
                        debugDescription: "Attempting to create nested unkeyed container for non-collection value \(property.value)"
                    )
                    // swiftlint:enable line_length
                }
                let container = KripkeStatePropertyUnkeyedDecodingContainer(
                    codingPath: codingPath + [key],
                    properties: []
                )
                return container
            }
            return KripkeStatePropertyUnkeyedDecodingContainer(
                codingPath: codingPath + [key],
                properties: properties
            )
        }
    }

    func superDecoder() throws -> Decoder {
        fatalError("nyi")
    }

    func superDecoder(forKey key: Key) throws -> Decoder {
        fatalError("nyi")
    }

}
