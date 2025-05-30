//
//  LocationDetailView.swift
//  Pump my Bike
//
//  Created by Milos Denck on 26.09.23.
//

import SwiftUI
import CoreLocation

struct LocationDetailView: View {
    
    @State var pump: PumpData
    @EnvironmentObject var mapAPI:MapAPI
    @StateObject var ldvm: DetailViewModel
    @State var showRatingView: Bool = false
    @StateObject var photoSelectorViewModel = PhotoSelectorViewModel()
    
    var body: some View {
        ZStack{
            VStack{
                PictureView
                HStack{
                    Text(pump.name)
                        .font(.system(size: 30))
                        .bold()
                    NavigationLink(destination: PhotoUploader(id: pump.id!).environmentObject(photoSelectorViewModel), label: {
                        Image(systemName: "camera")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 20)
                            .foregroundColor(.secondary)
                    })
                }
                HStack{
                    if(mapAPI.manager.location != nil){
                        Text(String(format: "%.1f km" , mapAPI.manager.location?.dist(coordinates: CLLocationCoordinate2D(latitude: pump.lat, longitude: pump.lon )) ?? 0))
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                    }
                    
                    if let opening = pump.openingHours{
                        if(opening.alwaysOpen || opening.isOpen()){
                            Text("open")
                                .foregroundColor(.green)
                        }else{
                            Text("closed")
                                .foregroundColor(.red)
                        }
                    }
                }
                    

                    //.padding(pump.description == "" ? 0 : 10)
                OpeningHoursDetailView
                Spacer()
            }
            
        }
            .ignoresSafeArea()
    }
    
    var PictureView: some View{
        VStack{
            if let names = ldvm.filenames{
                TabView{
                    ForEach(names, id: \.self){ image in
                        let url = "\(mapAPI.networkService.SERVER_IP)/Images/\(pump.id!)/\(image)"
                        AsyncImage(url: URL(string:url)!){ phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(height: 200)
                                    .frame(maxWidth: .infinity)
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                //.scaledToFit()
                                //.frame(height: 200)
                                //.frame(maxWidth: .infinity)
                                //.clipped()
                                    .ignoresSafeArea()
                                
                            case .failure(_):
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .padding(.top, 150)
                                    .frame(width: 50)
                                
                            @unknown default:
                                EmptyView()
                                    .frame(height: 200)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                      
                    }
                }.tabViewStyle(PageTabViewStyle())
                    .ignoresSafeArea()
            }else{
                Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 50)
                        .padding(.top, 100)
                        .padding(.bottom, 50)
                
            }
        }.frame(height: 200)
    }
    
    

    
    
    var OpeningHoursDetailView: some View{
        VStack{
            List{
                Section(header: HStack{Text("description"); Spacer(); NavigationLink(pump.description == "" ? "add" : "change description", destination: {DescriptionUploadView(id: pump.id!).environmentObject(ldvm)})
                }){
                    Text(pump.description)
                }
                Section(header:
                    HStack{
                        Text("Opening Hours")
                        Spacer()
                    NavigationLink(pump.openingHours == nil ? "add" : "report changes", destination: {OpeningHourUploadView(id: pump.id!).environmentObject(OpeningHourAddViewModel(openingHours: pump.openingHours ?? OpeningHours(alwaysOpen: true, monday: nil) ))})
                    }
                ){
                    if let openingHour = pump.openingHours{
                        if !openingHour.alwaysOpen{
                            Opening(openingHour: $pump.openingHours, dayString: "monday", dayInt: 2)
                            Opening(openingHour: $pump.openingHours, dayString: "tuesday", dayInt: 3)
                            Opening(openingHour: $pump.openingHours, dayString: "wednesday", dayInt: 4)
                            Opening(openingHour: $pump.openingHours, dayString: "thursday", dayInt: 5)
                            Opening(openingHour: $pump.openingHours, dayString: "friday", dayInt: 6)
                            Opening(openingHour: $pump.openingHours, dayString: "saturday", dayInt: 7)
                            Opening(openingHour: $pump.openingHours, dayString: "sunday", dayInt: 1)
                        }else{
                            Text("always Open")
                        }
                    }
                }
                if let ratings = ldvm.ratings{
                    Section(header: HStack{Text("Ratings"); Spacer(); NavigationLink("add Rating", destination: Rating)}){
                        
                        ForEach(ratings, id: \.self){ rating in
                            VStack{
                                HStack{
                                    ForEach(0..<Int(rating.rating), id: \.self){_ in
                                        Image(systemName: "star.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 10)
                                            .foregroundColor(.yellow)
                                    }
                                    ForEach(0..<5-Int(rating.rating), id: \.self){_ in
                                        Image(systemName: "star.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 10)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                }.padding(.vertical, 5)
                                HStack{
                                    Text(rating.comment)
                                    Spacer()
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(.plain)
            .refreshable {
                if let id = pump.id{
                    ldvm.getRatings(id: id)
                    ldvm.getFilenames(id: id)
                    Task {
                        do {
                            let data = try await mapAPI.updatePump(id: id)
                            pump = data
                        } catch {
                            print("Fehler: \(error)")
                        }
                    }
                }
            }
        }
    }
    /*
    var O: some View{
        HStack{
            OpeningHourUploadView()
        }
    }*/
    
    
    
    var Rating: some View{
        VStack{
            if let locationId = pump.id{
                VStack{
                    HStack{
                        Text("Rating")
                            .padding(.horizontal)
                            .font(.system(size: 50))
                            .bold()
                        Spacer()
                    }
                    RatingView(locationId: locationId, showRatingView: {
                        showRatingView.toggle()
                        //showCardView.toggle()
                    }).environmentObject(mapAPI)
                        .padding(.horizontal)
                    Spacer()
                }
            }
        }.toolbar{
            ToolbarItem(placement: .navigationBarLeading){
                Text("Rating")
            }
        }
    }
    
    
        
}

struct Opening: View {
    
    //@State var openingHour: OpeningHour?
    @Binding var openingHour: OpeningHours?
    @State var dayString: String
    @State var dayInt: Int
    
    
    var body: some View{
        HStack{
            Text("\(dayString):")
            Spacer()
            if let day = openingHour!.getOpeningHoursOfDay(day: dayInt){
                Text(String(format:"%02d:%02d-%02d:%02d", day.opening.hour, day.opening.minute, day.closing.hour, day.closing.minute))
                    .foregroundStyle(.secondary)
            }else{
                Text("closed")
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct PhotoUploader: View{
    
    @State var id: Int
    @EnvironmentObject var photoSelectorViewModel: PhotoSelectorViewModel
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View{
        VStack{
            PhotoSelector().environmentObject(photoSelectorViewModel)
            Spacer()
        }
        .toolbar{
            ToolbarItem(placement: .navigationBarTrailing){
                Button{
                    
                    photoSelectorViewModel.uploadImage(pumpId: id)
                    presentationMode.wrappedValue.dismiss()
                    
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
                Text("Upload Photo")
            }
        }
    }
}

struct DescriptionUploadView: View{
    
    @State var id: Int
    @State var text: String = ""
    @EnvironmentObject var vm: DetailViewModel
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View{
        VStack{
            TextField("Description", text: $text, axis: .vertical)
                .lineLimit(5...10)
                .padding()
                .background(RoundedRectangle(cornerSize: CGSize(width: 9, height: 9)).fill(.white.opacity(0.2)).stroke(.gray, lineWidth: 1))
                .padding()
            Spacer()
        }
        .toolbar{
            ToolbarItem(placement: .navigationBarTrailing){
                Button{
                    
                    presentationMode.wrappedValue.dismiss()
                    vm.postDescription(id: id, description: text)
                    
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
                Text("Desription")
            }
        }
    }
}

struct openingHourAddView: View {
    
    @State var day: String
    var openingHour: OpeningHour?{
        if day == "monday" {return vm.monday}
        if day == "tuesday" {return vm.tuesday}
        if day == "wednesday" {return vm.wednesday}
        if day == "thursday" {return vm.thursday}
        if day == "friday" {return vm.friday}
        if day == "saturday" {return vm.saturday}
        if day == "sunday" {return vm.sunday}
        return nil
    }
    @Binding var active: Bool
    @EnvironmentObject var vm: OpeningHourAddViewModel
    
    
    var body: some View {

        HStack{
            Toggle(day, isOn: $active)
                .toggleStyle(CheckboxToggleStyle())
            Spacer()
            if let d = openingHour{
                HStack{
                    Text(String(format:"%02d:%02d-%02d:%02d", d.opening.hour, d.opening.minute, d.closing.hour, d.closing.minute))
                        .foregroundColor(.secondary)
                    Button(action: {vm.deleteOpeningHour(day: day)}, label: {Image(systemName: "trash").foregroundColor(.primary)})
                }
            }else{
                Text("closed")
                    .foregroundColor(.secondary)
            }
        }
    }
    
    
}

struct OpeningHourUploadView: View{
    @EnvironmentObject var openingHourAddViewModel: OpeningHourAddViewModel
    @State var id: Int
    @State var openingTime: Date = Date()
    @State var closingTime: Date = Date()
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        Form{
            Toggle(isOn: $openingHourAddViewModel.alwaysOpen, label: {Text("always Open")})
                .toggleStyle(.switch)
            if(openingHourAddViewModel.activeDay && !openingHourAddViewModel.alwaysOpen){
                HStack{
                    DatePicker( "opening:" ,selection: $openingTime, displayedComponents: .hourAndMinute)
                        .onChange(of: openingTime){
                            openingHourAddViewModel.setOpeningHour(openingHour: OpeningHour(opening: Time(date: openingTime), closing: Time(date: closingTime)))
                        }
                    Spacer()
                    DatePicker("closing:" ,selection: $closingTime, displayedComponents: .hourAndMinute)
                        .onChange(of: closingTime){
                            openingHourAddViewModel.setOpeningHour(openingHour: OpeningHour(opening: Time(date: openingTime), closing: Time(date: closingTime)))
                        }
                }
            }
            if(!openingHourAddViewModel.alwaysOpen){
                openingHourAddView(day: "monday", active: $openingHourAddViewModel.mondayActive).environmentObject(openingHourAddViewModel)
                openingHourAddView(day: "tuesday", active: $openingHourAddViewModel.tuesdayActive).environmentObject(openingHourAddViewModel)
                openingHourAddView(day: "wednesday", active: $openingHourAddViewModel.wednesdayActive).environmentObject(openingHourAddViewModel)
                openingHourAddView(day: "thursday", active: $openingHourAddViewModel.thursdayActive).environmentObject(openingHourAddViewModel)
                openingHourAddView(day: "friday", active: $openingHourAddViewModel.fridayActive).environmentObject(openingHourAddViewModel)
                openingHourAddView(day: "saturday", active: $openingHourAddViewModel.saturdayActive).environmentObject(openingHourAddViewModel)
                openingHourAddView(day: "sunday", active: $openingHourAddViewModel.sundayActive).environmentObject(openingHourAddViewModel)
            }
        }
        .toolbar{
            ToolbarItem(placement: .navigationBarTrailing){
                Button{
                    
                    openingHourAddViewModel.postOpeningHours(id: id)
                    presentationMode.wrappedValue.dismiss()
                    //print("Test")
                    
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
                Text("Opening Hours")
            }
        }
    }
}

/*
#Preview {
    LocationDetailView()
}*/
