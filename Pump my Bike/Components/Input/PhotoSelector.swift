//
//  PhotoSelector.swift
//  Pump my Bike
//
//  Created by Milos Denck on 06.06.25.
//

import SwiftUI
import PhotosUI


struct PhotoSelector: View{
    
    @EnvironmentObject var vm: PhotoSelectorViewModel
    
    @Binding var showSelector: Bool
    
    var body: some View{
        ZStack{
            VStack{
                if let image = vm.selectedImage{
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .clipped()
                        .shadow(radius: 3)
                }else{
                    Image(systemName: "camera")
                        .resizable()
                        .padding(20)
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .foregroundStyle(.black)
                        .clipShape(Circle())
                        .clipped()
                }
            }
            Image(systemName: "pencil.circle.fill")
                .resizable()
                .foregroundStyle(.green)
                .background(.white)
                .clipShape(Circle())
                .clipped()
                .offset(x: 40, y:40)
                .frame(width: 30, height: 30)
                .onTapGesture {
                    showSelector = true
                }
        }
        
    }
}

#Preview {
    //PhotoSelector()
}
