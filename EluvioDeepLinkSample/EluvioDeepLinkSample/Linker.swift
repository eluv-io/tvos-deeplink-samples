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
        sku: String
    ) -> String {
        return urlScheme + "items" + "?" + "contract=\(contract)" + "&marketplace=\(marketplace)"
        + "&sku=\(sku)" + "&back_link=\(backlink)"
    }
    
    func createPlayLink(
        contract:String
    ) -> String {
        return urlScheme + "play" + "?" + "contract=\(contract)" + "&back_link=\(backlink)"
    }
    
    func createMintLink(
        marketplace: String,
        sku: String,
        entitlement: String = ""
    ) -> String {
        return urlScheme + "mint" + "?" + "marketplace=\(marketplace)" + "&sku=\(sku)" + "&entitlement=\(entitlement)" + "&back_link=\(backlink)"
    }
    
    //Hardcoded for now
    func createDemoEntitlement(purchaseId:String = "") -> String {
        let item = EntitlementItem(sku:"5teHdjLfYtPuL3CRGKLymd", amount: 1)
        
        var _purchaseId = purchaseId
        if _purchaseId.isEmpty {
            _purchaseId = UUID().uuidString
        }
        
        let entitlement = EntitlementModel(
            marketplace_id: "iq__2YZajc8kZwzJGZi51HJB7TAKdio2",
            items: [item],
            nonce: UUID().uuidString,
            purchase_id: _purchaseId
        )
        
        do {
            let jsonData = try JSONEncoder().encode(entitlement)
            let jsonString = String(data: jsonData, encoding: .utf8)!
            return jsonString
        }catch{
            print("Could not encode entitlement ", error)
            return ""
        }
    }

}
