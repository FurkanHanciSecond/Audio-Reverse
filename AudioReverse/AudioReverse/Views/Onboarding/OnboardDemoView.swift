//
//  OnboardDemoView.swift
//  AudioReverse
//
//  Created by Furkan Hanci on 3/30/26.
//

import SwiftUI

struct OnboardDemoView: View {
    @EnvironmentObject var onboardManager: OnboardingManager

    var body: some View {
        Text("Onboard Demo")
            .onTapGesture {
                onboardManager.nextScreen()
            }
    }
}

#Preview {
    OnboardDemoView()
}
