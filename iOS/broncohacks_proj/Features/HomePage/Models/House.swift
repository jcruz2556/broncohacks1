import Foundation

struct House: Identifiable, Codable {
    let id: Int
    let userId: Int
    let name: String
    let latitude: Double
    let longitude: Double
    let createdAt: Date
}
