//
//  RouteCard.swift
//  Pump my Bike
//
//  Created by Milos Denck on 06.06.25.
//

import SwiftUI

struct RouteCard: View {
    
    @EnvironmentObject var mapAPI:MapAPI
    
    var body: some View {
        GeometryReader{ geometry in
            VStack{
                Spacer()
                VStack{
                    if let route = mapAPI.route{
                        Text("Route")
                            .frame(alignment: .leading)
                            .font(.system(size: 18))
                            .bold()
                        Rectangle().fill(.secondary)
                            .frame(width: geometry.size.width*0.85, height: 1)
                        Text("\(route.name) - \(mapAPI.currentPin!.name ?? "")")
                            .font(.system(size: 12))
                        Text(String(format: "%.1f km",route.distance/1000))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                }
                .frame(maxWidth: .infinity)
                .padding(10)
                .background(RoundedRectangle(cornerSize: CGSize(width: 5, height: 5)).fill(.ultraThinMaterial))
                .padding(10)
            }
        }
    }
}

#Preview {
    RouteCard()
}
