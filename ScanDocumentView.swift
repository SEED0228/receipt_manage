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
    @Binding var selectedImage: UIImage?
        
    func makeCoordinator() -> Coordinator {
        Coordinator(selectedImage: $selectedImage, parent: self)
    }
    
    final class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
      
        var selectedImage: Binding<UIImage?>
        var parent: ScanDocumentView
        
        init(selectedImage: Binding<UIImage?>, parent: ScanDocumentView) {
            self.selectedImage = selectedImage
            self.parent = parent
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            // do the processing of the scan
//            let extractedImages = extractImages(from: scan)
            selectedImage.wrappedValue = extractImage(from: scan)
//            let processedText = recognizeText(from: extractedImages)
//            recognizedText.wrappedValue = processedText
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

//fileprivate func extractImages(from scan: VNDocumentCameraScan) -> [CGImage] {
//    var extractedImages = [CGImage]()
//    for index in 0..<scan.pageCount {
//        let extractedImage = scan.imageOfPage(at: index)
//        guard let cgImage = extractedImage.cgImage else { continue }
//
//        extractedImages.append(cgImage)
//    }
//    return extractedImages
//}

fileprivate func extractImage(from scan: VNDocumentCameraScan) -> UIImage? {
    return scan.imageOfPage(at: scan.pageCount - 1)
}

//fileprivate func recognizeText(from images: [CGImage]) -> String {
//    var entireRecognizedText = ""
//    let recognizeTextRequest = VNRecognizeTextRequest { (request, error) in
//        guard error == nil else { return }
//
//        guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
//
//        let maximumRecognitionCandidates = 1
//        for observation in observations {
//            guard let candidate = observation.topCandidates(maximumRecognitionCandidates).first else { continue }
//
//            entireRecognizedText += "\\(candidate.string)\\n"
//
//        }
//    }
//    recognizeTextRequest.recognitionLevel = .accurate
//
//    for image in images {
//        let requestHandler = VNImageRequestHandler(cgImage: image, options: [:])
//
//        try? requestHandler.perform([recognizeTextRequest])
//    }
//
//    return entireRecognizedText
//}

