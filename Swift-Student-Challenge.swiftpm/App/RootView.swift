//
//  RootView.swift
//  Swift-Student-Challenge
//
//  Created by 이은지 on 2/23/26.
//

import SwiftUI

/// 앱 시작 시 Onboarding → (완료 후) 기존 ContentView로 이동
struct RootView: View {
    @State private var didFinishFirst = false
    @State private var didFinishOnboarding = false

    var body: some View {
        if didFinishOnboarding {
            CreateView()
        } else if didFinishFirst {
            OnboardingSecondView(didFinish: $didFinishOnboarding)
        } else {
            OnboardingFirstView(didFinish: $didFinishFirst)
        }
    }
}
