//
//  StartingViewController.swift
//  wEaThEr
//
//  Created by Clara Jeon on 3/10/21.
//

import UIKit
import CoreLocation
import RadarSDK

class StartingViewController: UIViewController {

    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.locationManager.delegate = self
        self.requestLocationPermissions { (success) in
                if success {
                    print("YAYYY")
                    self.performSegue(withIdentifier: "startingToWeather", sender: self)
                }
        }
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
extension StartingViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.requestLocationPermissions { (success) in
            if success {
            self.performSegue(withIdentifier: "startingToWeather", sender: self)
            }
        }
    }
    
    func requestLocationPermissions(completion: @escaping (_ finished: Bool)->()) {
        let status = CLLocationManager.authorizationStatus()
        
        if status == .notDetermined {
            self.locationManager.requestWhenInUseAuthorization()
        }
        storeLocationToUserDefaults { (successStoring) in
            print("here")
            completion(true)
        }
        completion(false)
    }
    
    func storeLocationToUserDefaults(completion: @escaping (_ finished: Bool)->()) {
        if let location = locationManager.location?.coordinate {

            //storing user location to user defaults
            if var latitudeArrayCopy = UserDefaults.standard.array(forKey: latitudeArray) as? [CLLocationDegrees],
               var longitudeArrayCopy = UserDefaults.standard.array(forKey: longitudeArray) as? [CLLocationDegrees],
            var cityArrayCopy = UserDefaults.standard.array(forKey: cityArray) as? [String] {
                latitudeArrayCopy[0] = location.latitude
                longitudeArrayCopy[0] = location.longitude
                
                print("ye")
                Radar.reverseGeocode(location: CLLocation(latitude: location.latitude, longitude: location.longitude)) { (status, addresses) in
                    
                    let firstAddress = addresses![0]
                    print(firstAddress.city)
                    
                    cityArrayCopy[0] = firstAddress.city ?? "undefined city"
                    print("cityarray\(cityArrayCopy)")
                    
                    
                    UserDefaults.standard.setValue(latitudeArrayCopy, forKey: "latitudeArray")
                    UserDefaults.standard.setValue(longitudeArrayCopy, forKey: "longitudeArray")
                    UserDefaults.standard.setValue(cityArrayCopy, forKey: "cityArray")
                    completion(true)
                }
                //completion(false)
            }
            else {
                print("no")
                var latitudeArrayCopy:[CLLocationDegrees] = []
                var longitudeArrayCopy:[CLLocationDegrees] = []
                var cityArrayCopy:[String] = []
                
                latitudeArrayCopy.append(location.latitude)
                longitudeArrayCopy.append(location.longitude)
                Radar.reverseGeocode(location: CLLocation(latitude: location.latitude, longitude: location.longitude)) { (status, addresses) in
                    
                    let firstAddress = addresses![0]
                    print(firstAddress.city)
                    
                    print("appended")
                    cityArrayCopy.append(firstAddress.city ?? "undefined city")
                    
                    
                    UserDefaults.standard.setValue(latitudeArrayCopy, forKey: "latitudeArray")
                    UserDefaults.standard.setValue(longitudeArrayCopy, forKey: "longitudeArray")
                    UserDefaults.standard.setValue(cityArrayCopy, forKey: "cityArray")
                    
                    completion(true)
                    //self.load
                }
                //completion(false)
            }
        }
    }
}
