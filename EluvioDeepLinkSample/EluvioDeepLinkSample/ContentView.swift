//
//  ContentView.swift
//  EluvioDeepLinkSample
//
//  Created by Wayne Tran on 2024-02-13.
//

import SwiftUI

// Either provide your own values from your system,
// or use https://appsvc.svc.eluv.io/sample-purchase as a development sample

let MARKETPLACE = "iq__D3N77Nw1ATwZvasBNnjAQWeVLWV"
let SKU = "5MmuT4t6RoJtrT9h1yTnos"
let JWT_ACCESS_TOKEN = ""
let ENTITLEMENT = """
{"tenant_id":"iten34Y7Tzso2mRqhzZ6yJDZs2Sqf8L","marketplace_id":"iq__D3N77Nw1ATwZvasBNnjAQWeVLWV","items":[{"sku":"5MmuT4t6RoJtrT9h1yTnos","amount":1}],"user":"3a9b5885-862c-41a5-85fa-c78fc61551a1","purchase_id":"12"}
"""

let ENTITLEMENT_SIGNATURE = "mje_KLmiKXVVaPZW9XyBz7RXBS7cr6KtRps3qwPdW62NjCwSS65djyZXZKnjVWRrpH5AJb7yV8DbmeopVrjquvnxk6WFK24yyE7XdA2XwZPXVJCUothX3BoH9iYLQahbXtiLH2tpn98kKyJsxcPkMuZrqTSwXvs2WefkP96AQSmjf3Ewek7w3Lp7U3dkQpcsJFLCu24qCnvt5QEvVnpu72PfeGFqa5zZu2Ha7Y5xfzeniT2mVgf6aB4mVam2fbGGp1m63ZakrHB7MXqkG3k13XoAK4B9KDeWD6H8GZYiLLvUYF2GDuSx2k5967derLH5a8Y8iW42q2MjR8ztPHRDPH4GTXfTpDLn4nKhVhKC9ezCUuK4VqRZgquQxLPZ1ESWkMK6c"

//Optional (will use the marketplace and sku to find the contract if not provided (for the bundle)
let CONTRACT = ""
let FABRIC_CONFIG_URL = "https://main.net955305.contentfabric.io/config"
let CONTENT_WIDTH : CGFloat = 1200
let APPSTOREURL = "https://apps.apple.com/in/app/eluvio-media-wallet/id1591550411"

struct ContentView: View {
    @Environment(\.openURL) private var openURL
    @StateObject var fabric = Fabric()
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
                Header()
                Divider()
                    .padding(.bottom, 40)
                
                Button {
                    let token = JWT_ACCESS_TOKEN
                    do {
                        if token.isEmpty {
                            throw "Please build the sample with a jwt token."
                        }
                            
                        if ENTITLEMENT.isEmpty {
                            throw "Please build the sample with an entitlement."
                        }
                        
                        if ENTITLEMENT_SIGNATURE.isEmpty {
                            throw "Please build the sample with an entitlement signature."
                        }
                            
                        let urlString = linker.createMintLink(marketplace: MARKETPLACE, sku: SKU, entitlement: ENTITLEMENT, signature: ENTITLEMENT_SIGNATURE, authToken: token)
                        debugPrint("deeplink string: ", urlString)
                        if let url = URL(string: urlString) {
                            openLink(url:url)
                        }

                    }catch {
                        alertMessage = error.localizedDescription
                        showingAlert = true
                    }
                } label: {
                    Text("Mint Bundle With Entitlement")
                    .frame(width:CONTENT_WIDTH)
                }
                
                // LAUNCH BUNDLE
                
                Button {
                    let token = JWT_ACCESS_TOKEN
                    let urlString = linker.createBundleLink(contract: CONTRACT, marketplace: MARKETPLACE, sku: SKU, authToken: token)
                    if let url = URL(string: urlString) {
                        openLink(url:url)
                    }

                } label: {
                    Text("Launch Bundle")
                    .frame(width:CONTENT_WIDTH)
                }
                
                // LAUNCH BUNDLE AND PLAY FIRST FEATURED MEDIA
                Button {
                    let token = JWT_ACCESS_TOKEN

                    let urlString = linker.createPlayLink(contract: CONTRACT, marketplace: MARKETPLACE, sku: SKU, authToken: token)
                    if let url = URL(string: urlString) {
                        openLink(url:url)
                    }
                } label: {
                    Text("Play Bundle Featured Media")
                    .frame(width:CONTENT_WIDTH)
                }
                
            }
            .frame(maxWidth: .infinity)
        }
        .scrollClipDisabled()
        .environmentObject(
            fabric
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
