final class KripkeStatePropertyDecoding: Decoder {

    var codingPath: [CodingKey]

    var userInfo: [CodingUserInfoKey: Any]

    var property: KripkeStateProperty

    init(codingPath: [CodingKey], userInfo: [CodingUserInfoKey: Any], property: KripkeStateProperty) {
        self.codingPath = codingPath
        self.userInfo = userInfo
        self.property = property
    }

    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key: CodingKey {
        let container = try KripkeStatePropertyKeyedDecodingContainer<Key>(
            codingPath: codingPath,
            property: property
        )
        return KeyedDecodingContainer(container)
    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        try KripkeStatePropertyUnkeyedDecodingContainer(codingPath: codingPath, property: property)
    }

    func singleValueContainer() throws -> SingleValueDecodingContainer {
        KripkeStatePropertySingleValueDecodingContainer(codingPath: codingPath, property: property)
    }

}
