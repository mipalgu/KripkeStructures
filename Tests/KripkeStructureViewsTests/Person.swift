struct Person: Hashable, Codable, Sendable {

    var name: String

    var age: Int

    var friends: [Friend]

    var bestFriend: Friend?

    init(name: String, age: Int, friends: [Friend] = [], bestFriend: Friend? = nil) {
        self.name = name
        self.age = age
        self.friends = friends
        self.bestFriend = bestFriend
    }

    init(friend: Friend) {
        self.init(name: friend.name, age: friend.age)
    }

}

struct Friend: Hashable, Codable, Sendable {

    var name: String

    var age: Int

}
