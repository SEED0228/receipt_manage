//
//  CameraSelectHeaderView.swift
//  receipt_manage (iOS)
//
//  Created by 多根直輝 on 2021/06/26.
//

import SwiftUI

struct CameraSelectHeaderView: View {
    var body: some View {
        VStack() {
            HStack{
                Text("Add Receipt")
                    .font(.title)
                    .bold()
                    .padding(.leading, 20)
                    .padding(.top, 30)
                Spacer()
            }
            Spacer()
        }
    }
}

struct CameraSelectHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        CameraSelectHeaderView()
    }
}
