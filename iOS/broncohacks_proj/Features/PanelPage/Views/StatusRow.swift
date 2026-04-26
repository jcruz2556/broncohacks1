//
//  StatusRow.swift
//  broncohacks_proj
//
//  Created by Kenneth Sieu on 4/25/26.
//

import SwiftUI

struct StatusRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let value: String?
    let valueColor: Color
    
    let showProgress: Bool
    var progress: Double = 0.77

    var body: some View {
        HStack(spacing: 14) {
            // Icon badge
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(iconColor.opacity(0.18))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(iconColor)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.white)
                if showProgress {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 3)
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.orange)
                                .frame(width: geo.size.width * progress, height: 3)
                        }
                    }
                    .frame(height: 3)
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundStyle(Color.white.opacity(0.4))
                } else {
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundStyle(Color.white.opacity(0.4))
                }
            }

            Spacer()

            // Value + chevron
            if let value {
                HStack(spacing: 4) {
                    Text(value)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(valueColor)
                }
            }
        }
    }
}


#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        StatusRow(
            icon: "bolt.fill",
            iconColor: .orange,
            title: "Energy generated",
            subtitle: "18.6 kWh — 77% of target",
            value: nil,
            valueColor: .white,
            showProgress: true
        )
    }
    .preferredColorScheme(.dark)
}
