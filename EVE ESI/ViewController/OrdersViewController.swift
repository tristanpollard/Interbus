//
// Created by Tristan Pollard on 2017-10-14.
// Copyright (c) 2017 Sumo. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import AlamofireImage

class OrdersViewController : UICharacterViewController, NVActivityIndicatorViewable {
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.startAnimating()

        self.character.loadMarketOrders(){
            self.tableView.reloadData()

            for order in self.character.orders{
                debugPrint(order.id)
            }

            self.stopAnimating()
        }

    }
}

extension OrdersViewController: UITableViewDataSource, UITableViewDelegate{

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.character.orders.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "orderCell", for: indexPath)

        cell.imageView?.af_cancelImageRequest()
        cell.imageView?.image = nil

        let order = self.character.orders[indexPath.row]

        cell.textLabel?.text = String(describing: self.character.orders[indexPath.row].id)
        let placeHolder = UIImage(named: "characterPlaceholder64.jpg")!.af_imageRoundedIntoCircle().af_imageScaled(to: CGSize(width: 43, height: 43))
        let filter = ScaledToSizeCircleFilter(size: CGSize(width: 43, height: 43))
        cell.imageView?.af_setImage(withURL: order.imageURL(), placeholderImage: placeHolder, filter: filter)

        return cell
    }
}
