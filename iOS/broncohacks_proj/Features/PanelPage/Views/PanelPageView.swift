import SwiftUI

struct PanelPageView: View {
    @State private var vm: PanelViewModel

    init(panel: Panel) {
        _vm = State(initialValue: PanelViewModel(panel: panel))
    }
    
    var body: some View {
        let _ = Self._printChanges()

        ScrollView {
            VStack(spacing: 22) {
                PanelHeroView(panel:vm.panel)

                PanelTodayOutputView(
                    totalKWh: vm.panel.outputKW * 6,
                    peakKW: vm.panel.outputKW,
                    outputData: [
                        (0, 0.0), (3, 0.0), (6, 0.3), (9, 1.4),
                        (12, 1.8), (15, 1.6)
                    ]
                )

                ControlsStatusView(panel:vm.panel)
            }
            .padding()
        }
        .scrollIndicators(.hidden)
        .background(Color.appBackground)
        .task {
            await vm.loadSensors()
            vm.startPolling()
        }
        .onDisappear{
            vm.stopPolling()
        }
    }
}

#Preview {
    NavigationStack {
        PanelPageView(panel: Panel.mock[0])
    }
    .preferredColorScheme(.dark)
}
