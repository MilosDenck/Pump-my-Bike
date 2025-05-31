//
//  RatingAddView.swift
//  Pump my Bike
//
//  Created by Milos Denck on 07.06.25.
//

import SwiftUI

struct RatingAddView: View {
    @AppStorage("loggedIn") private var loggedIn = false
    @EnvironmentObject var ratingAPI: RatingAPI
    
    @State var rating: Int = 0
    @State var comment: String = ""
    @State var locationId: Int
    
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
            CustomTextEditor(title: "Comment", text: $comment)
            HStack{
                Button(action: {
                    Task{
                        guard rating > 0 else {return}
                        let rat = Rating(rating: rating, comment: comment, locationId: locationId)
                        try await ratingAPI.postRating(rating: rat)
                        try await ratingAPI.updateRatings()
                        rating = 0
                        comment = ""
                    }
                }, label: {
                    Text("comment")
                        .foregroundColor(.white)
                        .padding(13)
                        .font(.footnote)
                        .frame(maxWidth: .infinity)
                        .background(RoundedRectangle(cornerSize: CGSize(width: 5, height: 5)).fill(.black))
                        .padding(.horizontal, 10)
                })
            }
        }
        .frame(maxWidth: .infinity)
    }
}
#Preview {
    //RatingAddView()
}
