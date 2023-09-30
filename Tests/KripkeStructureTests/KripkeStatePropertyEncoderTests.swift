import KripkeStructure
import XCTest

final class RawBytesEncoderTests: XCTestCase {

    struct Person: Codable {

        struct Friend: Codable {

            var friendsName: String

        }

        var firstName: String

        var lastName: String

        var friends: [Friend]

    }

    func testPersonEncodesCorrectly() throws {
        let encoder = KripkeStatePropertyEncoder()
        let person = Person(
            firstName: "Bob",
            lastName: "Smith",
            friends: [
                Person.Friend(friendsName: "Steve")
            ]
        )
        let property = try encoder.encode(person)
        let expected = KripkeStateProperty(
            type: .Compound(KripkeStatePropertyList([
                "firstName": KripkeStateProperty(type: .String, value: "Bob"),
                "lastName": KripkeStateProperty(type: .String, value: "Smith"),
                "friends": KripkeStateProperty(
                    type: .Collection([
                        KripkeStateProperty(
                            type: .Compound(KripkeStatePropertyList([
                                "friendsName": KripkeStateProperty(type: .String, value: "Steve")
                            ])),
                            value: Person.Friend(friendsName: "Steve")
                        )
                    ]),
                    value: [Person.Friend(friendsName: "Steve")]
                )
            ])),
            value: person
        )
        XCTAssertEqual(expected, property)
    }

}
