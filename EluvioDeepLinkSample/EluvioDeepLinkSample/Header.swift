//
//  Header.swift
//  EluvioDeepLinkSample
//
//  Created by Wayne Tran on 2024-03-07.
//

import SwiftUI

struct Header: View {
    @EnvironmentObject var fabric: Fabric
    @EnvironmentObject var login : LoginManager
    
    var loginUrl : String
    
    var loginName : String {
        login.loginInfo?.addr ?? ""
    }
    
    var isLoggedOut : Bool {
        login.isLoggedOut
    }
    
    @State var showSignIn = false
    
    var signInText: String {
        login.isLoggedOut ? "SIGN IN" : "SIGN OUT"
    }
    
    func signOut() {
        login.signOut()
    }
    
    var body: some View {
        HStack  {
            HStack(
                alignment:.top,
                spacing:20
            ){
                Image("e_logo")
                    .resizable()
                    .frame(
                        width:120,
                        height:120
                    )
                Text("Eluvio Wallet Link Sample")
                    .foregroundColor(Color.white.opacity(0.4))
                    .font(.title)
            }
            .frame(maxWidth: .infinity)
            
            Spacer()
            
            VStack(alignment:.leading) {
                Button{
                    if isLoggedOut {
                        showSignIn = true
                    }else {
                        signOut()
                    }
                } label: {
                    HStack(
                        alignment:.center,
                        spacing:20
                    ){
                        Image(systemName: "person.fill")
                            .resizable()
                            .frame(
                                width:32,
                                height:32
                            )
                        Text(signInText)
                            .font(.system(size: 30))
                            .fontWeight(.semibold)
                    }
                }
                Text(loginName)
                    .font(.system(size: 30))
                    .padding(.top,5)
                    .frame(maxWidth:300)
                    .lineLimit(1)
            }
        }
        .focusSection()
        .frame(maxWidth: .infinity)
        .fullScreenCover(isPresented: $showSignIn) {
            SignInView(url:loginUrl)
        }
    }
}
