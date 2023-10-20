//
//  SignupLoadingService.swift
//  teamplan
//
//  Created by 주찬혁 on 2023/10/20.
//  Copyright © 2023 team1os. All rights reserved.
//

import Foundation

final class SignupLoadingService{
    
    let userFS = UserServicesFirestore()
    let userCD = UserServicesCoredata()
    
    var newProfile: UserObject
    
    //===============================
    // MARK: - Constructor
    //===============================
    init(newUser: UserSignupReqDTO){
        let signupDate = Date()
        self.newProfile = UserObject(newUser: newUser, signupDate: signupDate)
    }
    
    //===============================
    // MARK: - Set User
    //===============================
    // : Firestore
    func setUserFS(result: @escaping(Result<Bool, Error>) -> Void) {
        userFS.setUserFirestore(reqUser: self.newProfile) { fsResult in
            switch fsResult {
    
            case .success(let docsId):
                self.newProfile.addDocsId(docsId: docsId)
                return result(.success(true))
                
            case .failure(let error):
                print(error)
                return result(.failure(error))
            }
        }
    }
    
    // : Coredata
    func setUserCD(result: @escaping(Result<Bool, Error>) -> Void) {
        userCD.setUserCoredata(userObject: self.newProfile) { cdResult in
            self.handleServiceResult(cdResult, with: result)
        }
    }
    
    //===============================
    // MARK: - Set Statistics
    //===============================
    
    
    //===============================
    // MARK: - Set AccessLog
    //===============================
    
    
    //===============================
    // MARK: - Set ChallengeLog
    //===============================

    
    //===============================
    // MARK: - Result Handler
    //===============================
    func handleServiceResult(_ serviceResult: Result<String, Error>,
                             with result: @escaping(Result<Bool, Error>) -> Void) {
        switch serviceResult {
        case .success(let message):
            print(message)
            result(.success(true))
        case .failure(let error):
            print(error)
            result(.failure(error))
        }
    }
}


