//
//  ScanDocumentView.swift
//  receipt_manage (iOS)
//
//  Created by 多根直輝 on 2021/04/16.
//

import SwiftUI
import VisionKit
struct ScanDocumentView: UIViewControllerRepresentable {
    
    @Environment(\.presentationMode) var presentationMode
    typealias UIViewControllerType = VNDocumentCameraViewController
  
    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        // to implement
        let documentViewController = VNDocumentCameraViewController()
        documentViewController.delegate = context.coordinator
        return documentViewController
    }
    
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {
                // nothing to do here
    }
    
//    @Binding var recognizedText: String
    @Binding var selectedImages: [UIImage]?
    @Binding var status: Status
        
    func makeCoordinator() -> Coordinator {
        Coordinator(selectedImages: $selectedImages, status: $status, parent: self)
    }
    
    final class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
      
        var selectedImages: Binding<[UIImage]?>
        var status: Binding<Status>
        var parent: ScanDocumentView
        
        init(selectedImages: Binding<[UIImage]?>, status: Binding<Status>, parent: ScanDocumentView) {
            self.selectedImages = selectedImages
            self.status = status
            self.parent = parent
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            // do the processing of the scan
//            let extractedImages = extractImages(from: scan)
            selectedImages.wrappedValue = extractImages(from: scan)
//            let processedText = recognizeText(from: extractedImages)
//            recognizedText.wrappedValue = processedText
//            parent.presentationMode.wrappedValue.dismiss()
            if scan.pageCount == 0 {
                status.wrappedValue = Status.home
            }
            else {
                status.wrappedValue = Status.selectImages
            }
            
            
        }
        
        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController){
            status.wrappedValue = Status.home
        }
    }
}


fileprivate func extractImages(from scan: VNDocumentCameraScan) -> [UIImage]? {
    var images: [UIImage] = []
    for i in 0..<scan.pageCount {
        images.append(scan.imageOfPage(at: i))
    }
    return images
}

