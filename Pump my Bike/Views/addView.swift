//
//  addView.swift
//  Pump my Bike
//
//  Created by Milos Denck on 20.09.23.
//

import SwiftUI
import CoreLocation
import PhotosUI

struct addView: View {
    
    @EnvironmentObject var mapAPI: MapAPI
    @State var name: String
    @StateObject private var addViewModel = pumpAddViewModel()
    @Binding var showAddView: Bool
    
    var body: some View {
        NavigationStack{
            
            PhotoSelector().environmentObject(addViewModel.photoSelectorViewModel)
            Form{
                Section(header: Text("Informations")){
                    TextField("name", text: $name)
                    TextField("description", text: $addViewModel.description, axis: .vertical)
                        .lineLimit(5...10)
                }
                OpeninngHourSelection
            }
            .toolbar{
                ToolbarItem(placement: .navigationBarTrailing){
                    Button{
                        Task{
                            if let loc = mapAPI.currentLocation{
                                let newPump = addViewModel.getData(name: name, location: loc)
                                await mapAPI.uploadNewPump(pumpData: newPump, image: addViewModel.photoSelectorViewModel.selectedImage)
                                showAddView = false
                            }else{
                                mapAPI.errorHandler.triggerError(name: "Error", message: "Location not found")
                            }
                        }
                    }label: {
                        Image(systemName: "plus")
                            .padding(6)
                            .background(.green)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                            .shadow(radius: 5)
                    }
                    
                }
                ToolbarItem(placement: .navigationBarLeading){
                    Text("Add a Pump")
                }
            }
        }
    }
    
    @State var openingTime: Date = Date()
    @State var closingTime: Date = Date()
    
    var OpeninngHourSelection: some View{
       
        Section(header: Text("opening hours")){
            if addViewModel.openingHourAddViewModel.isActive {
                Toggle(isOn: $addViewModel.openingHourAddViewModel.alwaysOpen, label: {Text("always Open")})
                    .toggleStyle(.switch)
                
                if(addViewModel.openingHourAddViewModel.activeDay){
                    
                    HStack{
                        DatePicker( "opening:" ,selection: $openingTime, displayedComponents: .hourAndMinute)
                        Spacer()
                        DatePicker("closing:" ,selection: $closingTime, displayedComponents: .hourAndMinute)
                            .onChange(of: closingTime){
                                addViewModel.setOpeningHour(openingHour: OpeningHour(opening: Time(date: openingTime), closing: Time(date: closingTime)))
                            }
                    }
                }
                if(!addViewModel.openingHourAddViewModel.alwaysOpen){
                    openingHourDayView(day: "monday", active: $addViewModel.openingHourAddViewModel.mondayActive).environmentObject(addViewModel)
                    openingHourDayView(day: "tuesday", active: $addViewModel.openingHourAddViewModel.tuesdayActive).environmentObject(addViewModel)
                    openingHourDayView(day: "wednesday", active: $addViewModel.openingHourAddViewModel.wednesdayActive).environmentObject(addViewModel)
                    openingHourDayView(day: "thursday", active: $addViewModel.openingHourAddViewModel.thursdayActive).environmentObject(addViewModel)
                    openingHourDayView(day: "friday", active: $addViewModel.openingHourAddViewModel.fridayActive).environmentObject(addViewModel)
                    openingHourDayView(day: "saturday", active: $addViewModel.openingHourAddViewModel.saturdayActive).environmentObject(addViewModel)
                    openingHourDayView(day: "sunday", active: $addViewModel.openingHourAddViewModel.sundayActive).environmentObject(addViewModel)
                }
            }else{
                Button("add", action: {triggerAddButton()})
            }
        }
        
    }
                       
    func triggerAddButton(){
        if(name.count == 0){
            mapAPI.errorHandler.triggerError(name: "Name is missig", message: "You have to give the pump a name")
            return
        }
        if(name.count > 200){
            mapAPI.errorHandler.triggerError(name: "Name to long", message: "The name must have no more than 200 characters.")
            return
        }
        if(addViewModel.description.count > 200){
            mapAPI.errorHandler.triggerError(name: "Description to long", message: "The description must have no more than 200 characters.")
            return
        }
        addViewModel.initOpeningHours()
    }
    
    var PhotoSelection: some View{
        VStack{
            if let image = addViewModel.photoSelectorViewModel.selectedImage{
                Image(uiImage: image)
                    .resizable()
                    .frame(width: 120, height: 120)
                    .scaledToFit()
                    .clipShape(Circle())
            }else{
                Image(systemName: "camera")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
            }
            PhotosPicker(selection: $addViewModel.photoSelectorViewModel.imageSelection, matching: .images, label: {
                Text("add Photo")
            })
        }
            
    }
}

struct PhotoSelector: View{
    
    @EnvironmentObject var vm: PhotoSelectorViewModel
    
    var body: some View{
    
        VStack{
            if let image = vm.selectedImage{
                Image(uiImage: image)
                    .resizable()
                    .frame(width: 120, height: 120)
                    .scaledToFit()
                    .clipShape(Circle())
            }else{
                Image(systemName: "camera")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
            }
            PhotosPicker(selection: $vm.imageSelection, matching: .images, label: {
                Text("add Photo")
            })
        }
    }
}

/*
struct addView_Previews: PreviewProvider {
    static var previews: some View {
        addView()
    }
}*/
