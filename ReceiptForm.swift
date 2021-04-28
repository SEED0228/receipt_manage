//
//  ReceiptForm.swift
//  receipt_manage (iOS)
//
//  Created by 多根直輝 on 2021/04/09.
//
import UIKit
import SwiftUI
import SwiftyTesseract
import Firebase

struct ReceiptForm: View {
    // レシートフォーム用変数
    @State var date = Date()
    @State var store_name = ""
    @State var total_price = ""
    @State var items: [Item] = []
    // レシートの商品用変数
    @State var new_item = Item()
    @State var selected_item_id = UUID()
    // レシートリストに反映する用
    @EnvironmentObject var userData: UserData
    // リスト画面に戻る用
    @Environment(\.presentationMode) var presentationMode
    // 画像取得用
    @State var showingImagePicker = true
    @State var showingReceiptForm = false
    @State private var image: UIImage?
    @State var inPhotoLibrary: Bool? = nil
    
    var body: some View {
        if showingReceiptForm {
            Form {
                HStack {
                    Text("店名　　:")
                    TextField("入力してください", text: $store_name)
                }
                DatePicker("購入日　:", selection: $date)
            
                ForEach(items) { item in
                    if selected_item_id != item.id {
                        Button(action: {selectItem(item: item)})
                        {
                            HStack() {
                                Spacer()
                                if item.name == "" {
                                    Text("タップで新規商品を登録")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 12))
                                }
                                else {
                                    Text(item.name)
                                    Text("¥\(item.price)")
                                }
                                Spacer()
                            }
                        }
                    }
                    else {
                        HStack {
                            TextField("商品名", text: $new_item.name)
                            TextField("0", value: $new_item.price, formatter: NumberFormatter())
                        }
                        
                    }
                    
                }
                
                Button(action: {addItem()})
                {
                    HStack {
                        Spacer()
                        Text("商品追加")
                            .foregroundColor(.orange)
                            .font(.system(size: 12))
                        Spacer()
                    }
                }
            
                HStack {
                    Text("合計金額:")
                    TextField("0", text: $total_price).keyboardType(.numberPad)
                }
                
                Button(action: {createReceipt()})
                {
                    HStack {
                        Spacer()
                        Text("保存")
                            .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                        Spacer()
                    }
                   
                }
            }
            
        }
        else if inPhotoLibrary == nil {
            Form {
                Button(action: {
                    inPhotoLibrary = true
                })
                {
                    HStack {
                        Spacer()
                        Text("フォトライブラリから")
                        Spacer()
                    }
                    
                }
                Button(action: {
                    inPhotoLibrary = false
                })
                {
                    HStack {
                        Spacer()
                        Text("カメラから")
                        Spacer()
                    }
                    
                }
                Button(action: {
                    showingReceiptForm = true
                })
                {
                    HStack {
                        Spacer()
                        Text("画像なし")
                        Spacer()
                    }
                    
                }
            }
        }
        else {
            VStack {
                if let selectedImage = image {
                    GeometryReader { geometry in
                        VStack {
                            HStack {
                                Spacer()
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .frame(width: geometry.size.width / 2, height: geometry.size.height / 2, alignment: .center)
                                Spacer()
                            }
                            Form {
                                Button(action: {
                                    showingReceiptForm = true
                                    getReceiptInformation()
                                    
                                })
                                {
                                    HStack {
                                        Spacer()
                                        Text("確認")
                                        Spacer()
                                    }
                                }
                                Button(action: {
                                    inPhotoLibrary = nil
                                })
                                {
                                    HStack {
                                        Spacer()
                                        Text("戻る")
                                        Spacer()
                                    }
                                }
                            }
                            
                            Spacer()
                        }
                        
                    }
                }
                else {
                    Button(action: {
                        inPhotoLibrary = nil
                        showingImagePicker = true
                    })
                    {
                        Text("画像が選択されていません")
                    }
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                if inPhotoLibrary! {
                    ImagePicker(sourceType: .photoLibrary, selectedImage: $image)
                }
                else {
                    //ImagePicker(sourceType: .camera, selectedImage: $image)
                    ScanDocumentView(selectedImage: $image)
                }
                
            }
        }
        
    }
    // レシート新規作成用
    func createReceipt() {
        save_item()
        let newReceipt = Receipt(store_name: self.store_name, date: self.date, total_price: Int(self.total_price)!, items: self.items)
        
        self.userData.receipts.insert(newReceipt, at: 0)
        saveReceiptsToDevise()

        if presentationMode.wrappedValue.isPresented {
            presentationMode.wrappedValue.dismiss() //close this view
        }
    }
    // 編集する商品を選択する用
    func selectItem(item: Item) {
        save_item()
        new_item = Item()
        selected_item_id = item.id
        new_item = item
    }
    // 新規商品の追加
    func addItem() {
        items.append(Item())
    }
    // 編集した商品を元の商品リストに保存
    func save_item() {
        if let index = items.firstIndex(where: {$0.id == selected_item_id}) {
            items[index] = new_item
        }
    }
    // 端末にデータを保存
    func saveReceiptsToDevise() {
        let data = self.userData.receipts.map { try? JSONEncoder().encode($0) }
        UserDefaults.standard.set(data, forKey: "receipts")
    }
    // レシートのテキストを取得
    func getReceiptInformation() {
        //################### use swiftytesseract
//        let start = Date()
//        let swiftyTesseract = SwiftyTesseract(language: RecognitionLanguage.japanese)
//        if let acquired_image = image {
//            swiftyTesseract.performOCR(on: acquired_image) { recognizedString in
//            guard let text = recognizedString else { return }
//            print("\(text)")
//
//            print("\(-start.timeIntervalSinceNow)")
//        }
        let vision = Vision.vision()
        let options = VisionCloudTextRecognizerOptions()
        options.languageHints = ["en", "ja"]
        let textRecognizer = vision.cloudTextRecognizer(options: options)
        let visionimage = VisionImage(image: image!)
        textRecognizer.process(visionimage) { result, error in
          guard error == nil, let result = result else {
            return
          }
            // 値段を記載している箇所を取得
            var price_lines: [VisionTextLine] = []
            // 全文字列を取得
            var acquired_lines: [VisionTextLine] = []
            // 省くものリスト（完全一致）
            let ExactMatchOmittionList: [String] = ["小計", "外税", "外税売"]
            // 省くものリスト（部分一致）
            let PartialMatchOmittionList: [String] = ["値引","端数","税"]
            for block in result.blocks {
                var cnt = 0
                for line in block.lines {
//                    print("word: " + line.text)
//                    print(line.frame.origin.x)
//                    print(line.frame.origin.y)
                    print(String(cnt) + "," + line.text + "," + String(format: "%.01f", Float(line.frame.origin.x)) + "," + String(format: "%.01f", Float(line.frame.origin.y)) )
                    cnt += 1
                    if line.text.contains("¥") {
                        price_lines.append(line)
//                        print(line.text)
                    }
                    else {
                        acquired_lines.append(line)
                    }
                }
                
            }
            // y座標、昇順に並び替え
            acquired_lines = acquired_lines.sorted(by: {
                $0.frame.origin.y < $1.frame.origin.y
            } )
            // 先頭の文字列を店名とする
            store_name = acquired_lines[0].text
            price: for price_line in price_lines {
                var min_dist:CGFloat = 10000.0
                var name: String = ""
                acquired: for acquired_line in acquired_lines {
                    if min_dist > abs(acquired_line.frame.origin.y - price_line.frame.origin.y) {
                        min_dist = abs(acquired_line.frame.origin.y - price_line.frame.origin.y)
                        name = acquired_line.text
                    }
                    if price_line.frame.origin.y < acquired_line.frame.origin.y {
                        print(name)
                        if name == "合" || name == "計" || name == "合計" {
                            total_price = String(NumericalExtraction(price_line.text))
                            break price
                        }
                        else {
                            for str in PartialMatchOmittionList {
                                if name.contains(str) {
                                    break acquired
                                }
                            }
                            if ExactMatchOmittionList.firstIndex(where: {$0 == name}) == nil  {
                                items.append(Item(name: name, price: NumericalExtraction(price_line.text)))
                            }
                            break
                        }
                        
                    }
                }
            }
        }
    }
    //　数値の抽出
    func NumericalExtraction(_ str: String) -> Int {
        let splitNumbers = (str.components(separatedBy: NSCharacterSet.decimalDigits.inverted))
        let number = splitNumbers.joined()
        return Int(number) ?? 0
    }
    

}

struct ReceiptForm_Previews: PreviewProvider {
    static var previews: some View {
        ReceiptForm()
            .environmentObject(UserData())
        
    }
}


