//
//  ratingView.swift
//  Pump my Bike
//
//  Created by Milos Denck on 22.09.23.
//

import SwiftUI

struct RatingView: View {
    
    @State var rating: Int = 0
    @State var comment: String = ""
    @State var locationId: Int
    @EnvironmentObject var mapAPI: MapAPI
    var showRatingView: () -> ()
    
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        VStack{
            HStack{
                ForEach(0..<rating, id: \.self){ i in
                    Image(systemName: "star.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30)
                            .foregroundColor(.yellow)
                            .onTapGesture {
                                if(self.rating + i + 1 > 5) {return}
                                self.rating = i + 1
                            }
                            .shadow(radius: 3)
                }
                ForEach(0..<(5-rating), id:\.self){ i in
                    Image(systemName: "star.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30)
                            .foregroundColor(.secondary)
                            .onTapGesture {
                                if(self.rating + i + 1 > 5) {return}
                                self.rating = self.rating + i + 1
                            }
                            .shadow(radius: 3)
                    
                }
            }
                .padding(15)
            TextField("Comment", text: $comment, axis: .vertical)
                .padding(10)
                .lineLimit(5...7)
                .background(RoundedRectangle(cornerSize: CGSize(width: 5, height: 5)).fill(.white.opacity(0.5)).stroke(.gray, lineWidth: 1).shadow(radius: 5))
                .padding(5)
            HStack{
                Button(action: {
                    showRatingView()
                    rating = 0
                    comment = ""
                    
                }, label: {
                    Text("abort")
                        .foregroundColor(.white)
                        .padding(7)
                        .frame(maxWidth: .infinity)
                        .background(RoundedRectangle(cornerSize: CGSize(width: 5, height: 5)).fill(.blue.opacity(0.5)).shadow(radius: 7))
                    
                        .padding(5)
                })
                Button(action: {
                    let rat = Rating(rating: rating, comment: comment, locationId: locationId)
                    mapAPI.postRating(rating: rat)
                    showRatingView()
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Text("comment")
                        .foregroundColor(.white)
                        .padding(7)
                        .frame(maxWidth: .infinity)
                        .background(RoundedRectangle(cornerSize: CGSize(width: 5, height: 5)).fill(.blue.opacity(0.5)).shadow(radius: 7))
                    
                        .padding(5)
                })
            }
            
        }
            .frame(maxWidth: .infinity)
            
    }
}
/*
#Preview {
    RatingView()
}
*/
