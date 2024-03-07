//
//  ContentView.swift
//  EluvioDeepLinkSample
//
//  Created by Wayne Tran on 2024-02-13.
//

import SwiftUI

let APPSTOREURL = "https://apps.apple.com/in/app/eluvio-media-wallet/id1591550411"
let MARKETPLACE = "iq__2YZajc8kZwzJGZi51HJB7TAKdio2"
let SKU = "5teHdjLfYtPuL3CRGKLymd"
let CONTRACT = "0xb77dd8be37c6c8a6da8feb87bebdb86efaff74f4"

let CONTENT_WIDTH : CGFloat = 1200

struct Header: View {
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
        }
        .focusSection()
        .frame(maxWidth: .infinity)
    }
}

struct ContentView: View {
    @Environment(\.openURL) private var openURL
    
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
                    let entitlement = linker.createDemoEntitlement()
                    let urlString = linker.createMintLink(marketplace: MARKETPLACE, sku: SKU, entitlement: entitlement)
                    if let url = URL(string: urlString) {
                        openLink(url:url)
                    }
                } label: {
                    Text("Mint Bundle with Entitlement")
                    .frame(width:CONTENT_WIDTH)
                }
                
            }
            .frame(maxWidth: .infinity)
        }
        .scrollClipDisabled()
    }
}

#Preview {
    ContentView()
}
