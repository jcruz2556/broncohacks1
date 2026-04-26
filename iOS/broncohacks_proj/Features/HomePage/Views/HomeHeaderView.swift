//
//  HomeHeaderView.swift
//  broncohacks_proj
//
//  Created by Kenneth Sieu on 4/26/26.
//

import SwiftUI

struct HomeHeaderView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("\(greetingText()), Kenny!")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)
                Spacer()
                AvatarView(label: "K")
            }
            Text(formattedDate())
                .font(.system(size: 13))
                .foregroundStyle(Color.white.opacity(0.4))
        }    }
}

#Preview {
    HomeHeaderView()
}
