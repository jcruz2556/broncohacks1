import Foundation

class HouseService {
    static let shared = HouseService()
    private let api = APIService.shared

    func getHouseStatus(houseId: Int) async throws -> HouseStatus {
        let response: HomePageResponse = try await api.get("/houses/\(houseId)/status")
        return response.toHouseStatus()
    }

    func getHouses() async throws -> [House] {
        try await api.get("/houses")
    }
}
