//
// Created by Tristan Pollard on 2017-10-14.
// Copyright (c) 2017 Sumo. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class ClonesViewController : UICharacterViewController, NVActivityIndicatorViewable{

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.startAnimating()

        self.character.loadClones(){
            self.character.clones.loadImplantNames() {
                self.stopAnimating()
            }
        }

    }

}

extension ClonesViewController : UITableViewDataSource, UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.character.clones.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.character.clones[section].implants!.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cloneCell", for: indexPath)

        return cell
    }
}
