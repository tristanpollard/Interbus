//
// Created by Tristan Pollard on 2018-02-14.
// Copyright (c) 2018 Sumo. All rights reserved.
//

import UIKit

class AssetHeaderView : UITableViewHeaderFooterView{

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var selectedLabel: UILabel!

    var location : Int64 = 0
    var delegate : AssetHeaderViewDelegate?

    static var height : CGFloat = CGFloat(40)

    @objc func headerTapped(){
        self.delegate?.locationToggled(header: self, location: self.location)
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(headerTapped)))
    }

    func rotateSelectedLabel(isShowing : Bool, doneAnimation : @escaping() -> ()){

        UIView.animate(withDuration: 0.3, animations: {
            self.selectedLabel.transform = CGAffineTransform(rotationAngle: isShowing ? 0 : .pi)
        }, completion: { finished in
            doneAnimation()
        })
    }

}
