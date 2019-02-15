//
//  ESIClient.swift
//  EVE ESI
//
//  Created by Tristan Pollard on 2017-09-25.
//  Copyright © 2017 Sumo. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import ObjectMapper
import CommonCrypto
import KTVJSONWebToken

enum ESIError: Error {
    case invalidChallengeCode
    case invalidChalllengeData
}

final class ESIClient {

    static let sharedInstance = ESIClient()

    enum baseURI: String {
        case api = "https://esi.evetech.net"
        case login = "https://login.eveonline.com"
        case loginV2 = "https://login.eveonline.com/v2"
        case image = "https://imageserver.eveonline.com"
    }

    static let type = "code"
    static let callback = "eveauth-interbus://callback/"
    static let client_id = "ecae83f594e5415c860707aa6d9f8d23"
    static let codeChallengeMethod = "S256"

    static let scopes: [String] = [
        "publicData",
        "esi-calendar.respond_calendar_events.v1",
        "esi-calendar.read_calendar_events.v1",
        "esi-location.read_location.v1",
        "esi-location.read_ship_type.v1",
        "esi-mail.organize_mail.v1",
        "esi-mail.read_mail.v1",
        "esi-mail.send_mail.v1",
        "esi-skills.read_skills.v1",
        "esi-skills.read_skillqueue.v1",
        "esi-wallet.read_character_wallet.v1",
        "esi-wallet.read_corporation_wallet.v1",
        "esi-search.search_structures.v1",
        "esi-clones.read_clones.v1",
        "esi-characters.read_contacts.v1",
        "esi-universe.read_structures.v1",
        "esi-bookmarks.read_character_bookmarks.v1",
        "esi-killmails.read_killmails.v1",
//        "esi-corporations.read_corporation_membership.v1",
        "esi-assets.read_assets.v1",
        "esi-planets.manage_planets.v1",
        "esi-fleets.read_fleet.v1",
        "esi-fleets.write_fleet.v1",
        "esi-ui.open_window.v1",
        "esi-ui.write_waypoint.v1",
        "esi-characters.write_contacts.v1",
        "esi-fittings.read_fittings.v1",
        "esi-fittings.write_fittings.v1",
        "esi-markets.structure_markets.v1",
//        "esi-corporations.read_structures.v1",
//        "esi-corporations.write_structures.v1",
        "esi-characters.read_loyalty.v1",
        "esi-characters.read_opportunities.v1",
        "esi-characters.read_chat_channels.v1",
        "esi-characters.read_medals.v1",
        "esi-characters.read_standings.v1",
        "esi-characters.read_agents_research.v1",
        "esi-industry.read_character_jobs.v1",
        "esi-markets.read_character_orders.v1",
        "esi-characters.read_blueprints.v1",
        "esi-characters.read_corporation_roles.v1",
        "esi-location.read_online.v1",
        "esi-contracts.read_character_contracts.v1",
        "esi-clones.read_implants.v1",
        "esi-characters.read_fatigue.v1",
        "esi-killmails.read_corporation_killmails.v1",
//        "esi-corporations.track_members.v1",
        "esi-wallet.read_corporation_wallets.v1",
        "esi-characters.read_notifications.v1",
//        "esi-corporations.read_divisions.v1",
//        "esi-corporations.read_contacts.v1",
        "esi-assets.read_corporation_assets.v1",
//        "esi-corporations.read_titles.v1",
//        "esi-corporations.read_blueprints.v1",
        "esi-bookmarks.read_corporation_bookmarks.v1",
        "esi-contracts.read_corporation_contracts.v1",
//        "esi-corporations.read_standings.v1",
//        "esi-corporations.read_starbases.v1",
        "esi-industry.read_corporation_jobs.v1",
        "esi-markets.read_corporation_orders.v1",
//        "esi-corporations.read_container_logs.v1",
        "esi-industry.read_character_mining.v1",
        "esi-industry.read_corporation_mining.v1",
        "esi-planets.read_customs_offices.v1",
//        "esi-corporations.read_facilities.v1",
//        "esi-corporations.read_medals.v1",
        "esi-characters.read_titles.v1",
        "esi-alliances.read_contacts.v1",
        "esi-characters.read_fw_stats.v1",
//        "esi-corporations.read_fw_stats.v1",
//        "esi-corporations.read_outposts.v1",
        "esi-characterstats.read.v1"
    ]

    func getRSAKey(kid: String, completion: @escaping (RSAKey?) -> ()) {
        var key: [String: String]? = nil
        let options: [String: Any] = [
            "baseURI": ESIClient.baseURI.login
        ]
        self.invoke(endPoint: "/oauth/jwks", options: options) { response in
            if let result = response.result as? [String: Any] {
                if let keys = result["keys"] as? [[String: String]] {
                    key = keys.first {
                        if let kid = $0["kid"], let alg = $0["alg"] {
                            return kid == kid && alg == "RS256"
                        }
                        return false
                    }
                }
            }

            guard let jwks = key else {
                completion(nil)
                return
            }

            let mod = jwks["n"]!.replacingOccurrences(of: "-", with: "+")
                    .replacingOccurrences(of: "_", with: "/") + "=="
            let exp = jwks["e"]!
            let publicKey = try! RSAKey.registerOrUpdateKey(modulus: Data(base64Encoded: mod)!, exponent: Data(base64Encoded: exp)!, tag: "jwtVerifyTag")
            RSAKey.removeKeyWithTag("jwtVerifyTag")
            completion(publicKey)
        }
    }

    fileprivate var lastCodeChallenge: String? = nil

    static func getESIUrl(codeChallenge: String) -> String {
        return "\(ESIClient.baseURI.loginV2.rawValue)/oauth/authorize?response_type=\(ESIClient.type)&redirect_uri=\(ESIClient.callback)&client_id=\(ESIClient.client_id)&scope=\(ESIClient.scopes.joined(separator: "%20"))&code_challenge_method=\(ESIClient.codeChallengeMethod)&state=\(String.randomString(length: 12))&code_challenge=\(encodeChallenge(codeChallenge: codeChallenge).replacingOccurrences(of: "=", with: "").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)"
    }

    static func encodeChallenge(codeChallenge: String) -> String {
        let data = codeChallenge.data(using: .utf8)!
        var buffer = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0, CC_LONG(data.count), &buffer)
        }
        let hash = Data(bytes: buffer)
        let challenge = hash.base64EncodedString()
                .replacingOccurrences(of: "+", with: "-")
                .replacingOccurrences(of: "/", with: "_")
                .replacingOccurrences(of: "=", with: "")
                .trimmingCharacters(in: .whitespaces)
        return challenge
    }

    var cache: NSCache<NSString, ESIResponse>

    private init() {
        cache = NSCache<NSString, ESIResponse>()
    }

    func setLastCodeChallenge(challenge: String) {
        self.lastCodeChallenge = challenge
    }

    func invoke(endPoint: String, httpMethod: HTTPMethod = .get, token: SSOToken? = nil, options: [String: Any]? = nil, request: @escaping (DataRequest) -> () = { _ in
    }, completion: @escaping (ESIResponse) -> ()) {

        var requestBase = ESIClient.baseURI.api
        var parameters: Parameters? = nil
        var headers: HTTPHeaders? = nil
        var parameterEncoding: ParameterEncoding = URLEncoding.default

        let group = DispatchGroup()

        if let opt = options {
            if let params = opt["parameters"] as? Parameters {
                parameters = params
            }
            if let heads = opt["headers"] as? HTTPHeaders {
                headers = heads
            }
            if let base = opt["baseURI"] as? ESIClient.baseURI {
                requestBase = base
            }
            if let encoding = opt["encoding"] as? ParameterEncoding {
                parameterEncoding = encoding
            }
        }
        var requestURL = requestBase.rawValue + endPoint
        if requestURL.last! != "/" { //So apparently if we run into a redirect (ccp redirects non / requests to /) the authorization header drops.
            requestURL += "/"
        }

        if let tok = token {
            if headers == nil {
                headers = []
            }
            group.enter()
            tok.refreshIfNeeded {
                group.leave()
            }
        }

        group.notify(queue: .main) {
            if let tok = token {
                headers!["Authorization"] = tok.authorizationHeader()
            }
            print(requestURL, httpMethod, parameters, headers)

            let req = AF.request(requestURL, method: httpMethod, parameters: parameters, encoding: parameterEncoding, headers: headers).responseJSON { json in
                completion(ESIResponse(rawResponse: json))
            }
            request(req)
        }
    }

    func refreshToken(token: SSOToken, completion: @escaping (ESIResponse) -> ()) {
        let parameters: Parameters = ["grant_type": "refresh_token", "refresh_token": token.refresh_token!, "client_id": ESIClient.client_id]
        let options: [String: Any] = [
            "baseURI": ESIClient.baseURI.loginV2,
            "parameters": parameters
        ]
        self.invoke(endPoint: "/oauth/token", httpMethod: .post, options: options) { response in
            print(response.result)
            completion(response)
        }
    }

    func processCode(code: String, completion: @escaping (SSOToken) -> ()) throws {
        guard let challenge = self.lastCodeChallenge else {
            throw ESIError.invalidChallengeCode
        }
        self.lastCodeChallenge = nil

        guard let challengeData = challenge.data(using: .utf8) else {
            throw ESIError.invalidChalllengeData
        }

        var parameters: Parameters = [
            "grant_type": "authorization_code",
            "code": code, "client_id": ESIClient.client_id,
            "code_verifier": challengeData.base64EncodedString().replacingOccurrences(of: "=", with: "").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        ]
        let options: [String: Any] = [
            "baseURI": ESIClient.baseURI.loginV2,
            "parameters": parameters,
        ]

        self.invoke(endPoint: "/oauth/token", httpMethod: .post, options: options) { response in
            let token = SSOToken(response: response)
            completion(token)
        }
    }

}