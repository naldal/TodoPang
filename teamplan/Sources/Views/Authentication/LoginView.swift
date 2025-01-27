//
//  LoginView.swift
//  teamplan
//
//  Created by sungyeon kim on 2023/02/18.
//

import SwiftUI
import FirebaseAuth
import GoogleSignInSwift
import AuthenticationServices

enum LoginViewState {
    case login
    case toHome
    case toSignup
}

struct LoginView: View {
    
    private var signInViewModel = GoogleSignInButtonViewModel(scheme: .dark, style: .standard, state: .normal)
    
    @State private var showTermsView: Bool = false
    @State private var showHomeView: Bool = false
    @State private var showSignUpView: Bool = false
    @State private var isLoading: Bool = false
    @State private var isLogin: Bool = false
    @State private var showAlert = false
    
    @AppStorage("mainViewState") var mainViewState: MainViewState?
    
    @ObservedObject var vm = GoogleSignInButtonViewModel()
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    let transition: AnyTransition = .asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading))
    
    var body: some View {
        NavigationView {
            ZStack {
                loginView
                if self.isLoading {
                    LoadingView().zIndex(1)
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("로그인 실패"),
                    message: Text("로그인을 실패했습니다."),
                    dismissButton: .default(Text("확인"))
                )
            }
        }
    }
    
    
    private var loginView: some View {
        VStack {
            HStack {
                Image("loginView")
                    .padding(.trailing, 51)
                    .padding(.leading, 16)
            }
            Spacer()
                .frame(height: 100)
            self.buttons
        }
        .transition(transition)
        .zIndex(0)
    }
    
    private var buttons: some View {
        VStack(spacing: 18) {
            SignInWithAppleButton(
                onRequest: { request in
                    request.requestedScopes = [.fullName, .email]
                },
                onCompletion: { result in
                    switch result {
                    case .success(let authResults):
                        switch authResults.credential {
                        case let appleIDCredential as ASAuthorizationAppleIDCredential:
                            guard let appleIDToken = appleIDCredential.identityToken else {
                                print("Unable to fetch identity token")
                                return
                            }
                            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                                print("\(appleIDToken.debugDescription)")
                                return
                            }
                            self.authViewModel.signInApple(idToken: idTokenString)
                        default:
                            break
                        }
                    case .failure(let error):
                        print("Apple 로그인 실패: \(error.localizedDescription)")
                    }
                }
            )
            .onAppear(perform: {
                self.authViewModel.requestRandomNonce()
            })
            .onChange(of: self.authViewModel.appleLoginStatus) { appleLoginStatus in
                guard let status = appleLoginStatus else {
                    return
                }
                switch status {
                case .exist:
                    self.mainViewState = .main
                case .new:
                    self.mainViewState = .signup
                }
            }
            .padding(.horizontal)
            .frame(height: 48)
            .frame(maxWidth: .infinity)
            .foregroundColor(Gen.Colors.blackColor.swiftUIColor)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Gen.Colors.blackColor.swiftUIColor, lineWidth: 1)
            )
            
            GoogleSignInButton(viewModel: self.signInViewModel) {
                Task {
                    do {
                        self.isLoading = true
                        let user = try await authViewModel.signInGoogle()
                        
                        switch user.status {
                        case .exist:
                            if await authViewModel.tryLogin() {
                                self.isLoading = false
                                withAnimation(.spring()) {
                                    self.mainViewState = .main
                                }
                            } else {
                                self.isLoading = false
                                self.showAlert = true
                            }
                            
                        case .new:
                            self.isLoading = false
                            withAnimation(.spring()) {
                                self.mainViewState = .signup
                            }
                        }
                        
                    } catch {
                        print(error.localizedDescription)
                        self.isLoading = false
                    }
                }
            }
        }
        .padding(.horizontal, 55)
    }
    
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
