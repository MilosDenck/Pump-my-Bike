//
//  AddViewModel.swift
//  Pump my Bike
//
//  Created by Milos Denck on 20.09.23.
//

import Foundation
import MapKit
import PhotosUI
import _PhotosUI_SwiftUI


@MainActor
class pumpAddViewModel:ObservableObject{
    @Published var name: String
    @Published var description: String = ""
    //@Published var openingHours: OpeningHours?
    /*
    @Published var alwaysOpen = true
    @Published var mondayActive: Bool = false
    @Published var tuesdayActive: Bool = false
    @Published var wednesdayActive: Bool = false
    @Published var thursdayActive: Bool = false
    @Published var fridayActive: Bool = false
    @Published var saturdayActive: Bool = false
    @Published var sundayActive: Bool = false*/
    
    @Published var openingHourAddViewModel = OpeningHourAddViewModel()
    @Published var photoSelectorViewModel = PhotoSelectorViewModel()
    
    
    

    
    func setOpeningHour(openingHour: OpeningHour){
        /*
        if mondayActive { openingHours?.monday = openingHour}
        if tuesdayActive { openingHours?.tuesday = openingHour}
        if wednesdayActive { openingHours?.wednesday = openingHour}
        if thursdayActive { openingHours?.thursday = openingHour}
        if fridayActive { openingHours?.friday = openingHour}
        if saturdayActive { openingHours?.saturday = openingHour}
        if sundayActive { openingHours?.sunday = openingHour}*/
        
        openingHourAddViewModel.setOpeningHour(openingHour: openingHour)
    }
    
    func deleteOpeningHour(day: String){
        /*
        switch day {
        case "monday":
            openingHours?.monday = nil
        case "tuesday":
            openingHours?.tuesday = nil
        case "wednesday":
            openingHours?.wednesday = nil
        case "thursday":
            openingHours?.thursday = nil
        case "friday":
            openingHours?.friday = nil
        case "saturday":
            openingHours?.wednesday = nil
        case "sunday":
            openingHours?.sunday = nil
        default:
            print("something went wrong")
        }*/
        /*
        if day == "monday" {
            openingHours?.monday = nil
            return
        }
        if day == "tuesday" {
            openingHours?.tuesday = nil
            return
        }
        if day == "wednesday" {
            openingHours?.wednesday = nil
            return
        }
        if day == "thursday" {
            openingHours?.thursday = nil
            return
        }
        if day == "friday" {
            openingHours?.friday = nil
            return
        }
        if day == "saturday" {
            openingHours?.saturday = nil
            return
        }
        if day == "sunday" {
            openingHours?.sunday = nil
            return
        }*/
        openingHourAddViewModel.deleteOpeningHour(day: day)
    }
    
    func getData(name: String, location: CLLocationCoordinate2D) -> PumpData{
        return PumpData(name: name, lat: location.latitude, lon: location.longitude, description: self.description, openingHours: openingHourAddViewModel.isActive ? openingHourAddViewModel.getOpeningHours() : nil)
    }
    
    
    /*
    @Published private(set) var selectedImage: UIImage? = nil
    @Published var imageSelection: PhotosPickerItem? = nil{
        didSet{
            setImage(from: imageSelection)
        }
    }*/
    
    init(name: String = "" , description: String = "") {
        self.name = name
        self.description = description
        //self.openingHours = openingHours
    }
    
    func initOpeningHours(){
        openingHourAddViewModel.isActive = true
    }

    /*
    func setImage(from selection: PhotosPickerItem?){
        guard let selection else {return}
        
        Task{
            if let data = try? await selection.loadTransferable(type: Data.self){
                if let uiImage = UIImage(data: data){
                    selectedImage = uiImage
                    return
                }
            }
        }
    }*/
    
}

@MainActor
class PhotoSelectorViewModel: ObservableObject{
    
    @Published private(set) var selectedImage: UIImage? = nil
    @Published var imageSelection: PhotosPickerItem? = nil{
        didSet{
            setImage(from: imageSelection)
        }
    }
    
    var networkService = NetworkService()
    
    
    func setImage(from selection: PhotosPickerItem?){
        guard let selection else {return}
        
        Task{
            if let data = try? await selection.loadTransferable(type: Data.self){
                if let uiImage = UIImage(data: data){
                    selectedImage = uiImage
                    return
                }
            }
        }
    }
    
    func uploadImage(pumpId: Int){
        guard let image = selectedImage else{
            return
        }
        let boundary: String = "Boundary-\(UUID().uuidString)"
        let urlString = "\(networkService.SERVER_IP)/images?id=\(pumpId)"
        guard let url = URL(string: urlString) else {
            print("invalid URL")
            return
        }
        let data = multipartFormDataBody(boundary, "gjhfg", image, pumpID: pumpId)
        let request = networkService.generateRequest(httpBody: data, url: url, headerValues: ["multipart/form-data; boundary=\(boundary)":"Content-Type"])
        networkService.postRequest(request: request)
    }
    
    private func multipartFormDataBody(_ boundary: String, _ fromName: String, _ image: UIImage, pumpID: Int) -> Data{
        let lineBreak = "\r\n"
        var body = Data()
        
        body.append("--\(boundary + lineBreak)")
        body.append("Content-Disposition: form-data; name=\"fromName\"\(lineBreak + lineBreak)")
        body.append("\(fromName + lineBreak)")
        
        body.append("--\(boundary + lineBreak)")
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"\(pumpID).jpg\"\(lineBreak)")
        body.append("Content-Type: image/jpeg\(lineBreak + lineBreak)")
        body.append(image.jpegData(compressionQuality: 0.05)!)
        body.append(lineBreak)
        
        body.append("--\(boundary)--\(lineBreak)")

        
        return body
    }
}

@MainActor
class OpeningHourAddViewModel: ObservableObject{

    @Published var alwaysOpen: Bool
    @Published var mondayActive: Bool = false
    @Published var tuesdayActive: Bool = false
    @Published var wednesdayActive: Bool = false
    @Published var thursdayActive: Bool = false
    @Published var fridayActive: Bool = false
    @Published var saturdayActive: Bool = false
    @Published var sundayActive: Bool = false
    
    @Published var isActive: Bool = false
    
    @Published var monday: OpeningHour? = nil
    @Published var tuesday: OpeningHour? = nil
    @Published var wednesday: OpeningHour? = nil
    @Published var thursday: OpeningHour? = nil
    @Published var friday: OpeningHour? = nil
    @Published var saturday: OpeningHour? = nil
    @Published var sunday: OpeningHour? = nil
    
    public let SERVER_IP = "http://192.168.178.36:8000"
    
    var networkService = NetworkService()
    
    var activeDay: Bool{
        if( mondayActive || tuesdayActive || wednesdayActive || fridayActive || thursdayActive || saturdayActive || sundayActive){return true}
        return false
    }
    
    init() {
        self.alwaysOpen = true
    }
    
    init(openingHours: OpeningHours) {
        self.monday = openingHours.monday
        self.tuesday = openingHours.tuesday
        self.wednesday = openingHours.wednesday
        self.thursday = openingHours.thursday
        self.friday = openingHours.friday
        self.saturday = openingHours.saturday
        self.sunday = openingHours.sunday
        self.alwaysOpen = openingHours.alwaysOpen
    }
    
    func postOpeningHours(id: Int){
        let openingHours = OpeningHours(alwaysOpen: self.alwaysOpen, monday: self.monday, tuesday: self.tuesday, wednesday: self.wednesday, thursday: self.thursday, friday: self.friday, saturday: self.saturday, sunday: self.sunday)
        guard let data = try? JSONEncoder().encode(openingHours) else{
            return
        }
        let url_string = "\(networkService.SERVER_IP)/openinghours?id=\(id)"
        guard let url = URL(string: url_string) else{
            return
        }
        let request = networkService.generateRequest(httpBody: data, url: url, headerValues: ["application/json":"Content-Type"])
        networkService.postRequest(request: request)
    }

    
    func setOpeningHour(openingHour: OpeningHour){
        if mondayActive { monday = openingHour}
        if tuesdayActive { tuesday = openingHour}
        if wednesdayActive { wednesday = openingHour}
        if thursdayActive { thursday = openingHour}
        if fridayActive { friday = openingHour}
        if saturdayActive { saturday = openingHour}
        if sundayActive { sunday = openingHour}
    }
    
    func deleteOpeningHour(day: String){
        switch day {
        case "monday":
            monday = nil
        case "tuesday":
            tuesday = nil
        case "wednesday":
            wednesday = nil
        case "thursday":
            thursday = nil
        case "friday":
            friday = nil
        case "saturday":
            saturday = nil
        case "sunday":
            sunday = nil
        default:
            print("something went wrong")
        }
        
    }
    
    func getOpeningHours() -> OpeningHours{
        let openingHours = OpeningHours(alwaysOpen: self.alwaysOpen, monday: self.monday, tuesday: self.tuesday, wednesday: self.wednesday, thursday: self.thursday, friday: self.friday, saturday: self.saturday, sunday: self.sunday)
        return openingHours
    }
    
}

