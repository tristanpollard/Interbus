////
//// Created by Tristan Pollard on 2017-10-05.
//// Copyright (c) 2017 Sumo. All rights reserved.
////
//

import Eureka

public final class MailRecipientCell: Cell<EveSearchResult>, CellType {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var searchImageView: UIImageView!

    public override func setup() {
        super.setup()
        self.editingAccessoryType = .disclosureIndicator
        self.searchImageView.roundImageWithBorder(color: .clear)
        self.searchImageView.image = UIImage(named: "characterPlaceholder64.jpg")!

        if let val = row.value {
            self.nameLabel.text = val.name?.name
            self.nameLabel.textColor = UIColor.black
            self.searchImageView.fetchAndSetImage(eve: val)
        } else {
            self.nameLabel.text = "To:"
            self.nameLabel.textColor = UIColor.lightGray
        }
    }

    public override func update() {
        super.update()
        self.searchImageView.image = nil
        self.searchImageView.image = UIImage(named: "characterPlaceholder64.jpg")!
        if let searchResult = self.row.value {
            self.searchImageView.fetchAndSetImage(eve: searchResult) {
            }
            self.nameLabel.text = searchResult.name?.name
            self.nameLabel.textColor = UIColor.black
        } else {
            self.nameLabel.text = "To:"
            self.nameLabel.textColor = UIColor.lightGray
        }
    }


}

public final class MailRecipientRow: SelectorRow<MailRecipientCell>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<MailRecipientCell>(nibName: "MailSearchCell")
        presentationMode = .segueName(segueName: "sendMailToMailRecipient", onDismiss: { vc in
            _ = vc.navigationController?.popViewController(animated: true)
        })
    }

    public override func prepare(for segue: UIStoryboardSegue) {
        if let vc = segue.destination as? MailRecipientViewController {
            vc.selectItem = { result in
                self.value = result
            }
        }
    }
}