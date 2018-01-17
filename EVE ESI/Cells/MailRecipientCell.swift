//
// Created by Tristan Pollard on 2017-10-05.
// Copyright (c) 2017 Sumo. All rights reserved.
//

import Eureka
import AlamofireImage

public final class MailRecipientCell : Cell<SearchResult>, CellType{
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var searchImageView: UIImageView!

    public override func setup() {
        super.setup()
        self.editingAccessoryType = .disclosureIndicator

        if let val = row.value {
            self.nameLabel.text = val.name
            self.nameLabel.textColor = UIColor.black
            let placeholderImg = UIImage(named: "characterPlaceholder64.jpg")!.af_imageRoundedIntoCircle().af_imageScaled(to: CGSize(width: 43, height: 43))
            let filter = ScaledToSizeCircleFilter(size: CGSize(width: 43, height: 43))
            self.searchImageView.af_setImage(withURL: val.imageUrlForSearchResult()!, placeholderImage: placeholderImg, filter: filter)
        }else{
            self.nameLabel.text = "To:"
            self.nameLabel.textColor = UIColor.lightGray
            self.searchImageView.image = UIImage(named: "characterPlaceholder64.jpg")!.af_imageRoundedIntoCircle().af_imageScaled(to: CGSize(width: 43, height: 43))
        }
    }

    public override func update() {
        super.update()
        self.searchImageView.af_cancelImageRequest()
        self.searchImageView.image = nil
        if let searchResult = self.row.value {
            let filter = ScaledToSizeCircleFilter(size: CGSize(width: 43, height: 43))
            self.searchImageView.af_setImage(withURL: searchResult.imageUrlForSearchResult()!, placeholderImage: searchResult.placeHolderForSearchResult()!.af_imageRoundedIntoCircle().af_imageScaled(to: CGSize(width: 43, height: 43)), filter: filter)
            self.nameLabel.text = searchResult.name
            self.nameLabel.textColor = UIColor.black
        }else{
            self.nameLabel.text = "To:"
            self.nameLabel.textColor = UIColor.lightGray
            self.searchImageView.image = UIImage(named: "characterPlaceholder64.jpg")!.af_imageRoundedIntoCircle().af_imageScaled(to: CGSize(width: 43, height: 43))
        }
    }


}

public final class MailRecipientRow: SelectorRow<MailRecipientCell>, RowType{
    required public init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<MailRecipientCell>(nibName: "MailSearchCell")
        presentationMode = .segueName(segueName: "sendMailToSearchRecipient", onDismiss: { vc in
            _ = vc.navigationController?.popViewController(animated: true)
        })
    }

    public override func prepare(for segue: UIStoryboardSegue) {
        if segue.identifier == "sendMailToSearchRecipient"{
            if let vc = segue.destination as? ReturnSearchViewController{
                if let name = self.value?.name {
                    vc.initString = name
                }
                vc.selectedCallback = { result in
                    self.value = result
                }
            }
        }
    }
}