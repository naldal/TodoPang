//
//  LoginService.swift
//  teamplan
//
//  Created by 주찬혁 on 2023/09/06.
//  Copyright © 2023 team1os. All rights reserved.
//

import Foundation
import AuthenticationServices

final class LoginService {
    
    let google = AuthGoogleServices()
    let apple = AuthAppleServices()
    
    // MARK: GoogleLogin
    
    func loginGoole() async throws -> AuthSocialLoginResDTO {
        return try await google.login()
    }
    
    // MARK: AppleLogin
    
    func loginApple(
        appleCredential: ASAuthorizationAppleIDCredential,
        result: @escaping(Result<AuthSocialLoginResDTO, Error>) -> Void
    ) async {
        await apple.login(appleCredential: appleCredential) { loginResult in
            switch loginResult {
            case .success(let userInfo):
                result(.success(userInfo))
                break
            case .failure(let error):
                print(error)
                break
            }
        }
    }
}
