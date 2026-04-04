//
//  View+Ext.swift
//  AudioReverse
//
//  Created by Furkan Hanci on 4/4/26.
//

import SwiftUI

extension View {
    func fadeInSequenceAnimation(
        index: Int,
        showIndex: Int,
        animationDelay: Double,
        duration: Double
    ) -> some View {
        let hapticTriggerTime = Double(index) * animationDelay

        return self
            .opacity(showIndex >= index ? 1 : 0)
            .animation(
                .easeIn(duration: duration)
                    .delay(hapticTriggerTime),
                value: showIndex
            )
            .onChange(of: showIndex) { newValue, oldValue in
                if newValue >= index && !(showIndex >= index) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + hapticTriggerTime) {
                        UIImpactFeedbackGenerator().impactOccurred()
                    }
                }
            }
    }
}
