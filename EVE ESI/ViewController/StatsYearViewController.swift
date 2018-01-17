//
// Created by Tristan Pollard on 2017-12-18.
// Copyright (c) 2017 Sumo. All rights reserved.
//

import UIKit
import Charts

class StatsYearViewController : UICharacterViewController{

    var year : Int64!
    var yearStats = [String:Int64]()
    var sortedKeys = [String]()
//    @IBOutlet weak var statsTable: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var miningChart: PieChartView!
    @IBOutlet weak var repairChart: BarChartView!
    @IBOutlet weak var dmgDoneChart: RadarChartView!
    
    @IBOutlet weak var bc2: BarChartView!
    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.contentSize = contentView.bounds.size
        debugPrint(scrollView.contentSize)

        self.title = String(year)
        self.yearStats = self.character.stats.first(where: {$0["year"] == year})!
        self.sortedKeys = Array(self.yearStats.keys).sorted(by: {$0 < $1})
        debugPrint(yearStats)

        var miningEntries = [PieChartDataEntry]()

        var armorEntries = [BarChartDataEntry]()
        var shieldEntries = [BarChartDataEntry]()
        var capEntries = [BarChartDataEntry]()

        var dmgDoneEntries = [RadarChartDataEntry]()
        
        for key in self.sortedKeys {
            if key.range(of: "mining_ore_") != nil { //mining
                let entry = PieChartDataEntry(value: Double(self.yearStats[key]!), label: key)
                miningEntries.append(entry)
            }
        }

        armorEntries.append(BarChartDataEntry(x: 0, yValues: [statForKey("combat_repair_armor_by_remote_amount")], label: "Armor Received"))
        shieldEntries.append(BarChartDataEntry(x: 0, yValues: [statForKey("combat_repair_shield_by_remote_amount")], label: "Shield Received"))
        capEntries.append(BarChartDataEntry(x: 0, yValues: [statForKey("combat_repair_capacitor_by_remote_amount")], label: "Cap Received"))

        armorEntries.append(BarChartDataEntry(x: 1, yValues: [statForKey("combat_repair_armor_remote_amount")], label: "Armor Sent"))
        shieldEntries.append(BarChartDataEntry(x: 1, yValues: [statForKey("combat_repair_shield_remote_amount")], label: "Shield Sent"))
        capEntries.append(BarChartDataEntry(x: 1, yValues: [statForKey("combat_repair_capacitor_remote_amount")], label: "Cap Sent"))

        armorEntries.append(BarChartDataEntry(x: 2, yValues: [statForKey("combat_repair_armor_self_amount")], label: "Local armor"))
        shieldEntries.append(BarChartDataEntry(x: 2, yValues: [statForKey("combat_repair_shield_self_amount")], label: "Local Shield"))
        capEntries.append(BarChartDataEntry(x: 2, yValues: [statForKey("combat_repair_capacitor_self_amount")], label: "Cap Boosted"))

        dmgDoneEntries.append(RadarChartDataEntry(value: statForKey("combat_damage_to_players_energy_amount")))
        dmgDoneEntries.append(RadarChartDataEntry(value: statForKey("combat_damage_to_players_projectile_amount")))
        dmgDoneEntries.append(RadarChartDataEntry(value: statForKey("combat_damage_to_players_hybrid_amount")))
        dmgDoneEntries.append(RadarChartDataEntry(value: statForKey("combat_damage_to_players_missile_amount")))
        dmgDoneEntries.append(RadarChartDataEntry(value: statForKey("combat_damage_to_players_combat_drone_amount")))

        let dmgDoneSet = RadarChartDataSet(values: dmgDoneEntries, label: "Damage Done")
        dmgDoneSet.setColor(.green)

        let dmgDoneData = RadarChartData(dataSet: dmgDoneSet)

        self.dmgDoneChart.data = dmgDoneData


        let armorSet = BarChartDataSet(values: armorEntries, label: "Armor")
        armorSet.setColor(.red)
        let shieldSet = BarChartDataSet(values: shieldEntries, label: "Shield")
        shieldSet.setColor(.blue)
        let capSet = BarChartDataSet(values: capEntries, label: "Cap")
        capSet.setColor(.orange)

        let repairData = BarChartData(dataSets: [shieldSet, armorSet, capSet])

        let groupSpace = 0.08
        let barSpace = 0.03
        let barWidth = 0.2

        repairData.barWidth = barWidth

        self.repairChart.xAxis.axisMinimum = 0
        self.repairChart.xAxis.axisMaximum = repairData.groupWidth(groupSpace: groupSpace, barSpace: barSpace) * Double(repairData.dataSets.count)
        self.repairChart.data = repairData
        self.repairChart.groupBars(fromX: 0, groupSpace: groupSpace, barSpace: barSpace)

        self.bc2.data = repairData

        let miningSet = PieChartDataSet(values: miningEntries, label: nil)
        miningSet.setRandomColors()

        let miningData = PieChartData(dataSet: miningSet)
        miningSet.drawValuesEnabled = false


        self.miningChart.drawSliceTextEnabled = false
        self.miningChart.highlightPerTapEnabled = true

        self.miningChart.data = miningData
        self.miningChart.chartDescription?.enabled = false

        let marker = BalloonMarker(color: UIColor(white: 180/255, alpha: 1),
                font: .systemFont(ofSize: 12),
                textColor: .white,
                insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8))

        marker.chartView = self.miningChart
        marker.minimumSize = CGSize(width: 80, height: 40)
        self.miningChart.marker = marker
        
    }
    
    func statForKey(_ key : String) -> Double{
        if let stat = self.yearStats[key]{
            return Double(stat)
        }
        
        return 0
    }

}

extension StatsYearViewController : UITableViewDataSource, UITableViewDelegate{

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return yearStats.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "statsCell", for: indexPath)

        let key = keyForIndex(indexPath: indexPath)
        let value = self.yearStats[key]!

        cell.textLabel?.text = key
        cell.detailTextLabel?.text = String(value)

        return cell
    }

    func keyForIndex(indexPath: IndexPath) -> String{
        return self.sortedKeys[indexPath.row]
    }

}
