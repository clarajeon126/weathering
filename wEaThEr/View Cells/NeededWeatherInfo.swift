//
//  NeededWeatherInfo.swift
//  wEaThEr
//
//  Created by Clara Jeon on 3/8/21.
//

import Foundation


//to get all the info needed from the json
public class NeededWeatherInfo {
    var currentWeather:currentWeatherInfo
    var dailyArray:[dayWeatherInfo]
    var hourlyArray:[hourWeatherInfo]
    init(weatherInfo: WeatherData){
        let current = weatherInfo.current
        
        let dailyArrayFull = weatherInfo.daily
        let hourlyArrayFull = weatherInfo.hourly
        
        var dailyArrayNeededInfo: [dayWeatherInfo] = []
        var hourlyArrayNeededInfo: [hourWeatherInfo] = []
        
        let timezone = weatherInfo.timezoneOffset

        //getting current weather array
        self.currentWeather = currentWeatherInfo(time: current.dt, timezone: timezone, temp: current.temp, sunrise: dailyArrayFull[0].sunrise, sunset: dailyArrayFull[0].sunset, feelsLike: current.feelsLike, icon: current.weather[0].icon)
        
        //gettng daily weather array
        for x in 0...7 {
            let dayInQuestion = dailyArrayFull[x]
            let high = dayInQuestion.temp.max
            let low = dayInQuestion.temp.min
            let icon = dayInQuestion.weather[0].icon
            let time = dayInQuestion.dt
            let dayInQuestionInfo = dayWeatherInfo(high: high, low: low, icon: icon, time: time, timezone: timezone)
            dailyArrayNeededInfo.append(dayInQuestionInfo)
        }
        
        //getting hourly weather array
        for x in 0..<12 {
            let hourInQuestion = hourlyArrayFull[x]
            let temp = hourInQuestion.temp
            let icon = hourInQuestion.weather[0].icon
            let time = hourInQuestion.dt
            let hourInQuestionInfo = hourWeatherInfo(temp: temp, icon: icon, time: time, timezone: timezone)
            hourlyArrayNeededInfo.append(hourInQuestionInfo)
        }
        
        self.hourlyArray = hourlyArrayNeededInfo
        self.dailyArray = dailyArrayNeededInfo
    }
    
}


public class currentWeatherInfo {
    var timeFormatted: String
    var sunriseFormatted: String
    var sunsetFormatted: String
    var sectionOfDay: String
    var temp: Int
    var feelsLike: Int
    var icon: String
    var dateInString: String
    
    init(time: Int, timezone: Int, temp: Double, sunrise: Int, sunset: Int, feelsLike: Double, icon: String){
        self.temp = Int(temp)
        self.feelsLike = Int(feelsLike)
        self.icon = icon
        self.timeFormatted = ""
        self.sunriseFormatted = ""
        self.sunsetFormatted = ""
        self.sectionOfDay = ""
        
        //get date to be formatted
        let timeZone = TimeZone(secondsFromGMT: timezone)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = timeZone
        dateFormatter.dateFormat = "EEEE MMMM d"
        let date = Date(timeIntervalSince1970: Double(time))
        let formattedDate = dateFormatter.string(from: date)
        self.dateInString = formattedDate.lowercased()
        
        let currentFormattedDate = getFormattedDate(time: time, timezone: timezone)
        
        if time < sunrise || time > sunset {
            sectionOfDay = "kombanwa"
        }
        else if currentFormattedDate.contains("PM"){
            sectionOfDay = "kon'nichiwa"
        }
        else {
            sectionOfDay = "ohayōgozaimasu"
        }
        
        self.timeFormatted = currentFormattedDate
        self.sunriseFormatted = getFormattedDate(time: sunrise, timezone: timezone)
        self.sunsetFormatted = getFormattedDate(time: sunset, timezone: timezone)
        
        
    }
    
    
    //format a UNIX num like 139401 to 4:33 PM
    func getFormattedDate(time: Int, timezone: Int) -> String {
        let timezoneE = TimeZone(secondsFromGMT: timezone)

        let dateFormatter = DateFormatter()

        dateFormatter.timeZone = timezoneE
        dateFormatter.dateFormat = "h:mm a"

        let date = Date(timeIntervalSince1970: Double(time))


        let formattedDate = dateFormatter.string(from: date)
        
        return formattedDate
    }
}

public class dayWeatherInfo {
    var high: Int
    var low: Int
    var icon: String
    var weekday: String
    
    init(high: Double, low: Double, icon: String, time: Int, timezone: Int){
        self.high = Int(high)
        self.low = Int(low)
        self.icon = icon
        
        let dateFormatter = DateFormatter()
        let timezone = TimeZone(secondsFromGMT: timezone)

        dateFormatter.timeZone = timezone
        dateFormatter.dateFormat = "EEEE"

        let date = Date(timeIntervalSince1970: Double(time))

        let formattedDate = dateFormatter.string(from: date)
        
        
        self.weekday = formattedDate.lowercased()
    }
}

public class hourWeatherInfo {
    var temp: Int
    var icon: String
    var hour: String
    
    init(temp: Double, icon: String, time: Int, timezone: Int){
        self.temp = Int(temp)
        self.icon = icon
        
        let dateFormatter = DateFormatter()
        let timezone = TimeZone(secondsFromGMT: timezone)

        dateFormatter.timeZone = timezone
        dateFormatter.dateFormat = "h a"

        let date = Date(timeIntervalSince1970: Double(time))

        let formattedDate = dateFormatter.string(from: date)
        
        
        self.hour = formattedDate
    }
}
