//
//  Fabric.swift
//  EluvioDeepLinkSample
//
//  Created by Wayne Tran on 2024-03-07.
//

import Foundation
import SwiftyJSON
import Alamofire

enum FabricError: Error {
    case invalidURL(String)
    case configError(String)
    case unexpectedResponse(String)
    case noLogin(String)
    case badInput(String)
}

struct RuntimeError: LocalizedError {
    let description: String

    init(_ description: String) {
        self.description = description
    }

    var errorDescription: String? {
        description
    }
}

struct FabricConfiguration: Codable {
    let nodeID: String
    let network: Network
    let qspace: Qspace
    let fabricVersion: String

    enum CodingKeys: String, CodingKey {
        case nodeID = "node_id"
        case network, qspace
        case fabricVersion = "fabric_version"
    }
    
    func getQspaceId() -> String{
        return self.qspace.id
    }
    
    func getAuthServices() -> [String]{
        return self.network.services.authorityService
    }
    
    func getFabricAPI() -> [String]{
        return self.network.seedNodes.fabricAPI
    }
    
    func getEthereumAPI() -> [String]{
        return self.network.seedNodes.ethereumAPI
    }
}

// MARK: - Network
struct Network: Codable {
    let seedNodes: SeedNodes
    let apiVersions: [Int]
    let services: Services

    enum CodingKeys: String, CodingKey {
        case seedNodes = "seed_nodes"
        case apiVersions = "api_versions"
        case services
    }
}

// MARK: - SeedNodes
struct SeedNodes: Codable {
    let fabricAPI, ethereumAPI: [String]

    enum CodingKeys: String, CodingKey {
        case fabricAPI = "fabric_api"
        case ethereumAPI = "ethereum_api"
    }
}

// MARK: - Services
struct Services: Codable {
    let authorityService, ethereumAPI, fabricAPI : [String]
    let search: [String]?
    enum CodingKeys: String, CodingKey {
        case authorityService = "authority_service"
        case ethereumAPI = "ethereum_api"
        case fabricAPI = "fabric_api"
        case search
    }
}

// MARK: - Qspace
struct Qspace: Codable {
    let id, version, type: String
    let ethereum: Ethereum
    let names: [String]
}

// MARK: - Ethereum
struct Ethereum: Codable {
    let networkID: Int

    enum CodingKeys: String, CodingKey {
        case networkID = "network_id"
    }
}


class Fabric: ObservableObject {
    var configUrl = ""
    var network = ""
    var configuration : FabricConfiguration? = nil
    var mainStaticUrl = "https://main.net955305.contentfabric.io/s"
    let mainStaticToken = "eyJxc3BhY2VfaWQiOiJpc3BjMlJVb1JlOWVSMnYzM0hBUlFVVlNwMXJZWHp3MSJ9Cg=="
    var authClient : AuthService? = nil

    func connect(configUrl: String) async throws {
        guard let url = URL(string: configUrl) else {
            throw FabricError.invalidURL("\(self.configUrl)")
        }
        
        // Use the async variant of URLSession to fetch data
        // Code might suspend here
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let str = String(decoding: data, as: UTF8.self)
        
        print("Fabric config response: \(str)")

        let config = try JSONDecoder().decode(FabricConfiguration.self, from: data)
        self.configuration = config
        
        guard let ethereumApi = self.configuration?.getEthereumAPI() else {
            throw FabricError.configError("Error getting ethereum apis from config: \(self.configuration)")
        }
        
        guard let asApi = self.configuration?.getAuthServices() else{
            throw FabricError.configError("Error getting authority apis from config: \(self.configuration)")
        }
        self.authClient = AuthService(ethApi: ethereumApi, authorityApi:asApi, network:"main")
    }
    
    
    func getEndpoint() -> String{
        
        guard let config = self.configuration else {
            debugPrint("config error")
            return mainStaticUrl
        }

        let endpoint = config.getFabricAPI()[0]
        if(endpoint.isEmpty){
            debugPrint("endpoint error.")
            return mainStaticUrl;
        }
        return endpoint
    }
    
    func createUrl(path:String, token: String = "") -> String {
        return getEndpoint() + path + "?authorization=\(token.isEmpty ? mainStaticToken : token)"
    }
}

struct JRPCParams: Codable {
    var jsonrpc = "2.0"
    var id = 1
    var method: String
    var params: [String]
}

class AuthService {
    var ethApi : [String]
    var authorityApi: [String]
    var currentEthIndex = 0
    var currentAuthIndex = 0
    var network : String

    init(ethApi: [String], authorityApi: [String], network: String){
        self.ethApi = ethApi
        self.authorityApi = authorityApi
        self.network = network
    }
    
    func getEthEndpoint() throws -> String{
        let endpoint = self.ethApi[self.currentEthIndex]
        if(endpoint.isEmpty){
            throw FabricError.configError("getEthEndpoint: could not get endpoint")
        }
        return endpoint
    }
    
    func getAuthEndpoint() throws -> String{
        let endpoint = self.authorityApi[self.currentAuthIndex]
        if(endpoint.isEmpty){
            throw FabricError.configError("getEthEndpoint: could not get endpoint")
        }
        return endpoint
    }

    
    //TODO: Convert this to responseDecodable
    func createAuthLogin(redirectUrl: String) async throws -> JSON {
        return try await withCheckedThrowingContinuation({ continuation in
            debugPrint("****** createMetaMaskLogin ******")
            do {
                var endpoint = try self.getAuthEndpoint().appending("/wlt/login/redirect/metamask")

                let headers: HTTPHeaders = [
                     "Accept": "application/json",
                     "Content-Type": "application/json" ]

                let parameters : [String: Any] = ["op":"create", "dest": redirectUrl]
                
                AF.request(endpoint, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers )
                    .responseJSON { response in
                    switch (response.result) {
                        case .success(let result):
                            continuation.resume(returning: JSON(result))
                         case .failure(let error):
                            print("createMetaMaskLogin error: \(error)")
                            continuation.resume(throwing: error)
                     }
                }
            }catch{
                continuation.resume(throwing: error)
            }
        })
    }
    
    //Pass in the response JSON of createMetaMaskLogin
    func checkAuthLogin(createResponse: JSON) async throws -> JSON {
        return try await withCheckedThrowingContinuation({ continuation in
            debugPrint("****** checkAuthLogin ******")
            do {
                
                let id = createResponse["id"].stringValue
                let pass = createResponse["passcode"].stringValue
                
                if (id == ""){
                    continuation.resume(throwing: FabricError.badInput("checkAuthLogin failed. ID is empty"))
                }
                
                if (pass == ""){
                    continuation.resume(throwing: FabricError.badInput("checkAuthLogin failed. passcode is empty"))
                }
                
                let endpoint = try self.getAuthEndpoint().appending("/wlt/login/redirect/metamask/")
                    .appending(id).appending("/").appending(pass)

                let headers: HTTPHeaders = [
                     "Accept": "application/json",
                     "Content-Type": "application/json" ]

                AF.request(endpoint, encoding: JSONEncoding.default, headers: headers )
                    .responseJSON { response in

                    switch (response.result) {
                        case .success(let result):
                            continuation.resume(returning: JSON(result))
                         case .failure(let error):
                            print("checkAuthLogin error: \(error)")
                            continuation.resume(throwing: error)
                     }
                }
            }catch{
                continuation.resume(throwing: error)
            }
        })
    }
    
    func createEntitlement(tenantId: String, marketplace: String, sku: String, purchaseId: String, authToken: String) async throws -> JSON {
        return try await withCheckedThrowingContinuation({ continuation in
            debugPrint("****** checkAuthLogin ******")
            let endpoint = "https://appsvc.svc.eluv.io/sample-purchase/gen-entitlement"
            
            let headers: HTTPHeaders = [
                 "Accept": "application/json",
                 "Content-Type": "application/json",
                 "Authorization" : "Bearer \(authToken)"]
            
            let parameters : [String: Any] = [
                "tenant_id":tenantId,
                "marketplace_id":marketplace,
                "sku":sku,
                "purchase_id": purchaseId]
            
            AF.request(endpoint, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers )
                .responseJSON { response in

                debugPrint("response: ", response)
                switch (response.result) {
                    case .success(let result):
                        continuation.resume(returning: JSON(result))
                     case .failure(let error):
                        print("createEntitlement error: \(error)")
                        continuation.resume(throwing: error)
                 }
            }
        })
    }
    
}
