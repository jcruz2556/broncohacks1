import Foundation

struct HomePageResponse: Codable {
    let houseId: Int
    let house: HouseResponse
    let panels: [PanelResponse]

    // computed from panels
    var totalOutputKW: Double {
        panels.map { $0.computed.outputW / 1000 }.reduce(0, +)
    }
    var onlinePanelCount: Int {
        panels.filter { $0.isOnline }.count
    }
    var coveragePct: Int {
        min(100, Int((totalOutputKW / 3.0) * 100))
    }
}

struct HouseResponse: Codable {
    let houseId: Int
    let userId: Int?
    let latitude: Double
    let longitude: Double
}

struct PanelResponse: Codable, Identifiable, Hashable {
    let id: Int  // decoded from "panel_id"
    let houseId: Int
    let panelOutputW: Double
    let isOnline: Bool
    let computed: ComputedPanel

    // CodingKeys because "panel_id" → "id"
    enum CodingKeys: String, CodingKey {
        case id = "panelId"
        case houseId
        case panelOutputW
        case isOnline
        case computed
    }

    var name: String { "Panel #\(id)" }
    var location: String { "Rooftop · Panel \(id)" }
    var outputKW: Double { computed.outputW / 1000 }
    var efficiencyPct: Int { Int(computed.efficiencyPercentage) }

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: PanelResponse, rhs: PanelResponse) -> Bool { lhs.id == rhs.id }
}

struct ComputedPanel: Codable {
    let outputW: Double
    let efficiencyPercentage: Double
}

extension HomePageResponse {
    func toHouseStatus() -> HouseStatus {
        let house = House(
            id: self.house.houseId,
            userId: self.house.userId ?? 0,
            name: "My House",
            latitude: self.house.latitude,
            longitude: self.house.longitude,
            createdAt: .now
        )

        let panels = self.panels.map { p in
            Panel(
                id: p.id,
                houseId: p.houseId,
                maxOutputW: p.panelOutputW,
                createdAt: .now,
                isOnlineOverride: p.isOnline,
                outputWOverride: p.computed.outputW,
                efficiencyPctOverride: Int(p.computed.efficiencyPercentage),
                sensors: nil
            )
        }

        return HouseStatus(house: house, panels: panels)
    }
}
