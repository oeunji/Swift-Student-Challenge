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
                    .foregroundColor(Color(red: 0.1647, green: 0.0275, blue: 0.0275))

                Spacer()
                    .frame(height: 46)

                Text("Choose Your Experience")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(Color(red: 0.4275, green: 0.2706, blue: 0.2706))
                    .padding(.vertical, 10)

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
                .padding(.vertical, 10)

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
                    .foregroundColor(Color(red: 0.1647, green: 0.0275, blue: 0.0275))
                Text(subtitle)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color(red: 0.4275, green: 0.2706, blue: 0.2706))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(width: 400)
            .frame(minHeight: 64)
            .padding(.vertical, 6)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color(red: 1.0, green: 0.1843, blue: 0.1843),
                                Color(red: 0.7176, green: 0.7451, blue: 0.1569),
                                Color(red: 0.8392, green: 0.8588, blue: 0.1843),
                                Color(red: 0.7176, green: 0.7451, blue: 0.1569),
                                Color(red: 1.0, green: 0.2275, blue: 0.1961)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .shadow(color: .white.opacity(0.25), radius: 6, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}
