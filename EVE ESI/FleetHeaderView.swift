//
// Created by Tristan Pollard on 2018-02-17.
// Copyright (c) 2018 Sumo. All rights reserved.
//

import UIKit

class FleetHeaderView : UITableViewHeaderFooterView{
    
    @IBOutlet weak var deleteButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var deleteButton: UIButton!

    
    @IBOutlet weak var addButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var compositionLabel: UILabel!
    var delegate : FleetHeaderDelegate?

    var composition : EveFleet.FleetComposition?

    var isEditing = false
    
    @IBAction func addButtonTapped(_ sender: Any) {

        guard let comp = self.composition else{
            return
        }

        self.delegate?.addToComposition(comp)

    }

    @IBAction func deleteButtonTapped(_ sender: Any) {

        guard let comp = self.composition else{
            return
        }

        self.delegate?.removeComposition(comp)

    }

    func hideAdd(){
        self.addButtonWidth.constant = 0
        self.addButton.isHidden = true
        self.addButton.isEnabled = false
        self.layoutIfNeeded()
    }

    func showAdd(){
        self.addButtonWidth.constant = 40
        self.addButton.isEnabled = true
        self.addButton.isHidden = false
        self.layoutIfNeeded()
    }

    func hideDelete(){
        self.deleteButtonWidth.constant = 0
        self.deleteButton.isHidden = true
        self.deleteButton.isEnabled = false
        self.layoutIfNeeded()
    }

    func showDelete(){
        self.deleteButtonWidth.constant = 50
        self.deleteButton.isHidden = false
        self.deleteButton.isEnabled = true
        self.layoutIfNeeded()
    }
}

protocol FleetHeaderDelegate{

    func removeComposition(_ composition: EveFleet.FleetComposition)

    func addToComposition(_ composition : EveFleet.FleetComposition)

}
