//
//  DecriptionUploadView.swift
//  Pump my Bike
//
//  Created by Milos Denck on 07.06.25.
//

import SwiftUI

struct DescriptionUploadView: View{
    
    @State var id: Int
    @State var text: String = ""
    @EnvironmentObject var vm: DetailViewModel
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View{
        VStack{
            CustomTextEditor(title: "Description", text: $text)
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
                Text("Description")
            }
        }
    }
}

#Preview {
    //DecriptionUploadView()
}
