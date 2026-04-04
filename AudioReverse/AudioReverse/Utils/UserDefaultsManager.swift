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

    var appRunCount: Int {
        get {
            access(keyPath: \.appRunCount)
            return UserDefaults.standard.integer(forKey: "appRunCount")
        }
        set {
            withMutation(keyPath: \.appRunCount) {
                UserDefaults.standard.set(newValue, forKey: "appRunCount")
            }
        }
    }


    func setupDefaultsIfNeeded() {
        if appRunCount == 0 {
            remainingCount = Self.defaultRemainingCount
        }
    }
}
