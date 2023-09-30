final class KripkeStatePropertyKeyedEncodingContainer<Key>: KeyedEncodingContainerProtocol, PropertyContainer
where Key: CodingKey {

    private let encoder: KripkeStatePropertyEncoder

    private var singleValueEncoder: KripkeStatePropertySingleValueEncodingContainer

    var codingPath: [CodingKey]

    var plist: [String: KripkeStateProperty] = [:]

    var values: [String: Any?] = [:]

    var property: KripkeStateProperty? {
        var plist: [String: KripkeStateProperty] = self.plist
        var values: [String: Any?] = self.values
        plist.reserveCapacity(subContainers.count + plist.count)
        values.reserveCapacity(subContainers.count + values.count)
        for (key, container) in subContainers.merging(subEncodings, uniquingKeysWith: { $1 }) {
            guard let property = container.property, let value: Any? = container.value else {
                continue
            }
            plist[key] = property
            values[key] = value
        }
        if plist.isEmpty {
            return nil
        } else {
            return KripkeStateProperty(type: .Compound(KripkeStatePropertyList(plist)), value: values)
        }
    }

    var value: Any?? {
        var values: [String: Any?] = self.values
        values.reserveCapacity(subContainers.count + values.count)
        for (key, container) in subContainers.merging(subEncodings, uniquingKeysWith: { $1 }) {
            guard let value: Any? = container.value else {
                continue
            }
            values[key] = value
        }
        if values.isEmpty {
            return nil
        } else {
            return .some(values as Any?)
        }
    }

    var subContainers: [String: PropertyContainer] = [:]

    var subEncodings: [String: PropertyContainer] = [:]

    var superEncoding: KripkeStatePropertyEncoding

    init(codingPath: [CodingKey]) {
        self.codingPath = codingPath
        self.encoder = KripkeStatePropertyEncoder(codingPath: codingPath)
        self.singleValueEncoder = KripkeStatePropertySingleValueEncodingContainer(codingPath: codingPath)
        self.superEncoding = KripkeStatePropertyEncoding(codingPath: codingPath, userInfo: [:])
    }

    func encodeNil(forKey key: Key) throws {
        try singleValueEncoder.encodeNil()
        plist[key.stringValue] = singleValueEncoder.property
        values[key.stringValue] = Optional<Int>.none as Any
    }

    func encode(_ value: Bool, forKey key: Key) throws {
        try singleValueEncoder.encode(value)
        plist[key.stringValue] = singleValueEncoder.property
        values[key.stringValue] = value
    }

    func encode(_ value: String, forKey key: Key) throws {
        try singleValueEncoder.encode(value)
        plist[key.stringValue] = singleValueEncoder.property
        values[key.stringValue] = value
    }

    func encode(_ value: Double, forKey key: Key) throws {
        try singleValueEncoder.encode(value)
        plist[key.stringValue] = singleValueEncoder.property
        values[key.stringValue] = value
    }

    func encode(_ value: Float, forKey key: Key) throws {
        try singleValueEncoder.encode(value)
        plist[key.stringValue] = singleValueEncoder.property
        values[key.stringValue] = value
    }

    func encode(_ value: Int, forKey key: Key) throws {
        try singleValueEncoder.encode(value)
        plist[key.stringValue] = singleValueEncoder.property
        values[key.stringValue] = value
    }

    func encode(_ value: Int8, forKey key: Key) throws {
        try singleValueEncoder.encode(value)
        plist[key.stringValue] = singleValueEncoder.property
        values[key.stringValue] = value
    }

    func encode(_ value: Int16, forKey key: Key) throws {
        try singleValueEncoder.encode(value)
        plist[key.stringValue] = singleValueEncoder.property
        values[key.stringValue] = value
    }

    func encode(_ value: Int32, forKey key: Key) throws {
        try singleValueEncoder.encode(value)
        plist[key.stringValue] = singleValueEncoder.property
        values[key.stringValue] = value
    }

    func encode(_ value: Int64, forKey key: Key) throws {
        try singleValueEncoder.encode(value)
        plist[key.stringValue] = singleValueEncoder.property
        values[key.stringValue] = value
    }

    func encode(_ value: UInt, forKey key: Key) throws {
        try singleValueEncoder.encode(value)
        plist[key.stringValue] = singleValueEncoder.property
        values[key.stringValue] = value
    }

    func encode(_ value: UInt8, forKey key: Key) throws {
        try singleValueEncoder.encode(value)
        plist[key.stringValue] = singleValueEncoder.property
        values[key.stringValue] = value
    }

    func encode(_ value: UInt16, forKey key: Key) throws {
        try singleValueEncoder.encode(value)
        plist[key.stringValue] = singleValueEncoder.property
        values[key.stringValue] = value
    }

    func encode(_ value: UInt32, forKey key: Key) throws {
        try singleValueEncoder.encode(value)
        plist[key.stringValue] = singleValueEncoder.property
        values[key.stringValue] = value
    }

    func encode(_ value: UInt64, forKey key: Key) throws {
        try singleValueEncoder.encode(value)
        plist[key.stringValue] = singleValueEncoder.property
        values[key.stringValue] = value
    }

    func encode<T>(_ value: T, forKey key: Key) throws where T: Encodable {
        plist[key.stringValue] = try encoder.encode(value)
        values[key.stringValue] = value
    }

    func nestedContainer<NestedKey>(
        keyedBy keyType: NestedKey.Type,
        forKey key: Key
    )-> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {
        let container = KripkeStatePropertyKeyedEncodingContainer<NestedKey>(codingPath: codingPath + [key])
        subContainers[key.stringValue] = container
        return KeyedEncodingContainer(container)
    }

    func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        let container = KripkeStatePropertyUnkeyedEncodingContainer(codingPath: codingPath + [key])
        subContainers[key.stringValue] = container
        return container
    }

    func superEncoder() -> Encoder {
        return superEncoding
    }

    func superEncoder(forKey key: Key) -> Encoder {
        let container = KripkeStatePropertyEncoding(
            codingPath: codingPath + [key],
            userInfo: [:]
        )
        subEncodings[key.stringValue] = container
        return container
    }

}
