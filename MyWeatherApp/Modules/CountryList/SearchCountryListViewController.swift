//
//  SearchCountryListViewController.swift
//  MyWeatherApp
//
//  Created by Lan on 14/08/2018.
//  Copyright © 2018 Lan YU. All rights reserved.
//

import UIKit

class SearchCountryListViewController: UIViewController {

    // MARK: Properties
    
    fileprivate let countryList = Country.mr_findAll() as! [Country]
    fileprivate var countryListfilted = Country.mr_findAll() as! [Country]
    var allDataSource = NSDictionary()
    
    // MARK: IBOutlet
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension SearchCountryListViewController: UITableViewDelegate {
    
    // MARK: UITableViewDelegate Protocol
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


extension SearchCountryListViewController: UITableViewDataSource {
    
    // MARK: UITableViewDataSource Protocol
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.countryListfilted.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let country: Country = self.countryListfilted[indexPath.row]
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "CellID", for: indexPath)
        
        cell.textLabel?.text = "\(country.name!) (\(country.code!))"
        
        return cell
    }
}

extension SearchCountryListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.countryListfilted = self.fetchCountiesForQuery(searchText.lowercased())
        self.tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    fileprivate func fetchCountiesForQuery(_ query: String?) -> [Country] {
        guard let query = query, !query.isEmpty else { return self.countryList }
        let defaultContext: NSManagedObjectContext = NSManagedObjectContext.mr_rootSaving()
        let regex = String(format: ".*\\b%@.*", NSRegularExpression.escapedPattern(for: query))
        let predicate = NSPredicate(format: "(code BEGINSWITH[c] %@) OR (name MATCHES[cd] %@)", query, regex)
        let countries: [Country] = Country.mr_findAllSorted(by: "name", ascending: true, with: predicate, in: defaultContext) as! [Country]
   
        return countries
    }
}
