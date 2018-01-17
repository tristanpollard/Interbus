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
import AlamofireObjectMapper
import PopupDialog

final class ESIClient {

    static let sharedInstance = ESIClient()

    static let baseURI : String = "https://esi.tech.ccp.is/latest";
    static let loginURI : String = "https://login.eveonline.com";
    static let type = "code"
    static let callback = "eveauth-companion://callback/"
    static let client_id = ""
    private static let secret_key = ""

    static let scopes : [String] = [
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
        "esi-search.search_structures.v1",
        "esi-clones.read_clones.v1",
        "esi-characters.read_contacts.v1",
        "esi-universe.read_structures.v1",
        "esi-bookmarks.read_character_bookmarks.v1",
        "esi-killmails.read_killmails.v1",
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
        "esi-corporations.write_structures.v1",
        "esi-characters.read_loyalty.v1",
        "esi-characters.read_opportunities.v1",
        "esi-characters.read_chat_channels.v1",
        "esi-characters.read_medals.v1",
        "esi-characters.read_standings.v1",
        "esi-characters.read_agents_research.v1",
        "esi-industry.read_character_jobs.v1",
        "esi-markets.read_character_orders.v1",
        "esi-characters.read_blueprints.v1",
        "esi-location.read_online.v1",
        "esi-contracts.read_character_contracts.v1",
        "esi-clones.read_implants.v1",
        "esi-characters.read_fatigue.v1",
        "esi-characters.read_notifications.v1",
        "esi-industry.read_character_mining.v1",
        "esi-characterstats.read.v1"
    ]

    static func getESIUrl() -> String{
        return "https://login.eveonline.com/oauth/authorize?response_type=\(ESIClient.type)&redirect_uri=\(ESIClient.callback)&client_id=\(ESIClient.client_id)&scope=\(ESIClient.scopes.joined(separator: "%20"))"
    }

    var cache : NSCache<NSString, ESIResponse>

    private init(){
        cache = NSCache<NSString, ESIResponse>()
    }

    func invoke(urlRequest: URLRequest, completionHandler: @escaping(ESIResponse) ->()){
        Alamofire.request(urlRequest).responseJSON{ response in
            let esiResponse = ESIResponse(rawResponse: response)
            completionHandler(esiResponse)
        }
    }

    func invoke(url: String = ESIClient.baseURI, endPoint: String, httpMethod : HTTPMethod = .get, parameters: Parameters? = nil, parameterEncoding: ParameterEncoding = URLEncoding.default, reqHeaders: HTTPHeaders? = nil, token: SSOToken? = nil, forceESI : Bool = false, completionHandler: @escaping (ESIResponse) -> ()){

        var httpHeaders = reqHeaders

        var requestUrl = url + endPoint
        if requestUrl.last! != "/"{ //So apparently if we run into a redirect (ccp redirects non / requests to /) the authorization header drops.
            requestUrl += "/"
        }

        var hashStr = "\(requestUrl):\(httpMethod.rawValue)"

        if let par = parameters{
            hashStr += ":\(par)"
        }

        if let char_id = token?.character_id{
            hashStr += ":\(char_id)"
        }

        if let existing = self.cache.object(forKey: hashStr as NSString){
            if httpMethod == .get && existing.expires! > Date() && !forceESI{
                completionHandler(existing)
                return
            }
        }

        if let tok = token{

            tok.refreshIfNeeded() {

                if httpHeaders == nil{
                    httpHeaders = [:]
                }

                httpHeaders!["Authorization"] = tok.authorizationHeader()
                Alamofire.request(requestUrl, method: httpMethod, parameters: parameters, encoding: parameterEncoding,headers: httpHeaders).responseJSON { response in
                    let esiResponse = ESIResponse(rawResponse: response)

                    if let resp = esiResponse.result as? [String:String]{
                        if let error = resp["error"] {
                            esiResponse.error = ESIResponse.ESIError(error: .unknown, errorMsg: error)
                            self.showError(msg: error)
                        }
                    }

                    self.cache.setObject(esiResponse, forKey: hashStr as NSString)
                    completionHandler(esiResponse)
                }
            }

        }else {

            let req = Alamofire.request(url + endPoint, method: httpMethod, parameters: parameters, encoding: parameterEncoding, headers: httpHeaders).responseJSON { response in
                let esiResponse = ESIResponse(rawResponse: response)
                if let resp = esiResponse.result as? [String:String]{
                    if let error = resp["error"] {
                        esiResponse.error = ESIResponse.ESIError(error: .unknown, errorMsg: error)
                        self.showError(msg: error)
                    }
                }
                self.cache.setObject(esiResponse, forKey: hashStr as NSString)
                completionHandler(esiResponse)
            }

        }
    }

    func refreshToken(token: SSOToken, completionHandler: @escaping() -> ()){
        let grant_type = "refresh_token"
        let parameters : Parameters = ["grant_type" : grant_type, "refresh_token" : token.refresh_token!]
        let headers : HTTPHeaders = ["Authorization" : "Basic \(ESIClient.getAuthorizationHeader())"]
        self.invoke(url: ESIClient.loginURI, endPoint: "/oauth/token", httpMethod: .post, parameters: parameters, reqHeaders: headers){ response in
            token.updateToken(response: response) {
                completionHandler()
            }
        }
    }

    func showError(msg: String){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if var topController = appDelegate.window!.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            topController.showErrorMsg(msg: msg)
        }
    }

    func processCode(code: String, completionHandler: @escaping(SSOToken) -> ()){

        let headers: HTTPHeaders = ["Authorization": "Basic \(ESIClient.getAuthorizationHeader())"]
        let parameters: Parameters = ["grant_type": "authorization_code", "code": code]

        self.invoke(url: ESIClient.loginURI, endPoint: "/oauth/token", httpMethod: .post, parameters: parameters, reqHeaders: headers){ response in
            let token = SSOToken(response: response)
            completionHandler(token)
        }

    }


    private static func getAuthorizationHeader() -> String{
        return "\(ESIClient.client_id):\(ESIClient.secret_key)".base64Encoded()!
    }

}