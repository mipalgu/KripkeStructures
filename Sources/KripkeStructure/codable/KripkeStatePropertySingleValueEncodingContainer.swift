final class KripkeStatePropertySingleValueEncodingContainer: SingleValueEncodingContainer, PropertyContainer {

    private let encoder: KripkeStatePropertyEncoder

    var property: KripkeStateProperty?

    var value: Any??

    var codingPath: [CodingKey]

    init(codingPath: [CodingKey]) {
        self.codingPath = codingPath
        self.encoder = KripkeStatePropertyEncoder(codingPath: codingPath)
    }

    func encodeNil() throws {
        property = KripkeStateProperty(type: .Optional(nil), value: Optional<Int>.none as Any)
        value = .some(Optional<Int>.none as Any?)
    }

    func encode(_ value: Bool) throws {
        property = KripkeStateProperty(type: .Bool, value: value)
        self.value = .some(value as Any?)
    }

    func encode(_ value: String) throws {
        property = KripkeStateProperty(type: .String, value: value)
        self.value = .some(value as Any?)
    }

    func encode(_ value: Double) throws {
        property = KripkeStateProperty(type: .Double, value: value)
        self.value = .some(value as Any?)
    }

    func encode(_ value: Float) throws {
        property = KripkeStateProperty(type: .Float, value: value)
        self.value = .some(value as Any?)
    }

    func encode(_ value: Int) throws {
        property = KripkeStateProperty(type: .Int, value: value)
        self.value = .some(value as Any?)
    }

    func encode(_ value: Int8) throws {
        property = KripkeStateProperty(type: .Int8, value: value)
        self.value = .some(value as Any?)
    }

    func encode(_ value: Int16) throws {
        property = KripkeStateProperty(type: .Int16, value: value)
        self.value = .some(value as Any?)
    }

    func encode(_ value: Int32) throws {
        property = KripkeStateProperty(type: .Int32, value: value)
        self.value = .some(value as Any?)
    }

    func encode(_ value: Int64) throws {
        property = KripkeStateProperty(type: .Int64, value: value)
        self.value = .some(value as Any?)
    }

    func encode(_ value: UInt) throws {
        property = KripkeStateProperty(type: .UInt, value: value)
        self.value = .some(value as Any?)
    }

    func encode(_ value: UInt8) throws {
        property = KripkeStateProperty(type: .UInt8, value: value)
        self.value = .some(value as Any?)
    }

    func encode(_ value: UInt16) throws {
        property = KripkeStateProperty(type: .UInt16, value: value)
        self.value = .some(value as Any?)
    }

    func encode(_ value: UInt32) throws {
        property = KripkeStateProperty(type: .UInt32, value: value)
        self.value = .some(value as Any?)
    }

    func encode(_ value: UInt64) throws {
        property = KripkeStateProperty(type: .UInt64, value: value)
        self.value = .some(value as Any?)
    }

    func encode<T>(_ value: T) throws where T: Encodable {
        property = try encoder.encode(value)
        self.value = .some(value as Any?)
    }

}
