//
//  CreateReceiptHeaderView.swift
//  receipt_manage (iOS)
//
//  Created by 多根直輝 on 2021/06/28.
//

import SwiftUI

struct CreateReceiptHeaderView: View {
    @Binding var status: Status
    
    var body: some View {
        VStack{
            ZStack {
                Color("blackwhite")
                    .frame(width: .infinity, height: 50)
                HStack {
                    Button(action: {status = Status.home}){
                        Image(systemName: "arrowshape.turn.up.backward")
//                        Label("without image", systemImage: "square.and.pencil")
                            .resizable()
                            .foregroundColor(Color("labelText"))
                            .frame(width: 30, height: 30)
                            .padding(.leading, 20)
                        
                    }
                    Spacer()
                    
                }
            }
            Spacer()
        }
    
    }
}

struct CreateReceiptHeaderView_Previews: PreviewProvider {
    @State static var status: Status = Status.home
    static var previews: some View {
        CreateReceiptHeaderView(status: $status)
    }
}
