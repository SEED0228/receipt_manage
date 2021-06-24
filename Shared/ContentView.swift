//
//  ContentView.swift
//  Shared
//
//  Created by 多根直輝 on 2021/04/08.
//
import UIKit
import SwiftUI
import SwiftyTesseract
import Firebase



struct ContentView: View {
    @EnvironmentObject var userData: UserData
    
    init() {
        // ################## swiftytesseract test
//        let start = Date()
//        let swiftyTesseract = SwiftyTesseract(language: RecognitionLanguage.japanese)
//        let fileName = "sample.png"
//        guard let image = UIImage(named: fileName) else { return }
//
//        swiftyTesseract.performOCR(on: image) { recognizedString in
//            guard let text = recognizedString else { return }
//            print("\(text)")
//
//            print("\(-start.timeIntervalSinceNow)")
//        }

        
        // ################## firebase mlkit test
//        let vision = Vision.vision()
//        let options = VisionCloudTextRecognizerOptions()
//        options.languageHints = ["en", "ja"]
//        let textRecognizer = vision.cloudTextRecognizer(options: options)
//        let fileName = "sample.png"
//        guard let uiImage = UIImage(named: fileName) else { return }
//        let image = VisionImage(image: uiImage)
//        textRecognizer.process(image) { result, error in
//          guard error == nil, let result = result else {
//            return
//          }
//            let resultText = result.text
//            //print(resultText)
//            for block in result.blocks {
//                let blockText = block.text
//                print(blockText)
//
//            }
//        }
    }
    
    var body: some View {
        NavigationView(){
            List {
                ForEach(userData.receipts) { receipt in
                    VStack {
                        if userData.delete_option {
                            
                            Button(action: {
                                let index = self.userData.receipts.firstIndex(of: receipt)
                                
                                self.userData.receipts[index!].is_deleted.toggle()
                            }){
                                ReceiptListRow(receipt: receipt, delete_option: userData.delete_option)
                            }
                        }
                        else {
                        Button(action: {display_action(receipt)})
                            {
                                ReceiptListRow(receipt: receipt, delete_option: userData.delete_option)
                            }
                            //if receipt.is_selected || receipt.items.count == 0 {
                            if receipt.items.count == 0 {
                                Text("no items")
                            }
                            else if receipt.is_selected {
                                ForEach(receipt.items) { item in
                                    ItemListRow(item: item)
                                }
                            }
                            
                        }
                    }
                }
                .onDelete(perform: { indexSet in
                    self.userData.receipts.remove(at: indexSet.first!)
                    saveReceiptsToDevise()
                  })
                
                
                HStack {
                    NavigationLink(destination: ReceiptForm()) {
                        Spacer()
                        Text("+")
                            .font(.title)
                        Spacer()
                    }
                }
                .onAppear { load_receipts() }
            }
            .navigationBarTitle(Text("Reseipt"))
            .navigationBarItems(trailing: Button(action:{
                userData.delete_option.toggle()
                for receipt in userData.receipts {
                    let index = self.userData.receipts.firstIndex(of: receipt)
                    if userData.delete_option {
                        self.userData.receipts[index!].is_selected = false
                    }
                }
                self.userData.receipts = self.userData.receipts.filter({!$0.is_deleted})
                saveReceiptsToDevise()
            })
            {
                Text("Delete")
            }
            )

        }
        
    }
    
    func display_action(_ receipt: Receipt) {
        let index = self.userData.receipts.firstIndex(of: receipt)
        self.userData.receipts[index!].is_selected.toggle()
    }
    
    func load_receipts() {
        if let data = UserDefaults.standard.array(forKey: "receipts") as? [Data] {
            let receipts = data.map { try! JSONDecoder().decode(Receipt.self, from: $0) }
            userData.receipts = receipts
        }
    }
    
    func saveReceiptsToDevise() {
        let data = self.userData.receipts.map { try? JSONEncoder().encode($0) }
        UserDefaults.standard.set(data, forKey: "receipts")
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(UserData())
    }
}
