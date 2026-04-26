import Foundation

@Observable
class HomeViewModel {
    var homeData: HouseStatus? = nil
    var isLoading: Bool = false
    var error: String? = nil
    private var pollingTask: Task<Void, Never>?

    var useMock: Bool = false

    func load(houseId: Int = 1) async {
        isLoading = true
        error = nil

        do {
            if useMock {
                try await Task.sleep(nanoseconds: 500_000_000)
                homeData = .mock
            } else {
                let newData = try await HouseService.shared.getHouseStatus(houseId: houseId)
                if newData != homeData {
                    homeData = newData
                }
            }
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }
    
    func startPolling(houseId: Int = 1) {
        pollingTask = Task {
            while !Task.isCancelled {
                await load(houseId: houseId)
                try? await Task.sleep(nanoseconds: 3_000_000_000)
            }
        }
    }

    func stopPolling() {
        pollingTask?.cancel()
        pollingTask = nil
    }
    
}
