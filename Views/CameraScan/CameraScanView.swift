//
//  CameraView.swift
//  receipt_manage (iOS)
//
//  Created by 多根直輝 on 2021/06/26.
//

import SwiftUI

struct CameraScanView: View {
    @State private var image: UIImage?
    @Binding var status: Status
    @Binding var scanned_images: [UIImage]?
    var body: some View {
        ZStack {
            ScanDocumentView(selectedImages: $scanned_images, status: $status)
                .padding(.top, 50)
            CameraScanHeaderView(status: $status)
        }
    }
}

struct CameraScanView_Previews: PreviewProvider {
    
    @State static var status: Status = Status.home
    @State static var scanned_images: [UIImage]? = nil
    static var previews: some View {
        CameraScanView(status: $status, scanned_images: $scanned_images)
    }
}
