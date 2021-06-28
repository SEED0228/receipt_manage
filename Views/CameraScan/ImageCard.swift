//
//  ImageCard.swift
//  receipt_manage (iOS)
//
//  Created by 多根直輝 on 2021/06/26.
//

import SwiftUI

struct ImageCard: View {
    var image:UIImage?
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color("background")
                    .edgesIgnoringSafeArea(.all)
                HStack {
                    Spacer()
                    Image(uiImage: image!)
                        .resizable()
                        .frame(width: geometry.size.width * 4 / 5)
                    Spacer()
                }
                VStack {
                    Rectangle()
                        .frame(width: geometry.size.width * 4 / 5, height: 2)
                        .foregroundColor(.gray)
                        .padding(.top, geometry.size.height / 5)
                    Rectangle()
                        .frame(width: geometry.size.width * 4 / 5, height: 2)
                        .foregroundColor(.gray)
                        .padding(.top, geometry.size.height / 5)
                    Rectangle()
                        .frame(width: geometry.size.width * 4 / 5, height: 2)
                        .foregroundColor(.gray)
                        .padding(.top, geometry.size.height / 5)
                    Rectangle()
                        .frame(width: geometry.size.width * 4 / 5, height: 2)
                        .foregroundColor(.gray)
                        .padding(.top, geometry.size.height / 5)
                    Spacer()
                }
            }
        }
        
    }
}

struct ImageCard_Previews: PreviewProvider {
    @State static var image: UIImage? = UIImage(named: "samplereceipt")
    static var previews: some View {
        ImageCard(image: image)
    }
}
