//
//  SettingViewController.swift
//  MyWeatherApp
//
//  Created by Lan on 31/07/2018.
//  Copyright © 2018 Lan YU. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {

    // MARK: - Typealias
    
    typealias RowItem = (rowID: String, cellID: String, text: String, detail: String?)
    
    // MARK: Properties
    
    @IBOutlet weak var tableView: UITableView!
    fileprivate var rowsAvailable: [RowItem] = []
    
    // MARK: Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getRows()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    
    fileprivate func getRows() {
        let firstRow = RowItem("", "CellID", "Langage", "francais")
        let secondRow = RowItem("", "CellID", "Infos", "Infos")
        let thirdRow = RowItem("", "CellID", "Another", "Another")
        self.rowsAvailable = [firstRow, secondRow, thirdRow]
    }
}


extension SettingViewController: UITableViewDelegate {
    // MARK: UITableViewDelegate Protocol
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


extension SettingViewController: UITableViewDataSource {
    
    // MARK: UITableViewDataSource Protocol
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rowsAvailable.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let rowItem: RowItem = self.rowsAvailable[indexPath.row]
        
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: rowItem.cellID, for: indexPath)
        cell.textLabel?.text = rowItem.text
        cell.detailTextLabel?.text = rowItem.detail
        
        return cell
    }
    
    // MARK: Cell Configuration
    
//    func configureCell(_ cell: CustomTitleTableViewCell, withItem item: RowItem) {
//        cell.titleLabel.text = item.text
//        cell.detailTitleLabel.text = "detailTitle"
//        cell.detail2TitleLable.text = "detail2Title"
//        cell.detailLable.text = item.subDetail
//        cell.detail2Lable.text = item.detail
//    }
    //
    //    func configurePhoneCell(_ cell: AirlineDetailPhoneTableViewCell, withItem item: RowItem) {
    //        cell.setButtonAttributedTitle("  " + localizedString("flights_flight_details_call_company"))
    //    }
}
