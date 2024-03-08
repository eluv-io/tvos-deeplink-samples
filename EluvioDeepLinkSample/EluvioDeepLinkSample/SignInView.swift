//
//  SignInView.swift
//  EluvioDeepLinkSample
//
//  Created by Wayne Tran on 2024-03-07.
//

import Foundation
import SwiftUI
import SwiftyJSON
import Combine

struct SignInView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var fabric: Fabric
    @EnvironmentObject var login : LoginManager
    @State var marketplaceId = ""
    @State var url = ""
    @State var statusUrl: String = ""
    @State var code = ""
    @State var deviceCode = ""
    @State var timer = Timer.publish(every: 1, on: .main, in: .common)
    @State var timerCancellable: Cancellable? = nil
    @State var showError = false
    @State var errorMessage = ""
    @State private var response = JSON()
    
    var countDown:Timer!
    var expired = false
    var ClientId = ""
    var Domain = ""
    var GrantType = ""
    

    var body: some View {
        VStack(alignment: .center, spacing: 30){
            VStack(alignment: .center, spacing:20){

                Text("Scan QR Code")
                    .font(.custom("Helvetica Neue", size: 50))
                    .fontWeight(.semibold)
                Text("Scan the QR Code with your camera app or a QR code reader on your device to verify the code.")
                    .font(.custom("Helvetica Neue", size: 30))
                    .fontWeight(.thin)
                    .frame(width: 600)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Text(code)
                    .font(.custom("Helvetica Neue", size: 50))
                    .fontWeight(.semibold)
                
                Image(uiImage: GenerateQRCode(from: url))
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 400, height: 400)
            }
            .frame(width: 700)
            
            Spacer()
                .frame(height: 10.0)
            
            HStack(alignment: .center, spacing:40){
                Button(action: {
                    Task{
                        await self.regenerateCode()
                    }
                }) {
                    Text("Request New Code")
                }
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Back")
                }
            }
            .focusSection()
        }
        .frame(maxWidth:.infinity, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all)
        .background(.thickMaterial)
        .onAppear(perform: {
            if(!login.isLoggedOut){
                self.presentationMode.wrappedValue.dismiss()
            }else{
                Task{
                    await self.regenerateCode()
                }
            }
        })
        .onReceive(timer) { _ in
            Task {
                await checkDeviceVerification(statusUrl: statusUrl)
            }
        }
        .fullScreenCover(isPresented: $showError) {
            VStack{
                Spacer()
                Text("Error connecting to the Network. Please try again later.")
                Spacer()
            }
            .background(Color.black.opacity(0.8))
            .background(.thickMaterial)
        }
    }
    
    func regenerateCode() async {
        do {
            guard let authClient = self.fabric.authClient else {
                print("MetaMaskFlowView regenerateCode() called without a signer.")
                return
            }
            
            let json = try await authClient.createAuthLogin(redirectUrl: url)
            
            self.response = json
            
            print("createMetaMaskLogin completed");
            
            
            debugPrint("MetaMask create response: ",json)

            self.url = json["url"].stringValue
            if (!self.url.hasPrefix("https") && !self.url.hasPrefix("http")){
                self.url = "https://".appending(self.url)
            }
            
            debugPrint("LOGIN URL: ", self.url)
            
            self.code = json["id"].stringValue
            self.deviceCode = json["passcode"].stringValue
            
            let interval = 5.0
            self.timer = Timer.publish(every: interval, on: .main, in: .common)
            self.timerCancellable = self.timer.connect()
        }catch{
            print("Could not get code for MetaMask login", error)
        }
    }
                                    
    
    func checkDeviceVerification(statusUrl: String) async {
        print("checkDeviceVerification \(self.code)");
        do {
            guard let result = try await self.fabric.authClient?.checkAuthLogin(createResponse: response) else{
                print("checkDeviceVerification() checkMetaMaskLogin returned nil")
                return
            }
            

            let status = result["status"].intValue
            
            if(status != 200){
                print("Check value \(result)")
                return
            }
            
            debugPrint("Result ", result)
            
            let json = JSON.init(parseJSON:result["payload"].stringValue)
            
            if json.isEmpty {
                print("checkDeviceVerification() json payload is empty.")
                showError = true
                return
            }
            
            let type = json["type"].stringValue
            let token = json["token"].stringValue
            let addr = json["addr"].stringValue
            let eth = json["eth"].stringValue

            login.loginInfo = LoginResponse(type: type, addr:addr, eth:eth, token: token)
            login.isLoggedOut = false
            
            self.timerCancellable!.cancel()
            self.presentationMode.wrappedValue.dismiss()
        } catch {
            print("checkDeviceVerification error", error)
            self.errorMessage =  error.localizedDescription
            showError = true
        }
    }
}
