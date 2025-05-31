import Foundation
import _PhotosUI_SwiftUI
import UIKit


@MainActor
class PhotoSelectorViewModel: ObservableObject{
    
    @Published var selectedImage: UIImage? = nil
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
