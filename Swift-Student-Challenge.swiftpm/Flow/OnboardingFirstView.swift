//
//  OnboardingFirstView.swift
//  Swift-Student-Challenge
//
//  Created by 이은지 on 2/23/26.
//

import SwiftUI

struct OnboardingFirstView: View {
    @Binding var didFinish: Bool

    private let backgrounds: [Color] = [
        Color(red: 1.0, green: 0.1843, blue: 0.1843),    // #FF2F2F
        Color(red: 0.7176, green: 0.7451, blue: 0.1569), // #B7BE28
        Color(red: 0.8392, green: 0.8588, blue: 0.1843), // #D6DB2F
        Color(red: 0.7176, green: 0.7451, blue: 0.1569), // #B7BE28
        Color(red: 1.0, green: 0.2275, blue: 0.1961)     // #FF3A32
    ]

    @State private var bgIndex: Int = 0

    var body: some View {
        ZStack {
            currentBackground
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.6), value: bgIndex)

            VStack(spacing: 28) {
                Spacer()

                // 중앙 반복 타이포
                VStack(spacing: 6) {
                    ForEach(0..<5, id: \.self) { i in
                        Text("Is This Red?")
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.9))
                            .shadow(radius: 10)
                            .opacity(opacityForLine(i))
                    }
                }
                .padding(.horizontal, 24)

                Spacer()

                // Yes/No 버튼
                HStack(spacing: 14) {
                    Button {
                        answerTapped(isYes: true)
                    } label: {
                        Text("Yes")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .frame(maxWidth: .infinity, minHeight: 54)
                    }
                    .buttonStyle(GlassButtonStyle())

                    Button {
                        answerTapped(isYes: false)
                    } label: {
                        Text("No")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .frame(maxWidth: .infinity, minHeight: 54)
                    }
                    .buttonStyle(GlassButtonStyle())
                }
                .padding(.horizontal, 22)
                .padding(.bottom, 34)
            }
        }
    }

    private var currentBackground: Color {
        backgrounds[bgIndex % backgrounds.count]
    }

    private func opacityForLine(_ i: Int) -> Double {
        // 위에서 아래로 약간 페이드
        let base = 0.95 - (Double(i) * 0.12)
        return max(0.35, base)
    }

    private func answerTapped(isYes: Bool) {
        let nextIndex = (bgIndex + 1) % backgrounds.count

        // 버튼 클릭 시 즉시 다음 배경으로
        withAnimation(.easeInOut(duration: 0.45)) {
            bgIndex = nextIndex
        }

        // 모든 배경을 순환했으면 다음 화면으로
        if nextIndex == 0 {
            withAnimation(.easeInOut(duration: 0.35)) {
                didFinish = true
            }
        }
    }
}

/// 유리(Glass) 느낌 버튼 스타일
struct GlassButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.white)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.white.opacity(configuration.isPressed ? 0.18 : 0.22))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(.white.opacity(0.35), lineWidth: 1)
                    )
                    .shadow(radius: configuration.isPressed ? 2 : 10)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
    }
}
