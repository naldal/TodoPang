//
//  LoginService.swift
//  teamplan
//
//  Created by 주찬혁 on 2023/09/06.
//  Copyright © 2023 team1os. All rights reserved.
//

import Foundation
import AuthenticationServices

final class LoginService{
    
    let google = AuthGoogleServices()
    let apple = AuthAppleServices()
    
    //====================
    // MARK: GoogleLogin
    //====================
    func loginGoogle(result: @escaping(Result<AuthSocialLoginResDTO, Error>) -> Void) async {
        
        await google.login(){ loginResult in
            switch loginResult {
            // Authentication Success: NewUser & Exist
            case .success(let userInfo):
                result(.success(userInfo))
                break
            // Authentication Failure: Unknown
            case .failure(let error):
                print(error)
                break
            }
        }
                
    // TODO: case1. missing TopViewController
    // TODO: case2. firebase authentication error
    // TODO: case3. Google Social Login error

    }
    
    //====================
    // MARK: AppleLogin
    //====================
    func loginApple(
        appleCredential: ASAuthorizationAppleIDCredential ,
        result: @escaping(Result<AuthSocialLoginResDTO, Error>) -> Void) async {
        
        await apple.login(appleCredential: appleCredential){ loginResult in
            switch loginResult {
            // Authentication Success: NewUser & Exist
            case .success(let userInfo):
                result(.success(userInfo))
                break
            // Authentication Failure: print error
            case .failure(let error):
                print(error)
                
                // TODO: case2. firebase authentication error
                // TODO: case3. Apple Social Login error
                
                break
            }
        }
    }
}