//
//  SectionHeader.swift
//  broncohacks_proj
//
//  Created by Kenneth Sieu on 4/25/26.
//


import SwiftUI

struct SectionHeader: View {
    let title: String
    var actionLabel: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(Color.white.opacity(0.45))
                .kerning(1.4)
            Spacer()
            if let actionLabel, let action {
                Button(action: action) {
                    HStack(spacing: 3) {
                        Text(actionLabel)
                            .font(.system(size: 14, weight: .medium))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundStyle(.orange)
                }
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        VStack(spacing: 16) {
            SectionHeader(title: "MY PANELS")
            SectionHeader(title: "TODAY'S OUTPUT", actionLabel: "See all") {}
        }
    }
    .preferredColorScheme(.dark)
}
