//
//  CameraScanHeaderView.swift
//  receipt_manage (iOS)
//
//  Created by 多根直輝 on 2021/06/26.
//

import SwiftUI

struct CameraScanHeaderView: View {
    @Binding var status: Status
    var body: some View {
        VStack{
            ZStack {
                Color("blackwhite")
                    .frame(width: .infinity, height: 50)
                HStack {
                    Button(action: {status = Status.createReceiptLine}){
                        Image(systemName: "square.and.pencil")
//                        Label("without image", systemImage: "square.and.pencil")
                            .resizable()
                            .foregroundColor(Color("labelText"))
                            .frame(width: 30, height: 30)
                            .padding(.leading, 20)
                        
                    }
                    Spacer()
                    Button(action: {status = Status.photoLibrary}){
                        Image(systemName: "photo")
                            .resizable()
                            .foregroundColor(Color("labelText"))
                            .frame(width: 30, height: 30)
                            .padding(.trailing, 20)
                    }
                    
                }
            }
            Spacer()
        }
    }
}

struct CameraScanHeaderView_Previews: PreviewProvider {
    @State static var status: Status = Status.home
    static var previews: some View {
        CameraScanHeaderView(status: $status)
    }
}
