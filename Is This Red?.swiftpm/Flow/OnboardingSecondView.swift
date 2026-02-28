//
//  OnboardingSecondView.swift
//  Swift-Student-Challenge
//
//  Created by 이은지 on 2/23/26.
//

import SwiftUI

struct OnboardingSecondView: View {
    @Binding var didFinish: Bool

    private let lines: [String] = [
        "Were Those Real Red?",
        "They were all Red.",
        "The color you see isn’t the color everyone sees.",
        "Start Experience"
    ]

    @State private var revealedCount = 1

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 18) {
                ForEach(0..<revealedCount, id: \.self) { index in
                    Text(lines[index])
                        .font(
                            .system(
                                size: index == lines.count - 1 ? 24 : 22,
                                weight: index == lines.count - 1 ? .bold : .semibold
                            )
                        )
                        .foregroundStyle(.white)
                        .transition(.opacity)
                }
            }
            .padding(.horizontal, 28)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            handleTap()
        }
    }

    private func handleTap() {
        if revealedCount < lines.count {
            withAnimation(.easeInOut(duration: 0.25)) {
                revealedCount += 1
            }
        } else {
            withAnimation(.easeInOut(duration: 0.35)) {
                didFinish = true
            }
        }
    }
}
