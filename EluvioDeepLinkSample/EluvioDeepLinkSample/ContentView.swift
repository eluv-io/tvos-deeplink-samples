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
let JWT_ACCESS_TOKEN = "eyJhbGciOiJSUzI1NiIsImtpZCI6ImJhMWU3M2EzLWQ0MGYtNGMxYy05NjY2LTA3NmZlYWQ0NDU2NSIsInR5cCI6IkpXVCJ9.eyJhbXIiOlsiY29kZV9yZWNvdmVyeSIsInBhc3N3b3JkIl0sImF0X2hhc2giOiJHa3R2RFZIaGN3M1RiT25WOUpObmhRIiwiYXVkIjpbIjU3YzI0YTZjLTA5NTQtNDExYi04NDljLTJlODlhMzM5OTFkYSJdLCJhdXRoX3RpbWUiOjE3MTQwNTMwNDgsImV4cCI6MTcxNDA1NjY1MiwiaWF0IjoxNzE0MDUzMDUyLCJpc3MiOiJodHRwczovL2Zyb3N0eS1zYW5kZXJzb24tamwxeGJpODhpay5wcm9qZWN0cy5vcnlhcGlzLmNvbSIsImp0aSI6IjZiMDk3ZjE3LTgwOWMtNDEzNC04OGYzLTY0MDRjN2ZiMDBkOSIsIm5vbmNlIjoiMDAwMS0wMDAyLTAwMDMiLCJyYXQiOjE3MTQwNTMwNDIsInNpZCI6IjVlYWU2ZDY3LTIzNDUtNGEyYy1hODhmLTA1OWEyMzAyNTRhNSIsInN1YiI6IjNhOWI1ODg1LTg2MmMtNDFhNS04NWZhLWM3OGZjNjE1NTFhMSJ9.sSohUbBcMmhwa_zKfyx-CaI4YgJMKrLDPGHCel1U9ZeeN41GsOggFCXo7I3wJ58MLMbfqegu5y0qyyvUVcNP8UNfSiAksQc_xdLdAzzz83h2Nh-adjz92XjgstTcM7tFOuhv2Aub8yfzPXQmOFRNEPAxRB9RptFOw5tWvX3FfpTiebsIBlINRtMIlp-KmHaSiTys_i0TlXRVtPRTMjJN8jULSVpoLgdDYL4UBczu5PKS2juOWaWTVIfoRKO_0ju4up6tRMIOpXIubpRYToyXC8Ot7Z2dEvEtuxxUfCjuLxTU_I0MLLr40jVJGPGbNJwaqDcYNKpe_LQ_A6iU0x-h3K_xELYB3pQ0t8ccsNaP7l30eFRwYmLof-j_BsnmVwRsNdcG34LWktmm4dyoyYQeHkfUxfPMpAYOgDzPPAoX5B8nIJZ9bt8HA-JEdAx2ce0RAX4ijsNJifH6IFoFAQ-80HpS6c_YTNfH5FxAwuTYPMcqaeH-AsY0m5POG1CUDD_tuu-hOaYClQqHgZ21uJvVJjvp05u1qiLoqJv7yIbHMTF-M2ZU129lpL5GDtv8Fvj4_zWlfVKmeTbWTfbazz3kQFNZTVi1die4rXWjLJyhCQ_aZ41i87X_n-cPMVeMH4DZeRQuoyCkKs3mRXR4MJvdxdUlRhWiKS2gSKa4VOqGU10"
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
