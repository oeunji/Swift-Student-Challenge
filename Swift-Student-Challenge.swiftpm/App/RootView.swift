//
//  RootView.swift
//  Swift-Student-Challenge
//
//  Created by 이은지 on 2/23/26.
//

import SwiftUI

struct RootView: View {
    @State private var didFinishFirst = false
    @State private var didFinishOnboarding = false

    var body: some View {
        if didFinishOnboarding {
            ExperienceModeSelectView()
        } else if didFinishFirst {
            OnboardingSecondView(didFinish: $didFinishOnboarding)
        } else {
            OnboardingFirstView(didFinish: $didFinishFirst)
        }
    }
}
