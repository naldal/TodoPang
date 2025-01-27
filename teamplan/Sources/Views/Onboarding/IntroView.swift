//
//  IntroView.swift
//  teamplan
//
//  Created by sungyeon kim on 2023/02/18.
//

import SwiftUI
import KeychainSwift

enum MainViewState: Int {
    case login
    case signup
    case main
}

struct IntroView: View {
    @AppStorage("isOnboarding") var isOnboarding: Bool = true
    @AppStorage("mainViewState") var mainViewState: MainViewState = .login
    @StateObject var notificationViewModel = NotificationViewModel()
    @State private var hasCheckedLoginStatus = false
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    var body: some View {
        ZStack {
            if isOnboarding {
                OnboardingView()
                    .transition(.asymmetric(insertion: .move(edge: .top), removal: .move(edge: .bottom)))
            } else {
                switch mainViewState {
                case .login:
                    LoginView()
                        .environmentObject(notificationViewModel)
                        .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .top)))
                case .signup:
                    SignupView()
                        .environmentObject(notificationViewModel)
                        .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .top)))
                case .main:
                    MainTapView()
                        .environmentObject(notificationViewModel)
                        .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .top)))
                }
            }
        }
        .onAppear {
            checkLoginStatus()
        }
    }
}

struct IntroView_Previews: PreviewProvider {
    static var previews: some View {
        IntroView()
    }
}

extension IntroView {
    
    private func checkLoginStatus() {
        guard !hasCheckedLoginStatus else {
            return
        }
        
        let userDefaultManager = UserDefaultManager.loadWith(key: "user")
        let identifier = userDefaultManager?.identifier
        
        if let identifier = identifier, !identifier.isEmpty {
            self.mainViewState = .main
        } else {
            self.mainViewState = .login
        }
        
        hasCheckedLoginStatus = true
    }
}
