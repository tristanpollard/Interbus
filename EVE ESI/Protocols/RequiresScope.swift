//
// Created by Tristan Pollard on 2018-02-10.
// Copyright (c) 2018 Sumo. All rights reserved.
//

import UIKit

protocol RequiresScope {

    var scopes : [String] { get }


}

extension RequiresScope{

    func characterHasScopes(_ character : EveAuthCharacter) -> Bool{

        let requiredScopes = Set(scopes)
        if let characterScopes = character.token?.scopes{
            let scopeSet = Set(characterScopes)
            return requiredScopes.isSubset(of: scopeSet)
        }

        return false

    }

    func showMissingScope(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if var topController = appDelegate.window!.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            topController.showErrorMsg(msg: "Missing Scope(s): \(scopes)")
        }
    }

}
