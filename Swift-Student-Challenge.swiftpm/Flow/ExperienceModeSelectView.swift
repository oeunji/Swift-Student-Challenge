//
//  ExperienceModeSelectView.swift
//  Swift-Student-Challenge
//
//  Created by 이은지 on 2/25/26.
//

import SwiftUI

struct ExperienceModeSelectView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Spacer()

                Text("Is This Red?")
                    .font(.system(size: 96, weight: .heavy))
                    .foregroundColor(Color(red: 0.95, green: 0.24, blue: 0.22))

                Text("The color you see isn’t the color everyone sees.")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.black)

                Spacer()

                Text("Choose Your Experience")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.black.opacity(0.8))

                HStack(spacing: 16) {
                    modeButton(
                        title: "See Through Their Eyes",
                        subtitle: "Simulate how your drawing looks to them"
                    ) {
                        CreateView()
                    }

                    modeButton(
                        title: "Draw As Them",
                        subtitle: "Draw with color-vision limits"
                    ) {
                        ColorblindDrawView()
                    }
                }
                .padding(.horizontal, 32)

                Spacer()
                Spacer()
            }
        }
    }

    @ViewBuilder
    private func modeButton<Destination: View>(
        title: String,
        subtitle: String,
        destination: @escaping () -> Destination
    ) -> some View {
        NavigationLink(destination: destination()) {
            VStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
                Text(subtitle)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.black.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, minHeight: 56)
            .padding(.vertical, 6)
            .background(Color(.systemGray4))
            .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .buttonStyle(.plain)
    }
}
