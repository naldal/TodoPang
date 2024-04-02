//
//  LoginService.swift
//  teamplan
//
//  Created by 주찬혁 on 2023/09/06.
//  Copyright © 2023 team1os. All rights reserved.
//

import Foundation
import FirebaseAuth
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
    
    
    // MARK: - private method
    
    func randomNonce(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var resultNonce = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }

            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }

                if random < charset.count {
                    resultNonce.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        return resultNonce
    }
    
    
    // MARK: - internal method
    
    func loginGoogle() async throws -> AuthSocialLoginResDTO {
        return try await google.login()
    }
    
    func loginApple(credential: OAuthCredential, idToken: String, completion: @escaping (Result<AuthSocialLoginResDTO, SignupError>) -> Void) {
        return self.apple.login(credential: credential, idToken: idToken, completion: completion)
    }
    
    func requestRandomNonce() -> String {
        return self.randomNonce()
    }
}
