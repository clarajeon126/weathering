//
//  SearchViewController.swift
//  wEaThEr
//
//  Created by Clara Jeon on 3/7/21.
//

import UIKit
import RadarSDK

class SearchViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var resultTableView: UITableView!
    
    
    //arrays from user defaults
    var latitudeArrayCopy = UserDefaults.standard.array(forKey: latitudeArray) as! [CLLocationDegrees]
    var longitudeArrayCopy = UserDefaults.standard.array(forKey: longitudeArray) as! [CLLocationDegrees]
    var cityArrayCopy = UserDefaults.standard.array(forKey: cityArray) as! [String]
    
    //arrays for the search results
    var resultArray: [CLLocationCoordinate2D] = []
    var resultArrayLabels: [String] = []
    var resultCityArray: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        searchBar.delegate = self
        resultTableView.delegate = self
        resultTableView.dataSource = self
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = resultTableView.dequeueReusableCell(withIdentifier: "resultCell") as! SearchResultsTableViewCell
        cell.resultLabel.text = resultArrayLabels[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if !resultArray.isEmpty {
            
            let cityOfOneSelected = resultCityArray[indexPath.row]
            print(cityOfOneSelected)
            
            var repeatedCities = false
            for x in 0..<cityArrayCopy.count {
                if cityArrayCopy[x] == cityOfOneSelected {
                    repeatedCities = true
                    break
                }
            }
            
            if !repeatedCities {
                let locationOfOneSelected = resultArray[indexPath.row]
                
                //updating array in user defaults
                latitudeArrayCopy.append(locationOfOneSelected.latitude)
                longitudeArrayCopy.append(locationOfOneSelected.longitude)
                
                cityArrayCopy.append(cityOfOneSelected)
                UserDefaults.standard.setValue(cityArrayCopy, forKey: cityArray)
                UserDefaults.standard.setValue(latitudeArrayCopy, forKey: latitudeArray)
                UserDefaults.standard.setValue(longitudeArrayCopy, forKey: longitudeArray)
                
                performSegue(withIdentifier: "searchToLocation", sender: self)
            }
            else {
                let alert = UIAlertController(title: "already added city", message: "you have already added this location's city to your app.", preferredStyle: .alert)
                let action = UIAlertAction(title: "close", style: .cancel, handler: nil)
                alert.addAction(action)
                
                present(alert, animated: true, completion: nil)
            }
        }
        
    }
    
    
}

extension SearchViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        
        //queries for results and puts it in the resultArray
        if !searchText.isEmpty {
            
            let latitudeCoordinate = latitudeArrayCopy[0]
            print(latitudeCoordinate)
            let longitudeCoordinate = longitudeArrayCopy[0]
            print(longitudeCoordinate)
            
            self.resultArray.removeAll()
            self.resultArrayLabels.removeAll()
            self.resultCityArray.removeAll()
            
            
            Radar.autocomplete(query: searchText, near: CLLocation(latitude: latitudeCoordinate, longitude: longitudeCoordinate),limit: 9) { (status, addresses) in
                
                
                for x in 0..<addresses!.count {
                    let addressInQuestion = addresses![x]
                    self.resultArray.append(addressInQuestion.coordinate)
                    self.resultArrayLabels.append(addressInQuestion.formattedAddress ?? "no label found")
                    self.resultCityArray.append(addressInQuestion.city ?? "undefined city")
                }
                
                //reloads data to updated resultArray
                self.resultTableView.reloadData()
            }
        }
    }
}
