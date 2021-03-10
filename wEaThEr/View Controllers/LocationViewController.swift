//
//  ViewController.swift
//  wEaThEr
//
//  Created by Clara Jeon on 3/2/21.
//

import UIKit
import CoreLocation

class LocationViewController: UIViewController {

    
    
    @IBOutlet weak var locationTableView: UITableView!
    var latitudeArrayCopy = UserDefaults.standard.array(forKey: latitudeArray) as! [CLLocationDegrees]
    var longitudeArrayCopy = UserDefaults.standard.array(forKey: longitudeArray) as! [CLLocationDegrees]
    var cityArrayCopy = UserDefaults.standard.array(forKey: cityArray) as! [String]
    var basicInfoArray:[BasicInfo] = []
    var basicInfoArrayCorrectOrder:[BasicInfo?] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
        locationTableView.delegate = self
        locationTableView.dataSource = self
        locationTableView.register(UINib(nibName: "LocationTableViewCell", bundle: nil), forCellReuseIdentifier: "locationCell")
        getBasicWeatherForTableCell()
    }
    
    func getBasicInfo(from url:String, completion: @escaping (_ info: BasicInfo)->()){
        let task = URLSession.shared.dataTask(with: URL(string: url)!) { (data, response, error) in
            DispatchQueue.main.async {
                guard let data = data, error == nil else {
                    print("Something went wrong")
                    return
                }

                var weatherInfo: BasicInfo
                
                do {
                    try weatherInfo = JSONDecoder().decode(BasicInfo.self, from: data)
                    completion(weatherInfo)
                    
                }
                catch {
                    print("error when getting data")
                }

            }
            
        }
        
        task.resume()
    }
    
    func getBasicWeatherForTableCell(){
        
        basicInfoArray.removeAll()

        basicInfoArrayCorrectOrder.removeAll()
        
        basicInfoArrayCorrectOrder = [BasicInfo?] (repeating:nil, count: latitudeArrayCopy.count)
        
        for x in 0..<latitudeArrayCopy.count {
            
            let latitude = latitudeArrayCopy[x]
            let longitude = longitudeArrayCopy[x]
            let url = "https://api.openweathermap.org/data/2.5/onecall?lat=\(latitude)&lon=\(longitude)&exclude=minutely,hourly,daily,alerts&units=imperial&appid=\(weatherApiKey)"
            
            getBasicInfo(from: url) { (weatherInfo) in
                
                self.basicInfoArrayCorrectOrder[x] = weatherInfo
                self.basicInfoArray.append(weatherInfo)
                print(self.cityArrayCopy[x])
                print(weatherInfo.current.temp)
                
                print(self.basicInfoArray.count)
                if self.basicInfoArray.count == self.latitudeArrayCopy.count{
                    self.locationTableView.reloadData()
                }
            }
            
        }
        
    }

    struct BasicInfo: Codable {
        let lat, lon: Double
        let timezone: String
        let timezoneOffset: Int
        let current: Current

        enum CodingKeys: String, CodingKey {
            case lat, lon, timezone
            case timezoneOffset = "timezone_offset"
            case current
        }
    }

    // MARK: - Current
    struct Current: Codable {
        let dt, sunrise, sunset: Int
        let temp, feelsLike: Double
        let pressure, humidity: Int
        let dewPoint, uvi: Double
        let clouds, visibility: Int
        let windSpeed: Double
        let windDeg: Int
        let weather: [Weather]

        enum CodingKeys: String, CodingKey {
            case dt, sunrise, sunset, temp
            case feelsLike = "feels_like"
            case pressure, humidity
            case dewPoint = "dew_point"
            case uvi, clouds, visibility
            case windSpeed = "wind_speed"
            case windDeg = "wind_deg"
            case weather
        }
    }

    // MARK: - Weather
    struct Weather: Codable {
        let id: Int
        let main, weatherDescription, icon: String

        enum CodingKeys: String, CodingKey {
            case id, main
            case weatherDescription = "description"
            case icon
        }
    }
}

extension LocationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if basicInfoArray.count < cityArrayCopy.count ?? 100000 {
            return 0
        }
        print("ya\(cityArrayCopy.count)")
        print(basicInfoArray.count)
        return cityArrayCopy.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = locationTableView.dequeueReusableCell(withIdentifier: "locationCell") as! LocationTableViewCell
        
        let basicWeatherInfo = basicInfoArrayCorrectOrder[indexPath.row]
        
        cell.locationLabel.text = self.cityArrayCopy[indexPath.row]
        
        let dateFormatter = DateFormatter()
        let timezone = TimeZone(secondsFromGMT: basicWeatherInfo?.timezoneOffset ?? 0)
        dateFormatter.timeZone = timezone
        dateFormatter.dateFormat = "h:mm a"
        
        let date = Date(timeIntervalSince1970: Double(basicWeatherInfo?.current.dt ?? 0))
        let formattedTime = dateFormatter.string(from: date)
        cell.timeLabel.text = formattedTime.lowercased()
        let temp = Int(basicWeatherInfo?.current.temp ?? 34.0)
        cell.temperatureLabel.text = "\(temp)°"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "locationToWeather", sender: self)
    }

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.row != 0 {
            let action = UIContextualAction(style: .destructive, title: "delete location") { (action, view, completionHandler) in
                self.latitudeArrayCopy.remove(at: indexPath.row)
                self.longitudeArrayCopy.remove(at: indexPath.row)
                self.cityArrayCopy.remove(at: indexPath.row)
                
                UserDefaults.standard.setValue(self.cityArrayCopy, forKey: cityArray)
                UserDefaults.standard.setValue(self.latitudeArrayCopy, forKey: latitudeArray)
                UserDefaults.standard.setValue(self.longitudeArrayCopy, forKey: longitudeArray)
                
                self.getBasicWeatherForTableCell()
                completionHandler(true)
            }
            return UISwipeActionsConfiguration(actions: [action])
        }
        else {
            return UISwipeActionsConfiguration(actions: [])
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "locationToWeather" {
            let indexPath = locationTableView.indexPathForSelectedRow
            let weatherVC = segue.destination as! WeatherViewController
            weatherVC.arrayNumOfLocation = locationTableView.indexPathForSelectedRow!.row as! Int
        }
    }
    
}

