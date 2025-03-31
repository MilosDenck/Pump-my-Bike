//
//  LocationMarkerView.swift
//  Pump my Bike
//
//  Created by Milos Denck on 05.09.23.
//

import SwiftUI

struct LocationMarkerView: View {
    
    var col: Color? = .green
    
    var body: some View {
        VStack(spacing: 0){
            Image(systemName: "bicycle.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 30)
                .foregroundColor(.white)
                .padding(5)
                .background(col)
                .cornerRadius(35)
            Image(systemName: "triangle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 12)
                .foregroundColor(col)
                .rotationEffect(Angle(degrees: 180))
                .offset(y: -2)
                .padding(.bottom, 42)
        }
    }
}

struct selectedLocationMarkerView: View{
    @State var col: Color = .orange
    
    var body: some View{
        VStack(spacing: 0){
            Image(systemName: "location.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 25)
                .foregroundColor(.white)
                .padding(5)
                .background(col)
                .cornerRadius(35)
            Image(systemName: "triangle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 10)
                .foregroundColor(col)
                .rotationEffect(Angle(degrees: 180))
                .offset(y: -2)
                .padding(.bottom, 42)
        }
    }
}


struct LocationMarkerView_Previews: PreviewProvider {
    static var previews: some View {
        LocationMarkerView()
    }
}
