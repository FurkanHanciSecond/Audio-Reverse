//
//  OnboardPaywall.swift
//  AudioReverse
//
//  Created by Furkan Hanci on 3/30/26.
//

import SwiftUI
import RevenueCat
import SVProgressHUD

struct Feature: Identifiable {
    let id = UUID()
    let emoji: String
    let title: String
}

struct OnboardPaywall: View {

    @Environment(UserDefaultsManager.self) private var userDefaultsManager
    @Environment(OnboardingManager.self) var onboardManager
    @Environment(\.openURL) var openURL
    @State private var lifeTimePriceText = ""
    @State private var isMovingAround : Bool = false
    @State private var showIndex: Int = -1

    var features = [
        Feature(emoji: "⏪", title: String(localized: "Reverse Longer Audios")),
        Feature(emoji: "🔊", title: String(localized: "Sound Effects")),
        Feature(emoji: "♾️", title: String(localized: "Unlimited Usage")),
        Feature(emoji: "📤", title: String(localized: "Unlimited Sharing")),
    ]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 15) {
                Text("Unlock Everything")
                    .font(.system(size: 43, weight: .bold))
                    .minimumScaleFactor(0.8)

                Text("Unlimited Reverse Your Audios")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.gray)

                featuresView
                    .padding(.top, 15)

                HStack {
                    Text("Just For: \(lifeTimePriceText)")
                    Text("❤️")
                }
                .font(.system(size: 22, weight: .semibold))
                .padding(.top, 25)

                continueButtonView

                termsOfUseLabelsView
            }
            .onAppear(perform: {
                Purchases.shared.getOfferings { offer, err in
                    if let package = offer?.offering(identifier: "lifeTimeOffer")?.lifetime?.storeProduct {
                        lifeTimePriceText = package.localizedPriceString
                    }
                }
            })
        }
    }

    var featuresView: some View {
        VStack(spacing: 10) {
            ForEach(Array(features.enumerated()), id: \.1.id) { (index, feature) in
                HStack {
                    Text(feature.emoji)
                        .font(.system(size: 35))
                        .foregroundStyle(.white.opacity(0.8))
                        .padding(.trailing , 10)

                    Text(feature.title)
                        .font(.system(size: 25, weight: .semibold))
                        .foregroundStyle(.white)
                        .minimumScaleFactor(0.8)

                    Spacer()
                }
                .padding()
                .compatibleGlassEffect(cornerRadius: 16, interactiveEnabled: true)
                .padding(.horizontal, 20)
                .fadeInSequenceAnimation(index: index, showIndex: showIndex, animationDelay: 0.3, duration: 0.3)
            }
        }
        .padding(.top, 10)
        .onAppear {
            showIndex = features.count
        }
    }

    var continueButtonView: some View {
        Button(action: {
            UIImpactFeedbackGenerator().impactOccurred()
            fetchPackage { pack in
                purchasePackageLifeTime(package: pack)
            }
        }) {
            Text("Continue")
                .font(.system(size: 25))
                .foregroundStyle(.white)
                .fontWeight(.bold)
                .frame(width: UIScreen.main.bounds.size.width / 1.15, height: 70)
                .padding(.vertical, 15)
                .background(
                    ZStack {
                        RoundedRectangle (cornerRadius: 25)
                            .frame(width: UIScreen.main.bounds.size.width / 1.15, height: 70)
                            .foregroundStyle(Color.gray.opacity(0.35).gradient)
                        RoundedRectangle(cornerRadius: 25)
                            .strokeBorder(style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round, dash: [40,400], dashPhase: isMovingAround ? 220 : -220))
                            .frame(width: UIScreen.main.bounds.size.width / 1.15, height: 70)
                            .foregroundStyle(LinearGradient(colors: [.gray, .white, .gray.opacity(0.6), .white.opacity(0.8), .gray, .white, .gray], startPoint: .trailing, endPoint: .leading))
                    }
                        .onAppear {
                            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                                isMovingAround = true
                            }
                        }
                )
        }
    }

    var termsOfUseLabelsView: some View {
        HStack {
            Text("Terms Of Use")
                .foregroundColor(.gray)
                .font(.system(size: 12))
                .onTapGesture {
                    openURL(URL(string: "https://docs.google.com/document/d/1FT_5OKyz_F8mZn3-A-kluJKpGogjjp4_rS4UykqgY2I/edit?usp=sharing")!)
                }

            Text("Restore Purchases")
                .foregroundStyle(.gray)
                .font(.system(size: 12))
                .onTapGesture {
                    restorePurchases()
                }

            Text("Privacy Policy")
                .foregroundColor(.gray)
                .font(.system(size: 12))
                .onTapGesture {
                    openURL(URL(string: "https://docs.google.com/document/d/1ewWb5WXb7IHn9mfUIGDg3Uj8ebPihHD-HeYlyBM_pM4/edit?usp=sharing")!)
                }

            Text("not now")
                .foregroundColor(.gray)
                .font(.system(size: 12))
                .onTapGesture {
                    onboardManager.completeOnboarding()
                }
        }
        .opacity(0.5)
        .multilineTextAlignment(.center)
        .padding(.horizontal , 10)
    }

    private func purchasePackageLifeTime(package:Package?){
        SVProgressHUD.show()
        if (package != nil){
            Purchases.shared.purchase(package: package!) { (transaction, customerInfo, error, userCancelled) in
                if customerInfo?.entitlements["audioReverseLifeTime"]?.isActive == true {
                    userDefaultsManager.isPremium = true
                    onboardManager.completeOnboarding()
                    SVProgressHUD.dismiss()
                } else {
                    SVProgressHUD.dismiss()
                }
            }
        } else {
            SVProgressHUD.dismiss()
        }
    }

    private func fetchPackage(completion: @escaping (Package) -> Void) {
        Purchases.shared.getOfferings { offerings, err in
            guard let offerings = offerings , err == nil else { return }
            guard let packages = offerings["lifeTimeOffer"]?.lifetime else { return }
            completion(packages)
        }
    }

    private func restorePurchases() {
        SVProgressHUD.show()
        Purchases.shared.restorePurchases { info, err in
            guard let info = info else { return }
            if info.entitlements["audioReverseLifeTime"]?.isActive == true {
                SVProgressHUD.dismiss()
                userDefaultsManager.isPremium = true
                onboardManager.completeOnboarding()
            } else {
                userDefaultsManager.isPremium = false
                SVProgressHUD.dismiss()
            }
        }
    }
}
