//
//  LoginManager.swift
//  EluvioDeepLinkSample
//
//  Created by Wayne Tran on 2024-03-07.
//

import Foundation

class LoginManager : ObservableObject {
    @Published var isLoggedOut = true
    @Published var loginInfo : LoginResponse? = nil
    
    func signOut() {
        isLoggedOut = true
        loginInfo = nil
    }
}

struct LoginResponse: Codable {
    var type : String? = ""
    var addr: String
    var eth: String
    var token: String
}
