//
// Created by Tristan Pollard on 2017-10-06.
// Copyright (c) 2017 Sumo. All rights reserved.
//

import UIKit
import PopupDialog


extension UIViewController {

    func showErrorMsg(msg: String, title : String = "ESI Error"){
        let message = msg

        let popup = PopupDialog(title: title, message: message, image: nil)

        let buttonOne = DefaultButton(title: "Ok") {
            print("ESI Error pressed.")
        }

        popup.addButtons([buttonOne])

        self.present(popup, animated: true, completion: nil)
    }

}
