//
//  PhotoUploader.swift
//  Pump my Bike
//
//  Created by Milos Denck on 07.06.25.
//

import SwiftUI

struct PhotoUploader: View{
    
    @State var id: Int
    @EnvironmentObject var photoSelectorViewModel: PhotoSelectorViewModel
    @EnvironmentObject var mapAPI: MapAPI
    @EnvironmentObject var lvdm: DetailViewModel
    @Environment(\.presentationMode) private var presentationMode
    
    @State var showSelection: Bool = false
    @State var showPicker: Bool = false
    @State var type: UIImagePickerController.SourceType = .camera
    
    var body: some View{
        VStack{
            PhotoSelector(showSelector: $showSelection).environmentObject(photoSelectorViewModel)
            Spacer()
        }
        
        .toolbar{
            ToolbarItem(placement: .navigationBarTrailing){
                Button{
                    Task{
                        guard let image = photoSelectorViewModel.selectedImage else{
                            return
                        }
                        try await mapAPI.uploadImage(image: image, pumpId: id)
                        lvdm.getFilenames(id: id)
                        presentationMode.wrappedValue.dismiss()
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
                Text("Upload Photo")
            }
        }
        .confirmationDialog("select", isPresented: $showSelection,titleVisibility: .hidden){

            
            Button("camera") {
                showPicker = true
                type = .camera
            }
            
            Button("photo library") {
                showPicker = true
                type = .photoLibrary
                
            }
        }
        .fullScreenCover(isPresented: $showPicker) {
            ImagePickerView(sourceType: type) { image in
                photoSelectorViewModel.selectedImage = image
            }.ignoresSafeArea()
        }
    }
}

#Preview {
    //PhotoUploader()
}
