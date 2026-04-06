//
//  SettingsView.swift
//  AudioReverse
//
//  Created by Furkan Hanci on 3/30/26.
//

import SwiftUI
import RevenueCat
import SVProgressHUD
import MessageUI
import Combine

enum SettingsFullScreens: Identifiable {

    var id: UUID {
        UUID()
    }

    case paywall
}

struct SettingsView: View {
    @Environment(\.openURL) var openURL
    @State private var activeFullScreens: SettingsFullScreens?
    @Environment(UserDefaultsManager.self) private var userDefaultsManager
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black
                List {
                    if userDefaultsManager.isPremium == false {
                        Section {
                            ZStack {
                                Rectangle()
                                    .compatibleGlassEffect(cornerRadius: 20, interactiveEnabled: true)
                                    .foregroundStyle(.clear)
                                    .frame(width: UIScreen.main.bounds.size.width / 1.1, height: 100)

                                VStack {
                                    HStack {
                                        Text("Premium")
                                            .foregroundColor(.gray)
                                            .font(.system(size: 30 , weight: .bold))
                                        Spacer()
                                    }

                                    HStack {
                                        Text("Unlock All Features")
                                            .font(.system(size: 20 , weight: .medium))
                                            .opacity(0.7)
                                        Spacer()
                                    }
                                }
                                .padding(.leading , 30)
                            }
                        }
                        .clipped()
                        .onTapGesture {
                            if userDefaultsManager.isPremium == false {
                                activeFullScreens = .paywall
                            }
                        }
                        .listRowBackground(Color.clear)
                    }

                    Section {
                        HStack {
                            Image(systemName: "heart.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)

                            Text("Share Us")
                                .font(.system(size: 15 , weight: .medium))
                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .clipped()
                        .listRowBackground(Color.gray.opacity(0.15))
                        .onTapGesture {
                            OperationQueue.main.addOperation {
                                let shareActivity = UIActivityViewController(activityItems: [URL(string: "https://apps.apple.com/us/app/ai-roast-maker-generator/id6753349828")!], applicationActivities: nil)
                                let window = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController
                                if let vc = window {
                                    shareActivity.popoverPresentationController?.sourceView = vc.view
                                    shareActivity.popoverPresentationController?.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height, width: 0, height: 0)
                                    shareActivity.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
                                    vc.present(shareActivity, animated: true, completion: nil)
                                }
                            }
                        }

                        HStack {
                            Image(systemName: "star.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)

                            Text("Request Feature")
                                .font(.system(size: 15 , weight: .medium))

                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .clipped()
                        .listRowBackground(Color.gray.opacity(0.15))
                        .listRowSeparatorTint(.white.opacity(0.2), edges: .all)
                        .onTapGesture {
                            feedBackButtonTapped()
                        }

                    } header: {
                        Text("About Us")
                            .font(.system(size: 15 , weight: .semibold))
                    }
                    Section {
                        HStack {
                            Image(systemName: "envelope.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)

                            Text("Send Feedback")
                                .font(.system(size: 15 , weight: .medium))

                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .clipped()
                        .listRowBackground(Color.gray.opacity(0.15))
                        .listRowSeparatorTint(.white.opacity(0.2), edges: .all)
                        .onTapGesture {
                            feedBackButtonTapped()
                        }

                        HStack {
                            Image(systemName: "arrow.clockwise")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)

                            Text("Restore Purchases")
                                .font(.system(size: 15 , weight: .medium))

                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .clipped()
                        .listRowBackground(Color.gray.opacity(0.15))
                        .onTapGesture {
                            restorePurchases()
                        }

                    } header: {
                        Text("Support")
                            .font(.system(size: 15 , weight: .semibold))
                    }

                    Section {
                        HStack {
                            Image(systemName: "doc.plaintext")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)

                            Text("Privacy Policy")
                                .font(.system(size: 15 , weight: .medium))

                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .clipped()
                        .listRowBackground(Color.gray.opacity(0.15))
                        .listRowSeparatorTint(.white.opacity(0.2), edges: .all)
                        .onTapGesture {
                            openURL(URL(string: "https://docs.google.com/document/d/1ewWb5WXb7IHn9mfUIGDg3Uj8ebPihHD-HeYlyBM_pM4/edit?usp=sharing")!)
                        }

                        HStack {
                            Image(systemName: "doc.plaintext")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)

                            Text("Terms Of Use")
                                .font(.system(size: 15 , weight: .medium))

                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .clipped()
                        .listRowBackground(Color.gray.opacity(0.15))
                        .onTapGesture {
                            openURL(URL(string: "https://docs.google.com/document/d/1FT_5OKyz_F8mZn3-A-kluJKpGogjjp4_rS4UykqgY2I/edit?usp=sharing")!)
                        }

                    } header: {
                        Text("Others")
                            .font(.system(size: 15 , weight: .semibold))
                    }

                    if userDefaultsManager.isPremium == false {
                        Section {
                            if userDefaultsManager.remainingCount <= 0 {
                                Text("Remaining Count: 0")
                                    .font(.system(size: 15 , weight: .medium))
                            } else {
                                Text("Remaining Count: \(userDefaultsManager.remainingCount)")
                                    .font(.system(size: 15 , weight: .medium))
                            }
                        }
                        .listRowBackground(Color.gray.opacity(0.15))
                    }
                }
                .scrollContentBackground(.hidden)
                .listStyle(.insetGrouped)
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
            }
            .fullScreenCover(item: $activeFullScreens) { screen in
                switch screen {
                case .paywall:
                    PaywallView()
                }
            }
        }
    }

    private func createEmailUrl(to: String, subject: String, body: String) -> URL? {
        let subjectEncoded = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let bodyEncoded = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!

        let gmailUrl = URL(string: "googlegmail://co?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        let outlookUrl = URL(string: "ms-outlook://compose?to=\(to)&subject=\(subjectEncoded)")
        let yahooMail = URL(string: "ymail://mail/compose?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        let sparkUrl = URL(string: "readdle-spark://compose?recipient=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        let defaultUrl = URL(string: "mailto:\(to)?subject=\(subjectEncoded)&body=\(bodyEncoded)")

        if let gmailUrl = gmailUrl, UIApplication.shared.canOpenURL(gmailUrl) {
            return gmailUrl
        } else if let outlookUrl = outlookUrl, UIApplication.shared.canOpenURL(outlookUrl) {
            return outlookUrl
        } else if let yahooMail = yahooMail, UIApplication.shared.canOpenURL(yahooMail) {
            return yahooMail
        } else if let sparkUrl = sparkUrl, UIApplication.shared.canOpenURL(sparkUrl) {
            return sparkUrl
        }

        return defaultUrl
    }


    func feedBackButtonTapped() {
        let recipientEmail = "furkanhanci265@gmail.com"
        let subject = "About Audio Reverser App"
        let body = "USER ID: \(Purchases.shared.appUserID)"
        let composer = MFMailComposeViewController()
        composer.setToRecipients([recipientEmail])
        composer.setSubject(subject)
        composer.setMessageBody(body, isHTML: false)

        if let emailUrl = createEmailUrl(to: recipientEmail, subject: subject, body: body) {
            OperationQueue.main.addOperation {
                UIApplication.shared.open(emailUrl)
            }
        }
    }

    private func restorePurchases() {
        SVProgressHUD.show()

        Purchases.shared.restorePurchases { info, err in
            guard let info = info else { return }
            if info.activeSubscriptions.count > 0 {
                SVProgressHUD.dismiss()
                userDefaultsManager.isPremium = true
            } else {
                userDefaultsManager.isPremium = false
                SVProgressHUD.dismiss()
            }
        }
    }
}

