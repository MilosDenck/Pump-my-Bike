//
//  Location.swift
//  Pump my Bike
//
//  Created by Milos Denck on 05.09.23.
//

import Foundation
import MapKit


struct PumpData: Codable{
    
    let id: Int?
    var name: String
    let lat, lon: Double
    var description: String
    var rating: Double?
    var openingHours: OpeningHours?
    var thumbnail: String?
    
    init(id: Int? = nil, name: String, lat: Double, lon: Double, description: String, rating: Double? = nil, openingHours: OpeningHours? = nil, thumbnail: String? = nil) {
        self.id = id
        self.name = name
        self.lat = lat
        self.lon = lon
        self.description = description
        self.rating = rating
        self.openingHours = openingHours
        self.thumbnail = thumbnail
    }
}

typealias PumpDatas = [PumpData]

class ImageFilename: Codable {
    var filename: String
}

class OpeningHours: Codable, ObservableObject{
    
    var alwaysOpen: Bool
    var monday: OpeningHour? = nil
    var tuesday: OpeningHour? = nil
    var wednesday: OpeningHour? = nil
    var thursday: OpeningHour? = nil
    var friday: OpeningHour? = nil
    var saturday: OpeningHour? = nil
    var sunday: OpeningHour? = nil
    
    init(alwaysOpen: Bool, monday: OpeningHour? = nil, tuesday: OpeningHour? = nil, wednesday: OpeningHour? = nil, thursday: OpeningHour? = nil, friday: OpeningHour? = nil, saturday: OpeningHour? = nil, sunday: OpeningHour? = nil) {
        self.alwaysOpen = alwaysOpen
        self.monday = monday
        self.tuesday = tuesday
        self.wednesday = wednesday
        self.thursday = thursday
        self.friday = friday
        self.saturday = saturday
        self.sunday = sunday
    }
    
    init(alwaysOpen:Bool, monday: [Time] = [], tuesday: [Time] = [], wednesday: [Time] = [], thursday: [Time] = [], friday: [Time] = [], saturday: [Time] = [], sunday: [Time] = []) {
        self.alwaysOpen = alwaysOpen
        if(monday.count == 2){
            self.monday = OpeningHour(opening: monday[0], closing: monday[1])
        }
        if(tuesday.count == 2){
            self.tuesday = OpeningHour(opening: tuesday[0], closing: tuesday[1])
        }
        if(wednesday.count == 2){
            self.wednesday = OpeningHour(opening: wednesday[0], closing: wednesday[1])
        }
        if(thursday.count == 2){
            self.thursday = OpeningHour(opening: thursday[0], closing: thursday[1])
        }
        if(friday.count == 2){
            self.friday = OpeningHour(opening: friday[0], closing: friday[1])
        }
        if(saturday.count == 2){
            self.saturday = OpeningHour(opening: saturday[0], closing: saturday[1])
        }
        if(sunday.count == 2){
            self.sunday = OpeningHour(opening: saturday[0], closing: saturday[1])
        }
        
        
    }
    

    
    func getOpeningHoursOfDay(day: Int) -> OpeningHour?{
        
        if(day == 2){
            return monday
        }else if(day == 3){
            return tuesday
        }else if(day == 4){
            return wednesday
        }else if(day == 5){
            return thursday
        }else if(day == 6){
            return friday
        }else if(day == 7){
            return saturday
        }
        return sunday
        
    }
    
    func getOpeningHoursOfDay(day: Date) -> OpeningHour?{
        
        if(Calendar.current.component(.day, from: day) == 2){
            return monday
        }else if(Calendar.current.component(.day, from: day)  == 3){
            return tuesday
        }else if(Calendar.current.component(.day, from: day)  == 4){
            return wednesday
        }else if(Calendar.current.component(.day, from: day)  == 5){
            return thursday
        }else if(Calendar.current.component(.day, from: day)  == 6){
            return friday
        }else if(Calendar.current.component(.day, from: day)  == 7){
            return saturday
        }
        return sunday
        
    }
    
    func isOpen() -> Bool{
        //let currentLoc = mapAPI.pumps.first(where: {$0.id == mapAPI.currentPin?.locationId})
        let cal = Calendar.current
        let hour = cal.component(.hour, from: Date())
        let minute = cal.component(.minute, from: Date())
        let todayOpen = self.getOpeningHoursOfDay(day: Date())
        if(todayOpen == nil){
            return false
        }else{
            if(todayOpen!.opening.hour == todayOpen!.closing.hour && todayOpen!.opening.minute == todayOpen!.closing.minute){ return false}
            if(hour > todayOpen!.opening.hour && hour < todayOpen!.closing.hour) {return true}
            else if(hour == todayOpen!.opening.hour && minute > todayOpen!.opening.minute){return true}
            else if(hour == todayOpen!.closing.hour && minute < todayOpen!.closing.minute){return true}
        }
        return false
    }
}

struct Time: Codable{
    
    let minute: Int
    let hour: Int
    
    init(minute: Int, hour: Int) {
        self.minute = minute
        self.hour = hour
    }
    
    init(date: Date){
        self.hour = Calendar.current.component(.hour, from: date)
        self.minute = Calendar.current.component(.minute, from: date)
    }
}

struct OpeningHour: Codable{
    
    let opening: Time
    let closing: Time
    
}

struct LocationPin: Identifiable{
    
    static func == (lhs: LocationPin, rhs: LocationPin) -> Bool {
        return lhs.id == rhs.id
    }
    
    
    let id = UUID()
    var name: String?
    let coodinates: CLLocationCoordinate2D
    let type: Int
    let locationId: Int?
    
    init(name: String?, coodinates: CLLocationCoordinate2D, type: Int, locationId: Int?) {
        self.name = name
        self.coodinates = coodinates
        self.type = type
        self.locationId = locationId
    }
    
    init(pumpData:PumpData){
        self.locationId = pumpData.id
        self.name = pumpData.name
        self.coodinates = CLLocationCoordinate2D(latitude: pumpData.lat, longitude: pumpData.lon)
        self.type = 1
    }
    
}

struct ID: Codable{
    let id: Int
}
