import Foundation

@Observable
class PanelViewModel {
    var panel: Panel
    var isLoading = false
    private var pollingTask: Task<Void, Never>?

    init(panel: Panel) {
        self.panel = panel
    }

    func loadSensors() async {
        isLoading = true
        do {
            let sensors = try await PanelService.shared.getSensors(panelId: panel.id)
            panel.sensors = sensors
        } catch {
            print("Failed to load sensors: \(error)")
        }
        isLoading = false
    }
    
    func startPolling() {
        pollingTask = Task {
            while !Task.isCancelled {
                await loadSensors()
                try? await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
            }
        }
    }

    func stopPolling() {
        pollingTask?.cancel()
        pollingTask = nil
    }
    
}
