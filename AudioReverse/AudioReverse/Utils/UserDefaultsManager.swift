//
//  UserDefaultsManager.swift
//  AudioReverse
//
//  Created by Furkan Hanci on 4/2/26.
//

import SwiftUI
import Observation

@MainActor @Observable
class UserDefaultsManager {

    private static let defaultRemainingCount = 3

    var isPremium: Bool {
        get {
            access(keyPath: \.isPremium)
            return UserDefaults.standard.bool(forKey: "isPremium")
        }
        set {
            withMutation(keyPath: \.isPremium) {
                UserDefaults.standard.set(newValue, forKey: "isPremium")
            }
        }
    }

    var remainingCount: Int {
        get {
            access(keyPath: \.remainingCount)
            return UserDefaults.standard.integer(forKey: "remainingCount")
        }
        set {
            withMutation(keyPath: \.remainingCount) {
                UserDefaults.standard.set(newValue, forKey: "remainingCount")
            }
        }
    }


    func setupDefaultsIfNeeded() {
        if !UserDefaults.standard.bool(forKey: "hasLaunchedBefore") {
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
            remainingCount = Self.defaultRemainingCount
        }
    }
}
