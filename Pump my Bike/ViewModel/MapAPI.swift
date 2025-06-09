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
    
    init() {
        self.networkService = NetworkService()
        if let location = manager.location {
            self.region = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
            self.cameraPosition = .region(MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)))

        }else{
            self.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 52.555305, longitude: 13.464911), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
            self.cameraPosition = .region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 52.555305, longitude: 13.464911), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)))

        }
        currentLocation = manager.location
        
    }
    
    func loadData() async throws{
        try await updatePumps(coordinates: region.center)
    }
    
    func searchPlace(name: String){
        
        if let searchItem = searchItemList.first{
            
            self.pins.removeAll(where: {$0.type == 0})
            let pin = LocationPin(name: name, coodinates: searchItem.placemark.coordinate, type: 0, locationId: nil)
            self.pins.insert(pin, at: 0)

            self.currentPin = pin
            self.currentLocation = searchItem.placemark.coordinate
            self.region = MKCoordinateRegion(center: searchItem.placemark.coordinate, span: self.region.span)
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
                        }
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
    
    func uploadNewPump(pumpData: PumpData, image: UIImage? = nil) async throws -> (Bool, String?){
        let url_string = "\(networkService.SERVER_IP)/locations"
        
        guard let url = URL(string: url_string) else {
            print("invalid URL")
            return (false, "invalid api url")
        }
        
        var jsonData:Data
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        do{
            jsonData = try encoder.encode(pumpData)
        }catch{
            print("encode gone wrong")
            return (false, "an error occured")
        }
        
        var request = networkService.generateRequest(httpBody: jsonData, url: url, headerValues: ["application/json":"Content-Type"])
        
        guard let cookieHeader = networkService.getTokenCookieHeader() else {
            TokenManager.shared.clearTokens()
            return (false, "an error occured")
        }
        
        request.setValue(cookieHeader, forHTTPHeaderField: "Cookie")
        request.setValue("session", forHTTPHeaderField: "rid")
        request.httpMethod = "POST"

        let (data, res) = try await networkService.authorizedRequest(request: request)
        
        if let pumpData = try? JSONDecoder().decode(PumpData.self, from: data) {

            self.pumps.append(pumpData)
            let newPin = LocationPin(pumpData: pumpData)
            self.pins.insert(newPin, at: 0)
            self.currentPin = newPin
            self.dismissRoute()
        }
        
        guard (200...299).contains(res.statusCode) else {
            return (false, "an error occured")
        }

        guard let image = image else {
            return (true, nil)
        }
        
        guard let id = try? JSONDecoder().decode(ID.self, from: data) else {
            return (false ,"an error occured")
        }

        try await self.uploadImage(image: image, pumpId: id.id)
        return (true, nil)
    }
    
    func uploadImage(image: UIImage, pumpId: Int) async throws -> (Bool, String?){
        let boundary: String = "Boundary-\(UUID().uuidString)"
        let urlString = "\(networkService.SERVER_IP)/images?id=\(pumpId)"
        guard let url = URL(string: urlString) else {
            print("invalid URL")
            return (false, "invalid api url")
        }
        let data = multipartFormDataBody(boundary, "gjhfg", image, pumpID: pumpId)
        let request = networkService.generateRequest(httpBody: data, url: url, headerValues: ["multipart/form-data; boundary=\(boundary)":"Content-Type"])
        let (httpData, res) = try await networkService.postRequest(request: request)
        
        guard (200..<300).contains(res.statusCode) else {
            return (false, "an error occured")
        }

        guard let filename = String(data: httpData, encoding: .utf8) else {
            return (false, "an error occured")
        }
        
        guard var pumpdata = self.pumps.first(where: { $0.id == pumpId }) else {
            return (false, "an error occured")
        }
            
        pumpdata.thumbnail = filename
        self.pumps.removeAll(where: { $0.id == pumpId })
        self.pumps.append(pumpdata)
        
        return (true, nil)
            
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
    
    func updatePump(id: Int) async throws -> PumpData {
        let url_string = "\(networkService.SERVER_IP)/location?id=\(id)"
        
        return try await withCheckedThrowingContinuation { continuation in
            networkService.getRequest(url_string: url_string) { data, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let data = data,
                      let pumpData = try? JSONDecoder().decode(PumpDatas.self, from: data),
                      let pump = pumpData.first else {
                    let err = NSError(domain: "DecodingError", code: 0, userInfo: nil)
                    continuation.resume(throwing: err)
                    return
                }
                continuation.resume(returning: pump)
            }
        }
    }
    
    func updatePumps(coordinates: CLLocationCoordinate2D) async throws -> (Bool, String?) {
        let url_string = "\(networkService.SERVER_IP)/locations?lat=\(coordinates.latitude)&lon=\(coordinates.longitude)&maxdist=20"
        
        let (data, res) = try await networkService.getRequest(url_string: url_string)
        
        guard (200..<300).contains(res.statusCode) else {
            return (false, "an error occured")
        }
      
        guard let pumpData = try? JSONDecoder().decode(PumpDatas.self, from: data) else {
            return (false, "an error occured")
        }
        
        self.pumps.removeAll()
        self.pumps = pumpData
        self.pins.removeAll(where: {$0.type == 1})
        for pump in self.pumps{
            let newPin = LocationPin(pumpData: pump)
            self.pins.insert(newPin, at: 0)
        }
        
        return (true, nil)
        
    }

    func updateRegion(coordinates: CLLocationCoordinate2D, span: MKCoordinateSpan?){
        self.region = MKCoordinateRegion(center: coordinates, span: span ?? self.region.span)
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
