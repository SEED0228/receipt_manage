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
                    .datePickerStyle(WheelDatePickerStyle())
            
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
                                    getReceiptInformation2() //////////////////////////////////////////////
                                    
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
            // 全文字列を取得
            var acquired_lines: [VisionTextLine] = []
            // 値段を記載している箇所を取得
            var price_lines: [VisionTextLine] = []
            // 省くものリスト（完全一致）
            let ExactMatchOmittionList: [String] = ["外税", "外税売"]
            // 省くものリスト（部分一致）
            let PartialMatchOmittionList: [String] = ["値引","端数","税","小計"]
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
    
    func getReceiptInformation2() {
        let vision = Vision.vision()
        let options = VisionCloudTextRecognizerOptions()
        options.languageHints = ["en", "ja"]
        let textRecognizer = vision.cloudTextRecognizer(options: options)
        let visionimage = VisionImage(image: image!)
        textRecognizer.process(visionimage) { result, error in
          guard error == nil, let result = result else {
            return
          }
            // 全文字列を取得
            let lines: [VisionTextLine] = getReceiptLines(result: result)
            let lines_group: [[VisionTextLine]] = getReceiptLinesGroup(lines: lines)
            printReceiptLineLanguage(lines_group: lines_group, lines: lines)
            if LogoCheck() == "familymart" {
                
            }
            else {
                
            }
        }
    }
    
    
    
    //　数値の抽出
    func NumericalExtraction(_ str: String) -> Int {
        let splitNumbers = (str.components(separatedBy: NSCharacterSet.decimalDigits.inverted))
        let number = splitNumbers.joined()
        return Int(number) ?? 0
    }
    
    func getReceiptLines(result: VisionText) -> [VisionTextLine] {
        var lines: [VisionTextLine] = []
        for block in result.blocks {
            var cnt = 0
            for line in block.lines {
                //print(String(cnt) + "," + line.text + "," + String(format: "%.01f", Float(line.frame.origin.x)) + "," + String(format: "%.01f", Float(line.frame.origin.y)) )
                cnt += 1
                lines.append(line)
                
            }
        }
        // y座標、昇順に並び替え
        lines = lines.sorted(by: {
            $0.frame.origin.y < $1.frame.origin.y
        } )
        return lines
    }
    
    
    
    func getReceiptLinesGroup(lines: [VisionTextLine]) -> [[VisionTextLine]] {
        
        var min_height: CGFloat = 100000.0
        for line in lines {
            if line.frame.size.height < min_height {
                min_height = line.frame.size.height
            }
        }
        var lines_group = [[lines[0]]]
        var right_lines: [VisionTextLine] = []
        var current_index = 0
        for i in 1..<(lines.count) {
            // (テキストの左端が半分以上でかつテキストの右端がレシートの5/7)後で処理
            if Float(lines[i].frame.origin.x) >= Float(image!.size.width) / 2.0
                && Float(lines[i].frame.origin.x) + Float(lines[i].frame.size.width) >= Float(image!.size.width) * 5 / 7 {
                right_lines.append(lines[i])
            }
            else if abs(Float(lines[i].frame.origin.y) - Float(lines[i-1].frame.origin.y)) < Float(min_height) * 2.0 / 5.0 {
                lines_group[current_index].append(lines[i])
            }
            else {
                lines_group[current_index] = lines_group[current_index].sorted(by: {
                    $0.frame.origin.x < $1.frame.origin.x
                } )
                lines_group.append([lines[i]])
                current_index += 1
            }
        }
        for line in right_lines {
            var min_dist:CGFloat = 10000.0
            var min_index = -1
            for (i, lines) in lines_group.enumerated() {
                if min_dist > abs(lines.last!.frame.origin.y - line.frame.origin.y) {
                    min_dist = abs(lines.last!.frame.origin.y - line.frame.origin.y)
                    min_index = i
                }
                if line.frame.origin.y < lines.last!.frame.origin.y {
                    if min_dist > abs(line.frame.origin.y - lines.last!.frame.origin.y) {
                        min_dist = abs(line.frame.origin.y - lines.last!.frame.origin.y)
                        min_index = i
                    }
                    lines_group[min_index].append(line)
                    break
                }
            }
        }
        
        return lines_group
    }
    
    func printReceiptLineLanguage(lines_group: [[VisionTextLine]], lines: [VisionTextLine]) {
        var line_width_text = ""
        var line_text = ""
        var double_angle_text = ""
        var min_height_line: VisionTextLine = lines[0]
        var min_height: CGFloat = 10000.0
        for line in lines {
            if min_height > line.frame.size.height {
                min_height = line.frame.size.height
                min_height_line = line
            }
        }
        let char_count = characterCount(line: min_height_line)
        var prev_x: CGFloat
        for g_lines in lines_group {
            line_width_text = "{width:"
            line_text = "||"
            double_angle_text = ""
            prev_x = 0.0
            for (i, line) in g_lines.enumerated() {
//                    print(String(cnt) + "," + line.text
//                            + "," + String(format: "%.01f", Float(line.frame.origin.x))
//                            + "," + String(format: "%.01f", Float(line.frame.origin.y))
//                            + "," + String(format: "%.01f",Float(line.frame.size.width))
//                            + "," + String(format: "%.01f",Float(line.frame.size.height)), terminator: " ")
                for _ in 1..<max(1, Int(floor(line.frame.size.height / min_height * 2 / 3))) {
                    double_angle_text += "^"
                }
                line_width_text += String(Int((line.frame.origin.x - prev_x) / image!.size.width * CGFloat(char_count))) + ","
                if i > 0 && Float(line.frame.origin.x) + Float(line.frame.size.width) >= Float(image!.size.width) * 5 / 7 {
                    line_text += " " + double_angle_text + line.text + "|"
                }
                else {
                    line_text += double_angle_text + line.text + " |"
                }
                prev_x = line.frame.origin.x
            }
            line_width_text += String(Int((image!.size.width - prev_x) / image!.size.width * CGFloat(char_count))) + "}"
            print(line_width_text)
            print(line_text)
        }
    }
    
    //文字数カウント
    func characterCount(line: VisionTextLine) -> Int {
        let textArray = Array(line.text).map { String($0) }
        var count = 0
        let format = "[ -~]"
        let regexp = try! NSRegularExpression.init(pattern: format, options: [])
        for i in 0..<line.text.count {
            let matchRet = regexp.firstMatch(in: textArray[i], options: [], range: NSRange.init(location: 0, length: 1))
            if matchRet != nil {
                count += 1
            }
            else {
                count += 2
            }
        }
        print(line.text)
        print(count)
        print(line.frame.size.width)
        print(image!.size.width)
        return Int(Float(count) * Float(image!.size.width / line.frame.size.width) )
    }

    //パターン認識でロゴをチェック（予定）
    func LogoCheck() -> String {
        return "familymart"
    }
    
}

struct ReceiptForm_Previews: PreviewProvider {
    static var previews: some View {
        ReceiptForm()
            .environmentObject(UserData())
        
    }
}


