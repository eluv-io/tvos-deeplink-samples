//
//  ContentView.swift
//  EluvioDeepLinkSample
//
//  Created by Wayne Tran on 2024-02-13.
//

import SwiftUI

let APPSTOREURL = "https://apps.apple.com/in/app/eluvio-media-wallet/id1591550411"
let TENANT_ID = "iten34Y7Tzso2mRqhzZ6yJDZs2Sqf8L"
let MARKETPLACE = "iq__D3N77Nw1ATwZvasBNnjAQWeVLWV"
let SKU = "5MmuT4t6RoJtrT9h1yTnos"
let CONTRACT = "0xb77dd8be37c6c8a6da8feb87bebdb86efaff74f4"
let FABRIC_CONFIG_URL = "https://main.net955305.contentfabric.io/config"
let CONTENT_WIDTH : CGFloat = 1200

func CreateLoginUrl(marketplaceId: String) -> String {
    return "https://wallet.contentfabric.io/login?mid=\(marketplaceId)&useOry=true&action=login&mode=login&response=code&source=code"
}

struct ContentView: View {
    @Environment(\.openURL) private var openURL
    @StateObject var fabric = Fabric()
    @StateObject var login = LoginManager()
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    let linker = Linker()
    
    func openLink(url:URL) {
        print("OpenLink ", url)
        openURL(url) { accepted in
            print(accepted ? "Success" : "Failure")
            if (!accepted){
                openURL(URL(string:APPSTOREURL)!) { accepted in
                    print(accepted ? "Success" : "Failure")
                    if (!accepted) {
                        print("Could not open URL ", APPSTOREURL)
                    }
                }
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment:.center) {
                Header(loginUrl:CreateLoginUrl(marketplaceId:MARKETPLACE))
                Divider()
                    .padding(.bottom, 40)
                
                Button {
                    let urlString = linker.createPlayLink(contract: CONTRACT)
                    if let url = URL(string: urlString) {
                        openLink(url:url)
                    }
                } label: {
                    Text("Play Media")
                    .frame(width:CONTENT_WIDTH)
                }
                
                Button {
                    let urlString = linker.createBundleLink(contract: CONTRACT, marketplace: MARKETPLACE, sku: SKU)
                    if let url = URL(string: urlString) {
                        openLink(url:url)
                    }

                } label: {
                    Text("Launch Bundle")
                    .frame(width:CONTENT_WIDTH)
                }
                
                
                Button {
                    if let token = login.loginInfo?.token {
                        let purchaseId = UUID().uuidString
                        Task {
                            do {
                                if let entitlementJson = try await fabric.authClient?.createEntitlement(tenantId: TENANT_ID, marketplace:MARKETPLACE, sku: SKU, purchaseId: purchaseId, authToken: token) {
                                    if let string = entitlementJson.rawString() {
                                        debugPrint("Entitlement ", string)
                                        let urlString = linker.createMintLink(marketplace: MARKETPLACE, sku: SKU, entitlement: string)
                                        if let url = URL(string: urlString) {
                                            openLink(url:url)
                                        }
                                    }
                                }
                            }catch{
                                print("Could not create entitlement from api: ", error)
                            }
                        
                        }
                    }else {
                        alertMessage = "Please login first"
                        showingAlert = true
                    }
                } label: {
                    Text("Mint Bundle with Entitlement")
                    .frame(width:CONTENT_WIDTH)
                }
                
            }
            .frame(maxWidth: .infinity)
        }
        .scrollClipDisabled()
        .environmentObject(
            fabric
        )
        .environmentObject(
            login
        )
        .alert(alertMessage, isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        }
        .task {
            do {
                try await fabric.connect(configUrl: FABRIC_CONFIG_URL)
            }catch{
                print(
                    "Error connecting to the fabric: ",
                    error
                )
            }
        }
    }
}

#Preview {
    ContentView()
}
