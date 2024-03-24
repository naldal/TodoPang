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
    
    // MARK: - private properties
    
    private let google: AuthGoogleService
    private let apple: AuthAppleService

    
    // MARK: - life cycle
    
    init(authGoogleService: AuthGoogleService, authAppleService: AuthAppleService) {
        self.google = authGoogleService
        self.apple = authAppleService
    }
    
    
    // MARK: - method
    
    func loginGoogle() async throws -> AuthSocialLoginResDTO {
        return try await google.login()
    }
    
    func requestNonceSignInApple() -> String {
        return self.apple.randomNonce()
    }
}
