
//
//  HomeViewController.swift
//  MyWeatherApp
//
//  Created by Lan on 16/07/2018.
//  Copyright © 2018 Lan YU. All rights reserved.
//

import UIKit
import Reachability
import CoreLocation

class HomeViewController: BaseViewController {

    // MARK: - Typealias
    
    typealias RowItem = (rowID: String, cellID: String, text: String, detail: String?, subDetail: String?)
    
    // MARK: Enum
    
    fileprivate enum Section {
        //case city
        case main
        case fiveDays
        case sys
        case weather
        case anotherInfos
    }
    
    // MARK: Constants
    
    struct LocalConstants {
        static var customTitleTableViewCellID: String               =  "CustomTitleTableViewCellID"
        static var currentCityCellID: String                        =  "CurrentCityTableViewCellID"
        
        static var companySectionCellHeight: CGFloat                =  70.0
        static var professionalSituationSectionCellHeight: CGFloat  =  70.0
        static var submitSectionCellHeight: CGFloat                 =  70.0
        static var mendatorySectionCellHeight: CGFloat              =  65.0
        static var avatarSectionCellHeight: CGFloat                 =  148.0
        
        static let showSettingViewControllerSegueID: String         = "showSettingViewControllerSegueID"
        static let showSearchCountryListViewControllerID: String    = "showSearchCountryListViewControllerID"

    }
    
    // MARK: Properties
    
    fileprivate var sectionsAvailable: [Section] = []
    var currentCity: CurrentCity?
    var fiveDaysWeather: FewDaysWeather?
    let reachability: Reachability = Reachability()!
    
    // MARK: IBOutlet
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: IBAction
    
    @IBAction func settingButtonAction() {
        self.performSegue(withIdentifier: LocalConstants.showSettingViewControllerSegueID, sender: nil)
    }
    
    @IBAction func searchButtonAction() {
        self.performSegue(withIdentifier: LocalConstants.showSearchCountryListViewControllerID, sender: nil)
    }
    
    // MARK: Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "hello"
        
        self.isTabBarTranparent = true
        
        //PreprocessingCityList().loadJson()
        PreprocessingCountryList().loadJson()
        //let language = LanguageManager.sharedInstanc.
//        let completion: (Bool, String?) -> Void = { (isZipCode, zipCode) in
//            print("zipcode: \(zipCode ?? "")")
//            if let country: Country = Country.mr_findFirst(byAttribute: "code", withValue: zipCode as Any), let countryName = country.name {
//                self.navigationItem.title = countryName
//            }
//            let fetch5daysOrCurrentCityWeatherStruct: Fetch5daysOrCurrentCityWeatherStruct = Fetch5daysOrCurrentCityWeatherStruct(cityName: nil, countryCode: zipCode, cityId: nil, lat: nil, lon: nil, zipCode: "93500", units: Constants.Temperature.Unit.metric.rawValue, isCall5SaysResquest: false)
//            self.fetchCurrentCityWeather(fetch5daysOrCurrentCityWeatherStruct)
//        }
//        self.getCountryCodeByZipCode("93500", completion: completion)
        
        self.sectionsAvailable = []
        let fetchCurrentCityWeatherStruct: Fetch5daysOrCurrentCityWeatherStruct = Fetch5daysOrCurrentCityWeatherStruct(cityName: nil, countryCode: "us", cityId: nil, lat: nil, lon: nil, zipCode: "94040", units: Constants.Temperature.Unit.metric.rawValue, isCall5SaysResquest: false)
        self.fetchCurrentCityWeather(fetchCurrentCityWeatherStruct)
        let fetch5daysStruct: Fetch5daysOrCurrentCityWeatherStruct = Fetch5daysOrCurrentCityWeatherStruct(cityName: nil, countryCode: "us", cityId: nil, lat: nil, lon: nil, zipCode: "94040", units: Constants.Temperature.Unit.metric.rawValue, isCall5SaysResquest: true)
        self.fetch5daysWeather(fetch5daysStruct)
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: self.reachability)
        do{
            try reachability.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.reachability.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: self.reachability)
    }

    
    // MARK: reachability Changed
    
    @objc func reachabilityChanged(note: Notification) {
        
        let reachability = note.object as! Reachability
        
        switch reachability.connection {
        case .wifi:
            print("Reachable via WiFi")
        case .cellular:
            print("Reachable via Cellular")
        case .none:
            print("Network not reachable")
        }
    }
    
    // MARK: Functions
    
    func getCountryCodeByZipCode(_ zipCode: String, completion: @escaping (Bool, String?) -> Void) {
        let geocoder = CLGeocoder()
        
        let completionHandler: CLGeocodeCompletionHandler = { (placemarks, error) in
            guard error == nil, let placemarks = placemarks else {
                print("can't find the city name by zip Code with error: \(error?.localizedDescription ?? ""))")
                return completion(false, error?.localizedDescription)
            }
            for placemark in placemarks {
                print("city :\(placemark.locality ?? "anything")")
                print("country :\(placemark.country ?? "anything")")
                print("country :\(placemark.isoCountryCode ?? "anything")")
                return completion(true, placemark.isoCountryCode)
            }
        }
        
        geocoder.geocodeAddressString(zipCode, completionHandler: completionHandler)
    }

    fileprivate func fetchCurrentCityWeather(_ fetch5daysOrCurrentCityWeatherStruct: Fetch5daysOrCurrentCityWeatherStruct) {
        
        let successClosure: (Any) -> Void = { json in
            SVProgressHUD.dismiss()
            print("currentCityJson \(json) ")
            let context = CoreDataApplicationContext.rootSaveContext
            self.currentCity = CurrentCity.managedObject(JSON: json, withContext: context)
            //            let flights: [SM_Flight] = [SM_Flight](withJson: json)
            //            ADPDispatch.async {
            //                success?(flights)
            //            }
            print("currentCity :\(self.currentCity?.base ?? "") - \(self.currentCity?.currentCityWind?.degrees) - \(self.currentCity?.currentCityWeatherInfo)")
            
            //self.sectionsAvailable = [.city, .main, .sys, .weather, .anotherInfos]
            
            self.sectionsAvailable.insert(.main, at: 0)
            DispatchQueue.main.async {
                self.navigationItem.title = "\(self.currentCity?.name)(\(self.currentCity?.currentCitySys?.country)"
                self.tableView.reloadData()
            }
            
        }
        let failureClosure: (HTTPService.HTTPResponseFailureReason) -> () = { reason in
            print("reason \(reason)")
            SVProgressHUD.dismiss()
            //            ADPDispatch.async {
            //                failure?(reason)
            //            }
        }
        
        SVProgressHUD.setDefaultStyle(.custom)
        SVProgressHUD.setDefaultMaskType(.custom)
        SVProgressHUD.show()
    
        HTTPManager.fetchCurrentCityWeather(fetch5daysOrCurrentCityWeatherStruct, success: successClosure, failure: failureClosure)
    }
    
    fileprivate func fetch5daysWeather(_ fetch5daysOrCurrentCityWeatherStruct: Fetch5daysOrCurrentCityWeatherStruct) {
        
        let successClosure: (Any) -> Void = { json in
            SVProgressHUD.dismiss()
            print(json)
            let context = CoreDataApplicationContext.rootSaveContext
            self.fiveDaysWeather = FewDaysWeather.managedObject(JSON: json, withContext: context)
            //            let flights: [SM_Flight] = [SM_Flight](withJson: json)
            //            ADPDispatch.async {
            //                success?(flights)
            //            }
            print("fiveDaysWeather :\(self.fiveDaysWeather?.weatherList)")
            
            //self.sectionsAvailable = [.city, .main, .sys, .weather, .anotherInfos]
            self.sectionsAvailable.append(.fiveDays)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        }
        let failureClosure: (HTTPService.HTTPResponseFailureReason) -> () = { reason in
            print("reason \(reason)")
            SVProgressHUD.dismiss()
            //            ADPDispatch.async {
            //                failure?(reason)
            //            }
        }
        
        SVProgressHUD.setDefaultStyle(.custom)
        SVProgressHUD.setDefaultMaskType(.custom)
        SVProgressHUD.show()

        HTTPManager.fetchCurrentCityWeather(fetch5daysOrCurrentCityWeatherStruct, success: successClosure, failure: failureClosure)
    }
    
    fileprivate var tileSetJSON: JSON? {
        guard let path = Bundle.main.path(forResource: "tileSets", ofType: "json"),
            let string = try? String(contentsOfFile: path, encoding: String.Encoding.utf8) else {
                return nil
        }
        let json = JSON(parseJSON: string)
        return json
    }
    
    //MARK: Rows for item outside because we need to acces a dynamic list
    
    fileprivate func rowsForSection(_ section: Section) -> [RowItem] {
        switch section {
        case .main:
            var rows: [RowItem] = []
            guard let currentCity = self.currentCity, let sys = currentCity.currentCitySys else { return rows }
            let nameRow = RowItem(LocalConstants.customTitleTableViewCellID, LocalConstants.customTitleTableViewCellID, "City", sys.country, currentCity.name)
            rows.append(nameRow)
            if let currentCityCoord = currentCity.currentCityCoord {
                let coordinateRow = RowItem(LocalConstants.customTitleTableViewCellID, LocalConstants.customTitleTableViewCellID, "Coordonne", "\(currentCityCoord.latitude)", "\(currentCityCoord.longitude)")
                rows.append(coordinateRow)
            }
            
            let sunrise = (sys.sunrise != nil) ? sys.sunrise!.toDayMonthAndYear() : "Information Nnavailable"
            let sunset = (sys.sunset != nil) ? sys.sunset!.toDayMonthAndYear() : "Information Nnavailable"
            let sunRow = RowItem(LocalConstants.customTitleTableViewCellID, LocalConstants.customTitleTableViewCellID, "Sun", sunrise, sunset)
            rows.append(sunRow)
            
            return rows
            
        case .fiveDays:
            var rows: [RowItem] = []
            guard let fiveDaysWeather = self.fiveDaysWeather else { return rows }
        
            let nameRow = RowItem(LocalConstants.customTitleTableViewCellID, LocalConstants.customTitleTableViewCellID, "City", String(fiveDaysWeather.cnt.doubleValue), String(fiveDaysWeather.message))
            rows.append(nameRow)
            
            guard let list = fiveDaysWeather.weatherList else { return rows }
            
            list.forEach { (weather) in
                if let weather = weather as? OneDayWeatherInfo {
                    let sunRow = RowItem(LocalConstants.customTitleTableViewCellID, LocalConstants.customTitleTableViewCellID, weather.dt_txt!, weather.oneDayDetail?.city.name, "\(String(describing: weather.oneDayMain?.temp))")
                    rows.append(sunRow)
                }
            }
            
            return rows
            
        
            
//        case .weather:
//            let rows: [RowItem] = [(LocalConstants.companySectionRowID, LocalConstants.companySectionRowID, localizedString("business_membership_mandatory_info"), "")]
//            return rows
//
//        case .anotherInfos:
//            let rows: [RowItem] = [(LocalConstants.companySectionRowID, LocalConstants.companySectionRowID, "", "")]
//            return rows
        default: return []
        }
    }
}

extension HomeViewController: UITableViewDelegate {
    // MARK: UITableViewDelegate Protocol
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        let sectionItem: Section = self.sectionsAvailable[indexPath.section]
//        let rowItem: RowItem = self.rowsForSection(sectionItem)[indexPath.row]
//
//        switch sectionItem {
//        case .airline:
//            return  Constants.defaultAirlineTableViewCellHeight
//        case .destination where rowItem.rowID == Constants.destinationHeadCellID:
//            return  Constants.defaultAirlineTableViewCellHeight + 10
//        default:
//            return Constants.defaultDestinationTableViewCellHeight
//        }
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


extension HomeViewController: UITableViewDataSource {
    
    // MARK: UITableViewDataSource Protocol
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sectionsAvailable.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionItem: Section = self.sectionsAvailable[section]
        return self.numberOfRowForSection(sectionItem)
    }
    
    fileprivate func numberOfRowForSection(_ section: Section) -> Int {
        print("count \(section) \(self.rowsForSection(section).count)")
        return self.rowsForSection(section).count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionItem: Section = self.sectionsAvailable[indexPath.section]
        let rowItem: RowItem = self.rowsForSection(sectionItem)[indexPath.row]
        print("sectionItem \(sectionItem)")

        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: rowItem.cellID, for: indexPath)
      
        self.configureCell(cell as! CustomTitleTableViewCell, withItem: rowItem)
//        switch sectionItem {
//        case .airline where rowItem.rowID == Constants.callPhoneRowID:
//            self.configurePhoneCell(cell as! AirlineDetailPhoneTableViewCell, withItem: rowItem)
//        default:
//            self.configureCell(cell as! RightDetailTableViewCell, withItem: rowItem)
//        }
        
        return cell
    }
    
    // MARK: Cell Configuration
    
    func configureCell(_ cell: CustomTitleTableViewCell, withItem item: RowItem) {
        cell.titleLabel.text = item.text
        cell.detailTitleLabel.text = "detailTitle"
        cell.detail2TitleLable.text = "detail2Title"
        cell.detailLable.text = item.subDetail
        cell.detail2Lable.text = item.detail
    }
//
//    func configurePhoneCell(_ cell: AirlineDetailPhoneTableViewCell, withItem item: RowItem) {
//        cell.setButtonAttributedTitle("  " + localizedString("flights_flight_details_call_company"))
//    }
}


//class func fetch(_ flightSearchStruct: FetchFlightStruct,
//                        success: (([SM_Flight]) -> ())? = nil,
//                        failure: ((HTTPService.HTTPResponseFailureReason) -> ())? = nil) {
//    
//    let successClosure: (Any) -> Void = { json in
//        let flights: [SM_Flight] = [SM_Flight](withJson: json)
//        ADPDispatch.async {
//            success?(flights)
//        }
//    }
//    
//    let failureClosure: (HTTPService.HTTPResponseFailureReason) -> () = { reason in
//        ADPDispatch.async {
//            failure?(reason)
//        }
//    }
//    
//    HTTPManager.fetchFlights(flightSearchStruct, success: successClosure, failure: failureClosure)
//}
