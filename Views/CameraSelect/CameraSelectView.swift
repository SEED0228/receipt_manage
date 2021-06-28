//
//  CameraSelectView.swift
//  receipt_manage (iOS)
//
//  Created by 多根直輝 on 2021/06/26.
//

import SwiftUI



struct CameraSelectView: View {
    @Binding var status: Status
    @Binding var receipt_line: ReceiptLine
    var body: some View {
        ZStack{
            CameraSelectHeaderView()
            VStack {
                Button(action:{status = Status.scan}){
                    Image(systemName: "camera")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(Color("labelText"))
                        .background(Color(red: 0, green: 0, blue: 0, opacity: 0))
                        .overlay(Circle()
                                    .stroke(Color("labelText"), lineWidth: 4)
                                    .frame(width: 200, height: 200)
                        )
                        .padding(100)
                }
                HStack {
                    Button(action:{status = Status.createReceiptLine}){
                        Image(systemName: "square.and.pencil")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(Color("labelText"))
                            .background(Color(red: 0, green: 0, blue: 0, opacity: 0))
                            .overlay(Circle()
                                        .stroke(Color("labelText"), lineWidth: 4)
                                        .frame(width: 100, height: 100)
                            )
                            .padding(50)
                    }
                    Button(action:{status = Status.photoLibrary}){
                        Image(systemName: "photo")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(Color("labelText"))
                            .background(Color(red: 0, green: 0, blue: 0, opacity: 0))
                            .overlay(Circle()
                                        .stroke(Color("labelText"), lineWidth: 4)
                                        .frame(width: 100, height: 100)
                            )
                            .padding(50)
                    }
                }
               
            }
            
        }
        .onAppear() {
            receipt_line = ReceiptLine()
        }
    }
}

struct CameraSelectView_Previews: PreviewProvider {
    
    @State static var status: Status = Status.home
    @State static var receipt_line: ReceiptLine = ReceiptLine()
    
    static var previews: some View {
        CameraSelectView(status: $status, receipt_line: $receipt_line)
    }
}
