import Foundation

struct User: Identifiable, Codable {
    let id: Int
    let email: String
    let name: String
    let createdAt: Date

    var firstName: String {
        name.components(separatedBy: " ").first ?? name
    }
}
