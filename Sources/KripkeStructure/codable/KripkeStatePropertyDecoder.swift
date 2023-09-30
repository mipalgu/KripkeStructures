public final class KripkeStatePropertyDecoder {

    public init() {}

    public func decode<T>(_ type: T.Type, from property: KripkeStateProperty) throws -> T where T: Decodable {
        let decoder = KripkeStatePropertyDecoding(codingPath: [], userInfo: [:], property: property)
        return try T(from: decoder)
    }

    public func decode<T>(
        _ type: T.Type,
        from plist: KripkeStatePropertyList
    ) throws -> T where T: Decodable {
        let property = KripkeStateProperty(type: .Compound(plist), value: plist.properties.mapValues(\.value))
        return try self.decode(type, from: property)
    }

}
