import SwiftUI

struct HomePageView: View {
    @State private var vm = HomeViewModel()

    var body: some View {
        let _ = Self._printChanges()

        NavigationStack {
            ScrollView {
                VStack(spacing: 22) {
                    HomeHeaderView()

                    if let data = vm.homeData {
                        HomeLiveSection(data: data)
                    } else {
                        ProgressView()
                            .tint(.orange)
                            .padding(.top, 40)
                    }
                }
                .padding()
            }
            .scrollIndicators(.hidden)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.appBackground)
            .task {
                await vm.load()
                vm.startPolling()
            }
            .onDisappear {
                vm.stopPolling()
            }
        }
    }
}

#Preview {
    HomePageView()
}
