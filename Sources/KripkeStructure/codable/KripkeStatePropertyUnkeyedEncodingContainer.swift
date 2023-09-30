final class KripkeStatePropertyUnkeyedEncodingContainer: UnkeyedEncodingContainer, PropertyContainer {

    private let encoder: KripkeStatePropertyEncoder

    private let singleValueEncoder: KripkeStatePropertySingleValueEncodingContainer

    var codingPath: [CodingKey]

    var properties: [Int: KripkeStateProperty] = [:]

    var values: [Int: Any?] = [:]

    var subContainers: [Int: PropertyContainer] = [:]

    var property: KripkeStateProperty? {
        var props: [KripkeStateProperty] = []
        props.reserveCapacity(currentIndex)
        var propValues: [Any?] = []
        propValues.reserveCapacity(currentIndex)
        for index in 0..<currentIndex {
            if let prop = properties[index], let value = values[index] {
                props.append(prop)
                propValues.append(value)
            } else if
                let container = subContainers[index],
                let prop = container.property,
                let value: Any? = container.value {
                props.append(prop)
                propValues.append(value)
            } else {
                continue
            }
        }
        if props.isEmpty {
            return nil
        } else {
            return KripkeStateProperty(type: .Collection(props), value: propValues)
        }
    }

    var value: Any?? {
        var propValues: [Any?] = []
        propValues.reserveCapacity(currentIndex)
        for index in 0..<currentIndex {
            if let value = values[index] {
                propValues.append(value)
            } else if let container = subContainers[index], let value: Any? = container.value {
                propValues.append(value)
            } else {
                continue
            }
        }
        if propValues.isEmpty {
            return nil
        } else {
            return .some(propValues as Any?)
        }
    }

    private var currentIndex = 0

    private let superEncoding: KripkeStatePropertyEncoding

    var count: Int {
        currentIndex
    }

    init(codingPath: [CodingKey]) {
        self.codingPath = codingPath
        self.encoder = KripkeStatePropertyEncoder(codingPath: codingPath)
        self.singleValueEncoder = KripkeStatePropertySingleValueEncodingContainer(codingPath: codingPath)
        self.superEncoding = KripkeStatePropertyEncoding(codingPath: codingPath, userInfo: [:])
    }

    func encodeNil() throws {
        try singleValueEncoder.encodeNil()
        let index = currentIndex
        currentIndex += 1
        properties[index] = singleValueEncoder.property
        values[index] = Optional<Int>.none as Any
    }

    func encode(_ value: Bool) throws {
        try singleValueEncoder.encode(value)
        let index = currentIndex
        currentIndex += 1
        properties[index] = singleValueEncoder.property
        values[index] = value
    }

    func encode(_ value: String) throws {
        try singleValueEncoder.encode(value)
        let index = currentIndex
        currentIndex += 1
        properties[index] = singleValueEncoder.property
        values[index] = value
    }

    func encode(_ value: Double) throws {
        try singleValueEncoder.encode(value)
        let index = currentIndex
        currentIndex += 1
        properties[index] = singleValueEncoder.property
        values[index] = value
    }

    func encode(_ value: Float) throws {
        try singleValueEncoder.encode(value)
        let index = currentIndex
        currentIndex += 1
        properties[index] = singleValueEncoder.property
        values[index] = value
    }

    func encode(_ value: Int) throws {
        try singleValueEncoder.encode(value)
        let index = currentIndex
        currentIndex += 1
        properties[index] = singleValueEncoder.property
        values[index] = value
    }

    func encode(_ value: Int8) throws {
        try singleValueEncoder.encode(value)
        let index = currentIndex
        currentIndex += 1
        properties[index] = singleValueEncoder.property
        values[index] = value
    }

    func encode(_ value: Int16) throws {
        try singleValueEncoder.encode(value)
        let index = currentIndex
        currentIndex += 1
        properties[index] = singleValueEncoder.property
        values[index] = value
    }

    func encode(_ value: Int32) throws {
        try singleValueEncoder.encode(value)
        let index = currentIndex
        currentIndex += 1
        properties[index] = singleValueEncoder.property
        values[index] = value
    }

    func encode(_ value: Int64) throws {
        try singleValueEncoder.encode(value)
        let index = currentIndex
        currentIndex += 1
        properties[index] = singleValueEncoder.property
        values[index] = value
    }

    func encode(_ value: UInt) throws {
        try singleValueEncoder.encode(value)
        let index = currentIndex
        currentIndex += 1
        properties[index] = singleValueEncoder.property
        values[index] = value
    }

    func encode(_ value: UInt8) throws {
        try singleValueEncoder.encode(value)
        let index = currentIndex
        currentIndex += 1
        properties[index] = singleValueEncoder.property
        values[index] = value
    }

    func encode(_ value: UInt16) throws {
        try singleValueEncoder.encode(value)
        let index = currentIndex
        currentIndex += 1
        properties[index] = singleValueEncoder.property
        values[index] = value
    }

    func encode(_ value: UInt32) throws {
        try singleValueEncoder.encode(value)
        let index = currentIndex
        currentIndex += 1
        properties[index] = singleValueEncoder.property
        values[index] = value
    }

    func encode(_ value: UInt64) throws {
        try singleValueEncoder.encode(value)
        let index = currentIndex
        currentIndex += 1
        properties[index] = singleValueEncoder.property
        values[index] = value
    }

    func encode<T>(_ value: T) throws where T: Encodable {
        let property = try encoder.encode(value)
        let index = currentIndex
        currentIndex += 1
        properties[index] = property
        values[index] = value
    }

    func nestedContainer<NestedKey>(
        keyedBy keyType: NestedKey.Type
    ) -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {
        let container = KripkeStatePropertyKeyedEncodingContainer<NestedKey>(codingPath: codingPath)
        let index = currentIndex
        currentIndex += 1
        subContainers[index] = container
        return KeyedEncodingContainer(container)
    }

    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        let container = KripkeStatePropertyUnkeyedEncodingContainer(codingPath: codingPath)
        let index = currentIndex
        currentIndex += 1
        subContainers[index] = container
        return container
    }

    func superEncoder() -> Encoder {
        superEncoding
    }

}
