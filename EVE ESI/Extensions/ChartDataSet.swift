//
// Created by Tristan Pollard on 2017-12-19.
// Copyright (c) 2017 Sumo. All rights reserved.
//

import Foundation
import Charts

extension ChartDataSet{

    func setRandomColors(){
        for i in 0..<self.entryCount {

            let red = Double(arc4random_uniform(256))
            let green = Double(arc4random_uniform(256))
            let blue = Double(arc4random_uniform(256))

            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            self.colors.append(color)
        }
    }

}
