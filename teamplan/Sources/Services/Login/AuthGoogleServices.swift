//
//  AuthGoogleServices.swift
//  teamplan
//
//  Created by 주찬혁 on 2023/09/06.
//  Copyright © 2023 team1os. All rights reserved.
//

import Foundation
import GoogleSignIn
import FirebaseAuth
import KeychainSwift

final class AuthGoogleService {
    
    
    // MARK: - private properties
    
    private let util = Utilities()
    private let location = "AuthGoolgle"
    private var keychain = KeychainSwift()
    
    
    // MARK: - methods

    @MainActor func login() async throws -> AuthSocialLoginResDTO {
        util.log(.info, location, "Initialize Google-Social-Login process", "LoginProcess")
        
        // prepare google parameter
        guard let topVC = GoogleLoginHelper.shared.topViewController() else {
            throw AuthGoogleError.UnexpectedTopViewControllerError
        }
        util.log(.info, location, "TopView Controller Ready", "LoginProcess")
        
        // google login process
        let loginResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)
        util.log(.info, location, "Google-Social-Login process complete", "LoginProcess")
        
        // firebase authentication
        let userType = try await firebaseAuth(loginResult: loginResult)
        util.log(.info, location, "Firebase authentication process complete", "LoginProcess")
        
        // login result inspection
        let dto = AuthSocialLoginResDTO(loginResult: loginResult, userType: userType)
        dataInspection(with: dto)
        return dto
    }
    
    private func firebaseAuth(loginResult: GIDSignInResult) async throws -> UserType {
        let credential = GoogleAuthProvider.credential(
            withIDToken: loginResult.user.idToken!.tokenString,
            accessToken: loginResult.user.accessToken.tokenString
        )
        let authResult = try await Auth.auth().signIn(with: credential)
        return authResult.additionalUserInfo?.isNewUser == true ? UserType.new : UserType.exist
    }
    
    func logout() throws {
        try Auth.auth().signOut()
        keychain.delete("idToken")
        keychain.delete("accessToken")
        let userDefaultManager = UserDefaultManager.loadWith(key: "user")
        userDefaultManager?.identifier = ""
        userDefaultManager?.userName = ""
    }
    
    private func dataInspection(with dto: AuthSocialLoginResDTO) {
        util.log(.info, location, "Initialize AuthDTO data inspection", dto.email ?? "")
        let log = """
        * email: \(dto.email)
        * provider: \(dto.provider)
        * status: \(dto.status)
        """
        print(log)
    }
}

// MARK: Exception

enum AuthGoogleError: LocalizedError {
    case UnexpectedTopViewControllerError
    
    var errorDescription: String?{
        switch self {
        case .UnexpectedTopViewControllerError:
            return "[Critical]AuthGoogle - Throw: There was an unexpected error while get TopView Controller"
        }
    }
}
