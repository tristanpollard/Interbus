import UIKit
import Charts

class StatsViewController: UIViewController {

    var stats: Stats!
    var activeYear: Int?
    var activeStats: CharacterStats? {
        get {
            guard let year = activeYear else {
                return nil
            }

            return stats.stats.first(where: { $0.year == year })
        }
    }


    lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    lazy var deathsChart: PieChartView = {
        let chart = PieChartView()
        chart.translatesAutoresizingMaskIntoConstraints = false
        return chart
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        NSLayoutConstraint.activate([
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
        ])

        stats.fetchStats { stats, error in
            if let year = self.activeYear {
                if stats?.first(where: { $0.year == year }) == nil {
                    self.activeYear = stats?.last?.year
                }
            } else {
                self.activeYear = stats?.last?.year
            }
            DispatchQueue.main.async {
                self.navigationItem.rightBarButtonItems = [
                    UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(StatsViewController.yearSelect))
                ]
            }
        }
    }

    @objc
    func yearSelect() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        for stat in stats.stats {
            let year = stat.year
            let action = UIAlertAction(title: String(year), style: .default) { action in
                self.activeYear = year
            }
            alert.addAction(action)
        }
        present(alert, animated: true)
    }
}
