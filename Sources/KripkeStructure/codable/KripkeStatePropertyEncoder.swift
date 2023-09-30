public struct KripkeStatePropertyEncoder {

    private let codingPath: [CodingKey]

    public init() {
        self.init(codingPath: [])
    }

    init(codingPath: [CodingKey]) {
        self.codingPath = codingPath
    }

    public func encode<T>(_ value: T) throws -> KripkeStateProperty where T: Encodable {
        let encoding = KripkeStatePropertyEncoding(codingPath: codingPath, userInfo: [:])
        try value.encode(to: encoding)
        return encoding.container?.property ?? KripkeStateProperty(
            type: .Compound([:]),
            value: [String: Any?]()
        )
    }

}
