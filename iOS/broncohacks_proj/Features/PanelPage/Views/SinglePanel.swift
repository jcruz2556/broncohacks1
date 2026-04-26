import SwiftUI

struct SinglePanel: View {
    // MARK: Data owned by me
    @State private var glowing = false
    
    // MARK: Data shared with me
    var isOnline: Bool = true
    var panelColor: Color { isOnline ? .panelOnline : .panelOffline }
    var strokeColor: Color { isOnline ? .panelOnlineStroke : .panelOfflineStroke }
    var gridColor: Color { isOnline ? .panelOnlineGrid.opacity(0.8) : .panelOfflineGrid.opacity(0.8) }

    var body: some View {
        ZStack {
            // Base
            RoundedRectangle(cornerRadius: 6)
                .fill(panelColor)

            // Cell grid
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height

                // Grid lines
                Path { p in
                    p.move(to: CGPoint(x: 0, y: h / 2))
                    p.addLine(to: CGPoint(x: w, y: h / 2))
                    p.move(to: CGPoint(x: w / 2, y: 0))
                    p.addLine(to: CGPoint(x: w / 2, y: h))
                }
                .stroke(gridColor, lineWidth: 0.5)

                // Busbars (thin horizontal lines across each cell)
                Path { p in
                    for i in 1..<4 {
                        let y = h * CGFloat(i) / 4
                        p.move(to: CGPoint(x: 0, y: y))
                        p.addLine(to: CGPoint(x: w, y: y))
                    }
                }
                .stroke(gridColor.opacity(0.4), lineWidth: 0.3)

                // Top glare
                LinearGradient(
                    colors: [Color.white.opacity(0.18), Color.clear],
                    startPoint: .topLeading,
                    endPoint: UnitPoint(x: 0.6, y: 0.5)
                )
                .clipShape(RoundedRectangle(cornerRadius: 6))

                // Bottom reflection
                LinearGradient(
                    colors: [Color.clear, Color.black.opacity(0.15)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .clipShape(RoundedRectangle(cornerRadius: 6))
            }

            // Offline pulse overlay
            if !isOnline {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.red.opacity(glowing ? 0.18 : 0.0))
                    .animation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true), value: glowing)
            }

            // Border
            RoundedRectangle(cornerRadius: 6)
                .stroke(strokeColor, lineWidth: 0.5)
        }
        .aspectRatio(1.4, contentMode: .fit)
        .shadow(color: isOnline ? Color.green.opacity(glowing ? 0.3 : 0.1) : Color.red.opacity(0.2), radius: 6, x: 0, y: 2)
        .onAppear {
            if isOnline { glowing = true }
            else {
                withAnimation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true)) {
                    glowing = true
                }
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        HStack(spacing: 16) {
            SinglePanel(isOnline: true)
                .frame(width: 120)
            SinglePanel(isOnline: false)
                .frame(width: 120)
        }
        .padding()
    }
    .preferredColorScheme(.dark)
}
