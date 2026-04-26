import Foundation

class PanelService {
    static let shared = PanelService()
    private let api = APIService.shared

    func getSensors(panelId: Int) async throws -> [SensorState] {
        let data = try await api.makeRequest(path: "/panel-readings/panel/\(panelId)/latest")
        print("RAW: \(String(data: data, encoding: .utf8) ?? "nil")")
        
        let response: SensorReadingResponse = try await api.get("/panel-readings/panel/\(panelId)/latest")
        let r = response.reading
        return [
            SensorState(id: 1, panelId: panelId, outputW: Double(1023 - r.ul), efficiencyPct: min(100, Int(Double(1023 - r.ul) / Double(1023) * 100)), isOnline: r.ul < 400, recordedAt: .now),
            SensorState(id: 2, panelId: panelId, outputW: Double(1023 - r.ur), efficiencyPct: min(100, Int(Double(1023 - r.ur) / Double(1023) * 100)), isOnline: r.ur < 400, recordedAt: .now),
            SensorState(id: 3, panelId: panelId, outputW: Double(1023 - r.ll), efficiencyPct: min(100, Int(Double(1023 - r.ll) / Double(1023) * 100)), isOnline: r.ll < 400, recordedAt: .now),
            SensorState(id: 4, panelId: panelId, outputW: Double(1023 - r.lr), efficiencyPct: min(100, Int(Double(1023 - r.lr) / Double(1023) * 100)), isOnline: r.lr < 400, recordedAt: .now),
        ]
    }
}

struct SensorReadingResponse: Codable {
    let panelId: Int
    let reading: SensorValues
}

struct SensorValues: Codable {
    let ul: Int
    let ur: Int
    let ll: Int
    let lr: Int

    enum CodingKeys: String, CodingKey {
        case ul = "UL"
        case ur = "UR"
        case ll = "LL"
        case lr = "LR"
    }
}
