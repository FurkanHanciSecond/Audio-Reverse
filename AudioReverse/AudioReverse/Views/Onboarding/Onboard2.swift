//
//  Onboard2.swift
//  AudioReverse
//
//  Created by Furkan Hanci on 3/30/26.
//

import SwiftUI

struct Onboard2: View {
    @EnvironmentObject var onboardManager: OnboardingManager

    var body: some View {
        Text("Onboard 2")
            .onTapGesture {
                onboardManager.nextScreen()
            }
    }
}

#Preview {
    Onboard2()
}
