final class KripkeStatePropertyEncoding: Encoder, PropertyContainer {

    var codingPath: [CodingKey]

    var userInfo: [CodingUserInfoKey: Any]

    var container: PropertyContainer?

    var property: KripkeStateProperty? {
        container?.property
    }

    var value: Any?? {
        container?.value as Any??
    }

    init(codingPath: [CodingKey], userInfo: [CodingUserInfoKey: Any]) {
        self.codingPath = codingPath
        self.userInfo = userInfo
    }

    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key: CodingKey {
        let container = KripkeStatePropertyKeyedEncodingContainer<Key>(codingPath: codingPath)
        self.container = container
        return KeyedEncodingContainer(container)
    }

    func unkeyedContainer() -> UnkeyedEncodingContainer {
        let container = KripkeStatePropertyUnkeyedEncodingContainer(codingPath: codingPath)
        self.container = container
        return container
    }

    func singleValueContainer() -> SingleValueEncodingContainer {
        let container = KripkeStatePropertySingleValueEncodingContainer(codingPath: codingPath)
        self.container = container
        return container
    }

}
