//
//  Linker.swift
//  EluvioDeepLinkSample
//
//  Created by Wayne Tran on 2024-03-04.
//

import Foundation

struct Linker {
    
    var urlScheme = "elvwallet://"
    var backlink = "walletlinksample://"
    
    func createBundleLink(
        contract:String,
        marketplace: String,
        sku: String,
        authToken: String = ""
    ) -> String {
        return urlScheme + "items" + "?" + "contract=\(contract)" + "&marketplace=\(marketplace)"
        + "&sku=\(sku)" + (authToken.isEmpty ? "" : "&authorization=\(authToken)") + "&back_link=\(backlink)"
    }
    
    func createPlayLink(
        contract:String,
        marketplace: String,
        sku: String,
        authToken: String = ""
    ) -> String {
        return urlScheme + "play" + "?" + "contract=\(contract)" + "&marketplace=\(marketplace)"
        + "&sku=\(sku)" + (authToken.isEmpty ? "" : "&authorization=\(authToken)") + "&back_link=\(backlink)"
    }
    
    func createMintLink(
        marketplace: String,
        sku: String,
        entitlement: String,
        signature: String,
        authToken: String = ""
    ) -> String {
        //Combine signature and entitlement to pass into the deep link
        let ent = "{\"entitlement\":\(entitlement), \"signature\":\"\(signature)\"}"
        
        return urlScheme + "mint" + "?" + "marketplace=\(marketplace)" + "&sku=\(sku)" + "&entitlement=\(ent)" + (authToken.isEmpty ? "" : "&authorization=\(authToken)") + "&back_link=\(backlink)"
    }

}
