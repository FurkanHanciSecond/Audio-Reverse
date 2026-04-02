//
//  GlassEffect+Ext.swift
//  AudioReverse
//
//  Created by Furkan Hanci on 3/30/26.
//

import SwiftUI

extension View {
    @ViewBuilder
    func compatibleGlassEffect(cornerRadius: CGFloat, interactiveEnabled: Bool) -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(.clear.interactive(interactiveEnabled), in: .rect(cornerRadius: cornerRadius))
        } else {
            self
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius))
        }
    }

    @ViewBuilder
    func compatibleGlassEffectCapsule(cornerRadius: CGFloat, interactiveEnabled: Bool) -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(.clear.interactive(interactiveEnabled), in: .capsule)
        } else {
            self
                .background(.ultraThinMaterial, in: .capsule)
        }
    }

    @ViewBuilder
    func compatibleGlassEffectRegular(cornerRadius: CGFloat, interactiveEnabled: Bool) -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(.regular.interactive(interactiveEnabled), in: .rect(cornerRadius: cornerRadius))
        } else {
            self
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius))
        }
    }

    @ViewBuilder
    func compatibleCircularGlassEffect(interactiveEnabled: Bool) -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(.clear.interactive(interactiveEnabled), in: .circle)
        } else {
            self
                .background(.thinMaterial, in: .circle)
        }
    }
}
