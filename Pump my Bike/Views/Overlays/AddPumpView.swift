//
//  AddPumpView.swift
//  Pump my Bike
//
//  Created by Milos Denck on 06.06.25.
//

import SwiftUI
import CoreLocation
import PhotosUI

struct AddPumpView: View {
    
    @AppStorage("loggedIn") private var loggedIn = false
    
    @Binding var overlayView: OverlaysViewStyle
    @Binding var authScreen: AuthScreen
    @EnvironmentObject var mapAPI: MapAPI
    
    @State var name: String 
    @StateObject private var addViewModel = pumpAddViewModel()
    @StateObject var openingHourViewModel: OpeningHourAddViewModel = OpeningHourAddViewModel()
    
    @State var showSelection: Bool = false
    @State var showPicker: Bool = false
    @State var type: UIImagePickerController.SourceType = .camera
    
    @EnvironmentObject var handler: ErrorHandler2

    
    let manager = LocationManager()
    
    var body: some View {
        ScrollView{
            if(loggedIn){
                HStack {
                    Text("Add a Photo:")
                        .font(.footnote)
                        .fontWeight(.bold)
                        .padding(.leading, 10)
                        .padding(.top,20)
                    Spacer()
                }
                PhotoSelector(showSelector: $showSelection).environmentObject(addViewModel.photoSelectorViewModel)
                    .padding(10)
                HStack {
                    Text("Informations:")
                        .font(.footnote)
                        .fontWeight(.bold)
                        .padding(.leading, 10)
                        .padding(.top,10)
                    Spacer()
                }
                
                CustomTextField(title:"name", text: $name)
                CustomTextEditor(title:"description", text: $addViewModel.description)
                OperningHourConfigurator().environmentObject(openingHourViewModel)
                CustomLongButton(title: "send"){
                    Task{
                        try await uploadPump()
                    }
                }
                .padding(.top, 20)
                .padding(.horizontal, 10)
                

            }else {
                Text("please login to add a pump")
                Button("login") {
                    authScreen = .loginScreen
                }
                .padding(10)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 7)
                        .stroke(Color.black, lineWidth: 1)
                )
                .padding(.trailing, 10)
                
            }
        }.confirmationDialog("select", isPresented: $showSelection,titleVisibility: .hidden){

            
            Button("camera") {
                showPicker = true
                type = .camera
            }
            
            Button("photo library") {
                showPicker = true
                type = .photoLibrary
                
            }
        }
        .padding(.horizontal, 10)
        .dismissKeyboardOnTap()
        .fullScreenCover(isPresented: $showPicker) {
            ImagePickerView(sourceType: type) { image in
                addViewModel.photoSelectorViewModel.selectedImage = image
            }.ignoresSafeArea()
        }
        
    }

    func uploadPump() async throws {
        guard let loc = mapAPI.currentLocation else {
            mapAPI.errorHandler.triggerError(name: "Error", message: "Location not found")
            return
        }
        var newPump = addViewModel.getData(name: name, location: loc)
        guard let accessTokenExpires = TokenManager.shared.accessTokenExpires else {
            return
        }
        if(accessTokenExpires < Date()){
            
            let (succ, _) = try await AuthManager.shared.refreshSession()
            if !succ{
                TokenManager.shared.clearTokens()
                return
            }
        }
        print(openingHourViewModel.isActive)
        if(openingHourViewModel.isActive){
            let openingHours = OpeningHours(alwaysOpen: openingHourViewModel.alwaysOpen, monday: openingHourViewModel.monday, tuesday: openingHourViewModel.tuesday, wednesday: openingHourViewModel.wednesday, thursday: openingHourViewModel.thursday, friday: openingHourViewModel.friday, saturday: openingHourViewModel.saturday, sunday: openingHourViewModel.sunday)
            newPump.openingHours = openingHours
            print(openingHours)
        }
        print(newPump)
        try await mapAPI.uploadNewPump(pumpData: newPump, image: addViewModel.photoSelectorViewModel.selectedImage)
        overlayView = .none
    }
}

