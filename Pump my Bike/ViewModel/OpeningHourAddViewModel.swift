import Foundation

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
