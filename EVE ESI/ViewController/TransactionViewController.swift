import UIKit
import NVActivityIndicatorView
import AlamofireImage

class TransactionViewController : UICharacterViewController, NVActivityIndicatorViewable{

    @IBOutlet weak var transactionTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.startAnimating()

        let group = DispatchGroup()

        group.enter()
        self.character.loadTransactions{
            self.character.transactions.loadNames() {
                group.leave()
            }
        }

        group.enter()
        self.character.loadWalletJournal{
            group.leave()
        }

        group.notify(queue: .main){
            self.stopAnimating()
            self.transactionTable.reloadData()
        }

    }
    
}

extension TransactionViewController : UITableViewDataSource, UITableViewDelegate{

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.character.transactions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "transactionCell", for: indexPath)

        cell.imageView?.af_cancelImageRequest()
        cell.imageView?.image = nil

        let transaction = self.character.transactions[indexPath.row]

        cell.textLabel?.text = String(transaction.name)
        cell.detailTextLabel?.text = String(transaction.quantity!)
        let placeholder = UIImage(named: "alliancePlaceholder64.png")?.af_imageRoundedIntoCircle().af_imageScaled(to: CGSize(width: 43, height: 43))
        let filter = ScaledToSizeCircleFilter(size: CGSize(width: 43, height: 43))
        cell.imageView?.af_setImage(withURL: transaction.imageURL(), placeholderImage: placeholder, filter: filter)

        return cell

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let transaction = self.character.transactions[indexPath.row]

        let journal = self.character.journal.first(where: {$0.ref_id == transaction.journal_ref_id})

        debugPrint(transaction.name)
        debugPrint(transaction.quantity)

        self.transactionTable.deselectRow(at: indexPath, animated: true)

    }
}
