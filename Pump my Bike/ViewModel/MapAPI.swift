//
//  LocationsViewModel.swift
//  Pump my Bike
//
//  Created by Milos Denck on 05.09.23.
//

import Foundation
import MapKit
import PhotosUI
import _PhotosUI_SwiftUI
import _MapKit_SwiftUI


@MainActor
class MapAPI: ObservableObject {
    
    @Published var region: MKCoordinateRegion{
        didSet{
            cameraPosition = .region(self.region)
        }
    }
    @Published var cameraPosition: MapCameraPosition
    
    
    @Published var showCardView: Bool = false
    @Published var pumps: [PumpData] = []
    @Published var pins: [LocationPin] = []
    @Published var currentPin: LocationPin? = nil
    @Published var errorHandler: ErrorHandler
    
    @Published var currentLocation: CLLocationCoordinate2D?
    
    @Published var searchItemList: [MKMapItem] = []
    @Published var searchItem: MKMapItem? = nil
    
    @Published var showRoute: Bool = false
    @Published var route: MKRoute?
    
    

    let manager = LocationManager()
    
    let userData = UserData()
    
    let networkService: NetworkService
    
    var filenames: [String]? = nil
    
    @Published var thumbnail: UIImage?
    
    init(){
        self.errorHandler = ErrorHandler()
        self.networkService = NetworkService()
        if let location = manager.location {
            self.region = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
            self.cameraPosition = .region(MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)))

        }else{
            self.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 52.555305, longitude: 13.464911), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
            self.cameraPosition = .region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 52.555305, longitude: 13.464911), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)))

        }
        
        
        
        updatePumps(coordinates: region.center)
        currentLocation = manager.location
        
    }
    
    func searchPlace(name: String){
        
        if let searchItem = searchItemList.first{
            
            self.pins.removeAll(where: {$0.type == 0})
            let pin = LocationPin(name: name, coodinates: searchItem.placemark.coordinate, type: 0, locationId: nil)
            self.pins.insert(pin, at: 0)

            self.currentPin = pin
            self.currentLocation = searchItem.placemark.coordinate
            self.region = MKCoordinateRegion(center: searchItem.placemark.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        }
    }
    
    func updateSearchItem(item: MKMapItem){
        self.searchItem = item
        self.pins.removeAll(where: {$0.type == 0})
        let pin = LocationPin(name: item.name, coodinates: item.placemark.coordinate, type: 0, locationId: nil)
        self.pins.insert(pin, at: 0)

        self.currentPin = pin
        self.currentLocation = item.placemark.coordinate
        self.region = MKCoordinateRegion(center: item.placemark.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
    }
    
    func getSeachPlaces(name: String) async{
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = name
        request.region = region
        
        let result = try? await MKLocalSearch(request: request).start()
        
        if let list = result?.mapItems{
            searchItemList = list
        }
    }
    
    func searchPlacefromCoordinates(coordinates: CLLocationCoordinate2D) {
        let geocoder = CLGeocoder()
                    
        geocoder.reverseGeocodeLocation(CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude), completionHandler: { (placemarks, error) in
                    if error == nil {
                        if let firstLocation = placemarks?[0]{
                            self.pins.removeAll(where: {$0.type == 0})
                            let pin = LocationPin(name: firstLocation.name ?? "", coodinates: coordinates, type: 0, locationId: nil)
                            self.pins.insert(pin, at: 0)
                            
                            self.currentPin = pin
                            self.currentLocation = coordinates
                            self.region = MKCoordinateRegion(center: coordinates, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
                        }
                    }
                    else {
                        self.errorHandler.triggerError(name: "Error", message: error!.localizedDescription)
                    }
                })
    }
    
    func dismissRoute(){
        route = nil
        showRoute = false
    }
    
    func fetchRoute(){
        let request = MKDirections.Request()
        if let loc = manager.location{
            request.source = .init(placemark: .init(coordinate: loc))
            request.transportType = .walking
            if let dest = currentPin?.coodinates{
                request.destination = .init(placemark: .init(coordinate: dest))
                Task{
                    let result = try? await MKDirections(request: request).calculate()
                    route = result?.routes.first
                    self.showRoute = true
                }
            }
        }
    }
    
    func postRating(rating: Rating){
        guard let url = URL(string:"\(networkService.SERVER_IP)/rating?userid=\(userData.userId!)" )else{
            return
        }
        guard let data = try? JSONEncoder().encode(rating) else {
            return
        }
        let request = networkService.generateRequest(httpBody: data, url: url, headerValues: ["application/json":"Content-Type"])
        networkService.postRequest(request: request)
    }
    
    func uploadNewPump(pumpData: PumpData, image: UIImage? = nil) async{
        let url_string = "\(networkService.SERVER_IP)/locations"
        
        guard let url = URL(string: url_string) else {
            print("invalid URL")
            return
        }
        
        var jsonData:Data
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        do{
            jsonData = try encoder.encode(pumpData)
        }catch{
            print("encode gone wrong")
            return
        }
        
        let request = networkService.generateRequest(httpBody: jsonData, url: url, headerValues: ["application/json":"Content-Type"])
        networkService.postRequest(request: request){ data in
            guard let image = image else{
                return
            }
            guard let id = try? JSONDecoder().decode(ID.self, from: data) else {
                print(data)
                return
            }
            self.uploadImage(image: image, pumpId: id.id)
            
        }
        
    }
    
    func uploadImage(image: UIImage, pumpId: Int){
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
    
    func updatePump(id: Int, callback: @escaping (PumpData) -> ()){
        let url_string = "\(networkService.SERVER_IP)/location?id=\(id)"
        networkService.getRequest(url_string: url_string){ data, error in
            if let error = error{
                self.errorHandler.triggerError(name: "Error", message: error.localizedDescription)
                return
            }
            guard let data = data else{
                return
            }
            guard let pumpData = try? JSONDecoder().decode(PumpDatas.self, from: data) else{
                return
            }
            
            guard var currentpump = self.pumps.first(where: {$0.id == id}) else{
                return
            }
            
            guard let pump = pumpData.first else{
                return
            }
            
            callback(pump)
            
            self.updatePumps(coordinates: CLLocationCoordinate2D(latitude: pump.lat, longitude: pump.lon))
        }
    }
    /*
    func getFilenames(id: Int){
        self.filenames = nil
        let url_string = "\(networkService.SERVER_IP)/images?id=\(id)"
        networkService.getRequest(url_string: url_string){ data , error in
            if let error = error{
                self.errorHandler.triggerError(name: "Error", message: error.localizedDescription)
                return
            }
            guard let data = data else{
                return
            }
            guard let files = try? JSONDecoder().decode([String].self, from: data) else {
                print("decode gone wrong")
                return
            }
            self.filenames = files
        }
    }*/
    
    func updatePumps(coordinates: CLLocationCoordinate2D){
        let url_string = "\(networkService.SERVER_IP)/locations?lat=\(coordinates.latitude)&lon=\(coordinates.longitude)&maxdist=20"
        
        networkService.getRequest(url_string: url_string){ data, error in
            if let error = error{
                self.errorHandler.triggerError(name: "Error", message: error.localizedDescription)
                return
            }
            guard let data = data else{
                return
            }
            guard let pumpData = try? JSONDecoder().decode(PumpDatas.self, from: data) else {

                return
            }
            
            self.pumps.removeAll()
            self.pumps = pumpData
            self.pins.removeAll(where: {$0.type == 1})
            for pump in self.pumps{
                let newPin = LocationPin(pumpData: pump)
                //print(pump.thumbnail)
                self.pins.insert(newPin, at: 0)
            }
        }
            

        
    }

    
    func updateRegion(coordinates: CLLocationCoordinate2D){
        self.region = MKCoordinateRegion(center: coordinates, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
    }
    
  
    
    func insertPin(coordinates: CLLocationCoordinate2D){
        let pin = LocationPin(name: "Location", coodinates: coordinates, type: 0, locationId: nil)
        self.pins.insert(pin, at: 0)
        self.currentPin = pin
        self.currentLocation = coordinates
    }
  
}


class ErrorHandler{
    @Published var errorMessage: ErrorMessage?
    @Published var showError: Bool{
        didSet{
            if self.showError == false{
                self.errorMessage = nil
            }
        }
    }
    
    init() {
        self.errorMessage = nil
        self.showError = false
    }
    
    func triggerError(name: String, message: String){
        self.errorMessage = ErrorMessage(name: name, massage: message)
        self.showError = true
    }
     
}

struct ErrorMessage{
    var name: String
    var massage: String
}

