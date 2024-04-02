//
//  AuthAppleServices.swift
//  teamplan
//
//  Created by 주찬혁 on 2023/10/13.
//  Copyright © 2023 team1os. All rights reserved.
//

import Foundation
import FirebaseAuth
import AuthenticationServices

final class AuthAppleService {
    
    
    
    // MARK: - method
    
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
    
    func login(credential: OAuthCredential, idToken: String, completion: @escaping (Result<AuthSocialLoginResDTO, SignupError>) -> Void) {
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                completion(.failure(.invalidUser))
                return
            }
            
            guard let user = authResult?.user else {
                completion(.success(.init(loginResult: nil, idToken: idToken, userType: .new)))
                return
            }
            
            completion(.success(.init(loginResult: user, idToken: idToken, userType: .exist)))
        }
    }

}
