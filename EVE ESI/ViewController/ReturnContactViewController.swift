//
// Created by Tristan Pollard on 2017-10-06.
// Copyright (c) 2017 Sumo. All rights reserved.
//

import UIKit

class ReturnContactViewController : ReturnSearchViewController{

    @IBOutlet weak var standingSlider: UISlider!
    @IBOutlet weak var standingLabel: UILabel!
    var selectedStandingCallback: ((SearchResult, Float) -> (Void))?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.standingLabel.text = String(standingSlider.value)
    }

    @IBAction func sliderChanged(_ sender: Any) {
        let step: Float = 5.0
        let roundedValue = round(standingSlider.value / step) * step
        standingSlider.value = roundedValue
        self.standingLabel.text = String(standingSlider.value)
    }

    override func callback() {
        self.selectedStandingCallback?(self.selectedResult!, self.standingSlider.value)
    }
}
