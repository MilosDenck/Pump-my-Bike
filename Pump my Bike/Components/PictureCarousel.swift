//
//  PictureCarousel.swift
//  Pump my Bike
//
//  Created by Milos Denck on 06.06.25.
//

import SwiftUI

struct PictureCarousel: View {
    @State var pump: PumpData
    @EnvironmentObject var mapAPI:MapAPI
    @StateObject var ldvm: DetailViewModel
    @StateObject var photoSelectorViewModel = PhotoSelectorViewModel()
    
    var body: some View{
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
}

#Preview {
    //PictureCarousel()
}
