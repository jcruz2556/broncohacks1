import Foundation

struct Panel: Identifiable, Codable, Hashable {
    let id: Int
    let houseId: Int
    let maxOutputW: Double
    let createdAt: Date
    
    var isOnlineOverride: Bool?
    var outputWOverride: Double?
    var efficiencyPctOverride: Int?
    
    // From panel detail — individual sensors
    var sensors: [SensorState]?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var name: String { "Panel #\(id)" }
    
    var location: String { "Rooftop · Panel \(id)" }

    var isOnline: Bool {
        isOnlineOverride ?? sensors?.contains { $0.isOnline } ?? false
    }

    var outputKW: Double {
        if let override = outputWOverride { return override / 1000 }
        return sensors?.filter { $0.isOnline }.map { $0.outputW / 1000 }.reduce(0, +) ?? 0
    }


    var efficiencyPct: Int {
        if let override = efficiencyPctOverride { return override }
        let online = sensors?.filter { $0.isOnline } ?? []
        guard !online.isEmpty else { return 0 }
        return online.map { $0.efficiencyPct }.reduce(0, +) / online.count
    }

    var onlineSensorCount: Int {
        sensors?.filter { $0.isOnline }.count ?? (isOnline ? 1 : 0)
    }
    
}
