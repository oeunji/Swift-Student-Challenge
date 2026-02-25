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
                Text("Choose Your Experience")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .padding(.top, 24)

                modeCard(
                    title: "See Through Their Eyes",
                    subtitle: "Simulate how your drawing looks to them",
                    systemImage: "eye"
                ) {
                    CreateView()
                }

                modeCard(
                    title: "Draw As Them",
                    subtitle: "Draw with color-vision limits",
                    systemImage: "pencil.and.outline"
                ) {
                    ColorblindDrawView()
                }

                Spacer()
            }
            .padding(.horizontal, 20)
            .navigationTitle("Experience")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    @ViewBuilder
    private func modeCard<Destination: View>(
        title: String,
        subtitle: String,
        systemImage: String,
        destination: @escaping () -> Destination
    ) -> some View {
        NavigationLink(destination: destination()) {
            HStack(spacing: 16) {
                Image(systemName: systemImage)
                    .font(.system(size: 28, weight: .semibold))
                    .frame(width: 44, height: 44)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(.systemGray5), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
