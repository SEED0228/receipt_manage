//
//  SelectImageView.swift
//  receipt_manage (iOS)
//
//  Created by 多根直輝 on 2021/06/26.
//

import SwiftUI

struct SelectImageView: View {
    @Binding var scanned_images: [UIImage]?
    @Binding var selected_image: UIImage?
    @Binding var status: Status
    @State var currentPage: Int = 0
    var body: some View {
        ZStack {
            Color("background")
                .edgesIgnoringSafeArea(.all)
            if scanned_images!.count > 1 {
                PageView(pages: scanned_images!.map { ImageCard(image: $0) }, currentPage: $currentPage)
                    .aspectRatio(2 / 3, contentMode: .fit)
                    .listRowInsets(EdgeInsets())
            }
            else {
                ImageCard(image: scanned_images![0])
            }
            
            VStack {
                Spacer()
                Button(action: {
                        selected_image = scanned_images![currentPage]
                }){
                    Text("Choose this")
                        .fontWeight(.semibold)
                        .frame(width: 160, height: 48)
                        .foregroundColor(Color(.white))
                        .background(Color(.blue))
                        .cornerRadius(24)
                        .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                        .padding(20)
                }
            }
        }
    }
    
    
}

struct SelectImageView_Previews: PreviewProvider {
    @State static var images: [UIImage]? = nil
    @State static var image: UIImage? = UIImage(named: "samplereceipt")
    @State static var status: Status = Status.home
    static var previews: some View {
        SelectImageView(scanned_images: $images, selected_image: $image, status: $status)
    }
}
