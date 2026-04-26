extension HouseStatus: Equatable {
    static func == (lhs: HouseStatus, rhs: HouseStatus) -> Bool {
        lhs.panels == rhs.panels
    }
}

extension Panel: Equatable {
    static func == (lhs: Panel, rhs: Panel) -> Bool {
        lhs.id == rhs.id &&
        lhs.isOnline == rhs.isOnline &&
        lhs.outputKW == rhs.outputKW &&
        lhs.efficiencyPct == rhs.efficiencyPct
    }
}
