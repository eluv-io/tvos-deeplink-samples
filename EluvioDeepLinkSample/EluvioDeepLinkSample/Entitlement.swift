//
//  Entitlement.swift
//  EluvioDeepLinkSample
//
//  Created by Wayne Tran on 2024-03-04.
//

import Foundation

struct EntitlementModel: Codable {
    var marketplace_id : String = ""
    var items: [EntitlementItem]
    var nonce: String
    var purchase_id: String
}

struct EntitlementItem: Codable {
    var sku: String
    var amount: Int
}

func CreateEntitlement( marketplaceId: String, sku:String, purchaseId:String = "") -> String {
    let item = EntitlementItem(sku:sku, amount: 1)
    
    var _purchaseId = purchaseId
    if _purchaseId.isEmpty {
        _purchaseId = UUID().uuidString
    }
    
    let entitlement = EntitlementModel(
        marketplace_id: marketplaceId,
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
