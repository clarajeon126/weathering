//
//  WeatherViewController.swift
//  wEaThEr
//
//  Created by Clara Jeon on 3/2/21.
//

import UIKit
import CoreLocation
import RadarSDK

//just in case, for spelling mistakes regarding user default keys
public var latitudeArray = "latitudeArray"
public var longitudeArray = "longitudeArray"
public var cityArray = "cityArray"
public var weatherApiKey = "6fc892085226aeeaf9fe3bb5a92927c3"
class WeatherViewController: UIViewController {

    let sunIcon = UIImage.init(systemName: "sun.min")
    let moonIcon = UIImage.init(systemName: "moon")
    let slightlyCloudyDayIcon = UIImage.init(systemName: "cloud.sun")
    let slightlyCloudyNightIcon = UIImage.init(systemName: "cloud.moon")
    let cloudy = UIImage.init(systemName: "cloud")
    let rainyIcon = UIImage.init(systemName: "cloud.rain")
    let snowIcon = UIImage.init(systemName: "snow")
    let thunderIcon = UIImage.init(systemName: "cloud.bolt")
    
    var arrayNumOfLocation = 0
    
    @IBOutlet weak var dateAndGreetingLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var mainTempLabel: UILabel!
    @IBOutlet weak var sunriseSetLabel: UILabel!
    
    @IBOutlet weak var feelsLikeLabel: UILabel!
    
    @IBOutlet weak var backgroundImage: UIImageView!
    //hourly stack view
    @IBOutlet var hourlyStackView: [UIStackView]!
    
    //daily stack view
    @IBOutlet var dailyStackView: [UIStackView]!
    
    
    //collection for hourly time name
    @IBOutlet var hourlyTimeName: [UILabel]!
    
    //hourly image view
    @IBOutlet var hourlyImageView: [UIImageView]!
    
    //hourly temp
    @IBOutlet var hourlyTemp: [UILabel]!
    
    
    //collection for daily name
    @IBOutlet var dailyName: [UILabel]!
    
    //daily image view
    @IBOutlet var dailyImageView: [UIImageView]!
    
    //daily highLow
    @IBOutlet var dailyHighLow: [UILabel]!
    
    
    @IBOutlet weak var mainIconImageView: UIImageView!

    //arrays from user defaults
    var latitudeArrayCopy = UserDefaults.standard.array(forKey: latitudeArray) as? [CLLocationDegrees] ?? [CLLocationDegrees(0)]
    var longitudeArrayCopy = UserDefaults.standard.array(forKey: longitudeArray) as? [CLLocationDegrees] ?? [CLLocationDegrees(0)]
    var cityArrayCopy = UserDefaults.standard.array(forKey: cityArray) as? [String] ?? ["Prime Meridian"]
    
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewDidLoad()

        let hourDayBgColor = UIColor(red: 115/255, green: 105/255, blue: 128/255, alpha: 0.58)
        locationLabel.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
        // Do any additional setup after loading the view.
        
        for count in 0..<hourlyStackView.count {
            hourlyStackView[count].layer.cornerRadius = 15
            hourlyStackView[count].backgroundColor = hourDayBgColor
        }
        
        for count in 0..<dailyStackView.count {
            dailyStackView[count].layer.cornerRadius = 15
            dailyStackView[count].backgroundColor = hourDayBgColor
        }
        
        //getting relative info from the user default array
        
        let latitude = latitudeArrayCopy[arrayNumOfLocation]
        let longitude = longitudeArrayCopy[arrayNumOfLocation]
        let city = cityArrayCopy[arrayNumOfLocation] ?? "current location"
        locationLabel.text = city
        
        let weatherApiUrl = "https://api.openweathermap.org/data/2.5/onecall?lat=\(latitude)&lon=\(longitude)&exclude=minutely,alerts&units=imperial&appid=\(weatherApiKey)"
        
        getWeatherDataImperial(from: weatherApiUrl) { (weatherInfo) in
            DispatchQueue.main.async {
                
                //setting all of current info
                let currentInfo = weatherInfo.currentWeather
                self.changeBackGround(icon: currentInfo.icon, sectionName: currentInfo.sectionOfDay)
                self.dateAndGreetingLabel.text = "\(currentInfo.dateInString)\n\(currentInfo.sectionOfDay)"
                self.mainTempLabel.text = "\(currentInfo.temp)°"
                print(currentInfo.sunriseFormatted)
                print(currentInfo.sunsetFormatted)
                
                let sunriseLabelText = "sunrise: \(currentInfo.sunriseFormatted)\nsunset: \(currentInfo.sunsetFormatted)"
                
                print(sunriseLabelText)
                self.sunriseSetLabel.text = sunriseLabelText
                
                self.feelsLikeLabel.text = "feels\nlike\n\(currentInfo.feelsLike)°"
                self.mainIconImageView.image =
                self.returnRelevantIcon(icon: currentInfo.icon)
                
                
                //setting daily info
                let dailyArray = weatherInfo.dailyArray
                for y in 0...7 {
                    let dayInQuestion = dailyArray[y]
                    
                    let dailyIcon = self.returnRelevantIcon(icon: dayInQuestion.icon)
                    self.dailyImageView[y].alpha = 0.5
                    self.dailyImageView[y].image = dailyIcon
                    self.dailyName[y].text = " \(dayInQuestion.weekday)"
                    self.dailyHighLow[y].text = "\(dayInQuestion.high)° | \(dayInQuestion.low)°  "
                    
                }
                
                
                //setting hourly info
                let hourArray = weatherInfo.hourlyArray
                for x in 0..<12 {
                    let hourInQuestion = hourArray[x]
                    
                    let hourlyIcon = self.returnRelevantIcon(icon: hourInQuestion.icon)
                    self.hourlyImageView[x].alpha = 0.5
                    self.hourlyImageView[x].image = hourlyIcon
                    self.hourlyTemp[x].text = "\(hourInQuestion.temp)°"
                    self.hourlyTimeName[x].text = hourInQuestion.hour
                    self.hourlyTimeName[x].textAlignment = .center
                    self.hourlyTemp[x].textAlignment = .center
                }
                
            }
            
        }
        
    }
    
    func changeBackGround(icon: String, sectionName: String){
        
        if icon == "09d" || icon == "09n" || icon == "10d" || icon == "10n" {
            self.backgroundImage.image = #imageLiteral(resourceName: "rain")
        }
        //thunder
        else if icon == "11d" || icon == "11n" {
            self.backgroundImage.image = #imageLiteral(resourceName: "thunder")
        }
        //snow
        else if icon == "13d" || icon == "13n" {
            self.backgroundImage.image = #imageLiteral(resourceName: "snow")
        }
        else if sectionName == "ohayōgozaimasu" {
            self.backgroundImage.image = #imageLiteral(resourceName: "sunrise")
        }
        else if sectionName == "kombanwa" {
            self.backgroundImage.image = #imageLiteral(resourceName: "night")
        }
        else if icon == "01d" {
            self.backgroundImage.image = #imageLiteral(resourceName: "clear")
        }
        //slightly cloudy
        else if icon == "02d" || icon == "02n"{
            self.backgroundImage.image = #imageLiteral(resourceName: "fewclouds")
        }
        //cloudy and mist
        else if icon == "03d" || icon == "03n" || icon == "04d" || icon == "04n" || icon == "50d" || icon == "50n" {
            self.backgroundImage.image = #imageLiteral(resourceName: "cloudy")
        }
    }
    
    
    
    func getWeatherDataImperial(from url: String, completion: @escaping ((_ weatherInfo: NeededWeatherInfo) -> ())){
        
        print(url)
        let task = URLSession.shared.dataTask(with: URL(string: url)!) { (data, response, error) in
            guard let data = data, error == nil else {
                print("Something went wrong")
                return
            }
            
            var weatherInfo: WeatherData
            
            do {
                try weatherInfo = JSONDecoder().decode(WeatherData.self, from: data)
                let weatherInfoNecessary = NeededWeatherInfo(weatherInfo: weatherInfo)
                completion(weatherInfoNecessary)
            }
            catch {
                print("error when getting data")
            }
            
        }
        
        task.resume()
    }
    
    func returnRelevantIcon(icon: String)-> UIImage{
        if icon == "01d" || icon == "01n" {
            if icon == "01d" {
                return sunIcon!
            }
            else {
                return moonIcon!
            }
        }
        else if icon == "02d" || icon == "02n"{
            if icon == "02d"{
                return(slightlyCloudyDayIcon!)
            }
            else {
                return(slightlyCloudyNightIcon!)
            }
        }
        else if icon == "03d" || icon == "03n" || icon == "04d" || icon == "04n" || icon == "50d" || icon == "50n" {
            return(cloudy!)
        }
        else if icon == "09d" || icon == "09n" || icon == "10d" || icon == "10n" {
            return(rainyIcon!)
        }
        else if icon == "11d" || icon == "11n" {
            return(thunderIcon!)
        }
        else {
            return(snowIcon!)
        }
    }
}




