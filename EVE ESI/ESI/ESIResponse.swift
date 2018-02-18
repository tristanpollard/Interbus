//
// Created by Tristan Pollard on 2017-09-26.
// Copyright (c) 2017 Sumo. All rights reserved.
//

import Foundation
import Alamofire

class ESIResponse {

    enum ESIErrorType: Error{
        case unknown
        case forbidden
        case notFound
    }

    struct ESIError {
        var error : ESIErrorType?
        var errorMsg : String?
    }

    var rawResponse : DataResponse<Any>
    var result : Any?
    var error : ESIError?
    var statusCode : Int?
    var expires : Date?

    init(rawResponse: DataResponse<Any>){
        self.rawResponse = rawResponse;
        parseResponse()
    }

    func parseResponse(){

        if let expires = self.rawResponse.response?.allHeaderFields["Expires"] as? String{
            let df = DateFormatter()
            df.dateFormat = "E, dd MMM yyyy HH:mm:ss zzz"
            self.expires = df.date(from: expires)
        }
        self.statusCode = self.rawResponse.response?.statusCode
        self.result = self.rawResponse.result.value

        if let code = self.statusCode {
            switch (code) {
            case 200, 204:
                break
            case 403:
                self.error = ESIError(error: .forbidden, errorMsg: "Forbidden")
            case 404:
                self.error = ESIError(error: .notFound, errorMsg: "Not Found")
            default:
                break
            }
        }else{
            self.error = ESIError(error: .unknown, errorMsg: "Unknown")
        }


    }
}
