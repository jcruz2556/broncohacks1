import Foundation

struct SensorState: Identifiable, Codable, Hashable {
    let id: Int
    let panelId: Int
    let outputW: Double
    let efficiencyPct: Int
    let isOnline: Bool
    let recordedAt: Date

    var outputKW: Double { outputW / 1000 }
}
