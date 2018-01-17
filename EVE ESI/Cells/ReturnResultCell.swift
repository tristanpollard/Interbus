//
// Created by Tristan Pollard on 2017-10-06.
// Copyright (c) 2017 Sumo. All rights reserved.
//

import Eureka
import AlamofireImage

public final class ReturnResultCell: Cell<SearchResult>, CellType {

    @IBOutlet weak var resultImageView: UIImageView!
    @IBOutlet weak var resultLabel: UILabel!

    public override func setup() {
        super.setup()
        self.accessoryType = .disclosureIndicator

        if let value = self.row.value {
            self.resultLabel.text = value.name
            let filter = ScaledToSizeCircleFilter(size: CGSize(width: 43, height: 43))
            let placeHolder = value.placeHolderForSearchResult()!.af_imageRoundedIntoCircle().af_imageScaled(to: CGSize(width: 43, height: 43))
            self.resultImageView.af_setImage(withURL: value.imageUrlForSearchResult()!, placeholderImage: value.placeHolderForSearchResult(), filter: filter)
        }else{
            self.resultImageView.image = UIImage(named: "characterPlaceholder64.jpg")!.af_imageRoundedIntoCircle().af_imageScaled(to: CGSize(width: 43, height: 43))
        }
    }

    public override func update() {
        super.update()

        if let value = self.row.value {
            self.resultLabel.text = value.name
            let filter = ScaledToSizeCircleFilter(size: CGSize(width: 43, height: 43))
            let placeHolder = value.placeHolderForSearchResult()!.af_imageRoundedIntoCircle().af_imageScaled(to: CGSize(width: 43, height: 43))
            self.resultImageView.af_setImage(withURL: value.imageUrlForSearchResult()!, placeholderImage: value.placeHolderForSearchResult(), filter: filter)
        }else{
            self.resultImageView.image = UIImage(named: "characterPlaceholder64.jpg")!.af_imageRoundedIntoCircle().af_imageScaled(to: CGSize(width: 43, height: 43))
        }
    }
}

public final class ReturnResultRow: SelectorRow<ReturnResultCell>, RowType{

    required public init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<ReturnResultCell>(nibName: "ReturnContactCell")
    }
}