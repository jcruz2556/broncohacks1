// MARK: - MockData.swift

import Foundation

extension SensorState {
    static func mock(id: Int, panelId: Int, outputW: Double, isOnline: Bool = true) -> SensorState {
        SensorState(
            id: id,
            panelId: panelId,
            outputW: outputW,
            efficiencyPct: isOnline ? min(100, Int((outputW / 500) * 100)) : 0,
            isOnline: isOnline,
            recordedAt: .now
        )
    }
}

extension Panel {
    static let mock: [Panel] = [
        // Panel 1 — all healthy
        Panel(id: 1, houseId: 1, maxOutputW: 2000, createdAt: .now, sensors: [
            .mock(id: 1, panelId: 1, outputW: 420),
            .mock(id: 2,  panelId: 1, outputW: 0, isOnline: false),
            .mock(id: 3, panelId: 1, outputW: 410),
            .mock(id: 4, panelId: 1, outputW: 380)
        ]),
        // Panel 2 — one sensor offline
        Panel(id: 2, houseId: 1, maxOutputW: 2000, createdAt: .now, sensors: [
            .mock(id: 5,  panelId: 2, outputW: 300),
            .mock(id: 6,  panelId: 2, outputW: 280),
            .mock(id: 7,  panelId: 2, outputW: 0, isOnline: false),
            .mock(id: 8,  panelId: 2, outputW: 260)
        ]),
        // Panel 3 — degraded
        Panel(id: 3, houseId: 1, maxOutputW: 2000, createdAt: .now, sensors: [
            .mock(id: 9,  panelId: 3, outputW: 140),
            .mock(id: 10, panelId: 3, outputW: 120),
            .mock(id: 11, panelId: 3, outputW: 100),
            .mock(id: 12, panelId: 3, outputW: 90)
        ]),
        // Panel 4 — fully offline
        Panel(id: 4, houseId: 1, maxOutputW: 2000, createdAt: .now, sensors: [
            .mock(id: 13, panelId: 4, outputW: 0, isOnline: false),
            .mock(id: 14, panelId: 4, outputW: 0, isOnline: false),
            .mock(id: 15, panelId: 4, outputW: 0, isOnline: false),
            .mock(id: 16, panelId: 4, outputW: 0, isOnline: false)
        ])
    ]
}

extension House {
    static let mock = House(
        id: 1,
        userId: 1,
        name: "My House",
        latitude: 34.08,
        longitude: -117.56,
        createdAt: .now
    )
}

extension HouseStatus {
    static let mock = HouseStatus(house: .mock, panels: Panel.mock)
}

extension User {
    static let mock = User(
        id: 1,
        email: "ken@example.com",
        name: "Kenny",
        createdAt: .now
    )
}
