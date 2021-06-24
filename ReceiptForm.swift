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
    // 状態
    enum FM_status: Int {
        case branch = 0
        case address = 1
        case daytime = 2
        case registration = 3
        case item = 4
        case total_price = 5
        case accounting = 6
        case payment = 7
    }
    // レシートフォーム用変数
    @State var date = Date()
    @State var store_name = ""
    @State var total_price = ""
    @State var items: [Display_Item] = []
    // レシートの商品用変数
    @State var new_item = Display_Item()
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
    func selectItem(item: Display_Item) {
        save_item()
        new_item = Display_Item()
        selected_item_id = item.id
        new_item = item
    }
    // 新規商品の追加
    func addItem() {
        items.append(Display_Item())
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
                                items.append(Display_Item(name: name, price: NumericalExtraction(price_line.text)))
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
            // LogoCheck()
            if LogoCheck() == "familymart" {
                printReceiptLineLanguageFM(lines_group: lines_group, lines: lines)
            }
            else {
                printReceiptLineLanguage(lines_group: lines_group, lines: lines)
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
            if false && Float(lines[i].frame.origin.x) >= Float(image!.size.width) / 2.0
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
        
        for (i,_) in lines_group.enumerated() {
            lines_group[i].sort {$0.frame.origin.x < $1.frame.origin.x}
        }
        
        return lines_group
    }
    
    func printReceiptLineLanguage(lines_group: [[VisionTextLine]], lines: [VisionTextLine]) {
        var line_width_text = ""
        var line_text = ""
        var double_angle_text = ""
        var min_height: CGFloat = 10000.0
        var char_count = -1
        var count = -1
        for line in lines {
            if min_height > line.frame.size.height {
                min_height = line.frame.size.height
            }
            count = characterCount(line: line)
            if count <= 60 {
                char_count = (char_count < count) ? count : char_count
            }
        }
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
    
    func printReceiptLineLanguageFM(lines_group: [[VisionTextLine]], lines: [VisionTextLine]) {
        var line_width_text = ""
        var line_text = ""
        var txt = "" //格納用
        var cnt = 0 //代入用
        var discount_flag = false, discount_total_flag = false, item_total_flag = false, internal_consumption_tex_flag = false, total_sum_8_flag = false, total_sum_10_flag = false, payment_flag = false, change_flag = false, deposit_flag = false //値引きか
        var element_count = -1 //何番目の商品か
        var new_item = Item(-1)
        var new_payment = PaymentMethod(-1)
        var double_angle_text = ""
        var min_height: CGFloat = 10000.0
        var char_count = -1
        var count = -1
        var receipt_line: ReceiptLine = ReceiptLine()
        var status: Int = FM_status.branch.rawValue
        var existsBranchStore = -1, existsPhone = -1, existsDateTime = -1, existsRegisterNumber = -1, existsResponsibilyNumber = -1, existsReceipt = -1
        for line in lines {
            if min_height > line.frame.size.height {
                min_height = line.frame.size.height
            }
            count = characterCount(line: line)
            if count <= 60 {
                char_count = (char_count < count) ? count : char_count
            }
        }
        var prev_x: CGFloat
        // 〇〇が判別できるのかチェック
        for_i: for (i, g_lines) in lines_group.enumerated() {
            for (line) in g_lines {
                if isBranchStore(text: line.text) {
                    existsBranchStore = i
                }
                if isPhone(text: line.text) {
                    existsPhone = i
                }
                if isDateTime(text: line.text) {
                    existsDateTime = i
                }
                if isRegisterNumber(text: line.text) {
                    existsRegisterNumber = i
                }
                if isResponsibilyNumber(text: line.text) {
                    existsResponsibilyNumber = i
                }
                if isReceipt(text: line.text) {
                    existsReceipt = i
                    break for_i
                }
            }
        }
        for (i, g_lines) in lines_group.enumerated() {
            // 座標決め用
            line_width_text = "{width:"
            // 本文
            line_text = "||"
            //文字の大きさ
            double_angle_text = ""
            //行数に複数のブロックがあり、ブロックが2番目以降の場合,
            prev_x = 0.0
            // 店情報、責任情報が取得できない場合
            if (existsBranchStore == -1 || existsPhone == -1 || existsDateTime == -1 || existsRegisterNumber == -1 || existsResponsibilyNumber == -1) && i <= existsReceipt {
                status = -1
            }
            // 領収証の後かどうか
            if existsReceipt + 1 == i {
                status = FM_status.item.rawValue
            }
            for (j, line) in g_lines.enumerated() {
                //文字の大きさを決定
                for _ in 1..<max(1, Int(floor(line.frame.size.height / min_height * 2 / 3))) {
                    double_angle_text += "^"
                }
                // 座標を指定(全体の文字数からどのくらいの幅を取るべきか)
                line_width_text += String(Int((line.frame.origin.x - prev_x) / image!.size.width * CGFloat(char_count))) + ","
                if i == 0 { // ロゴかどうか
                    // true: 右端のものであると判断 false: 通常の表示
                    if j > 0 && Float(line.frame.origin.x) + Float(line.frame.size.width) >= Float(image!.size.width) * 5 / 7 {
                        line_text += " " + double_angle_text + line.text + "|"
                    }
                    else {
                        line_text += double_angle_text + line.text + " |"
                    }
                }
                else {
                    
                    // 要素の抽出処理
                    switch status {
                    case FM_status.branch.rawValue:
                        if line.text.suffix(1)=="店" {
                            receipt_line.store_information.branch_name += line.text.prefix(line.text.count-1)
                            if cnt == 0{
                                txt = "#{store_information.branch_name}店"
                            }
                            else {
                                txt = "#{store_information.branch_name[\(cnt)-\(cnt+line.text.count-1)]}店"
                            }
                            cnt = 0;
                            status += 1
                            //print("branch="+receipt_line.store_information.branch_name)
                            
                        }
                        else {
                            receipt_line.store_information.branch_name += line.text
                            txt = "#{store_information.branch_name[\(cnt)-\(cnt+line.text.count-1)]}"
                            cnt += line.text.count
                        }
                        // true: 右端のものであると判断 false: 通常の表示
                        if j > 0 && Float(line.frame.origin.x) + Float(line.frame.size.width) >= Float(image!.size.width) * 5 / 7 {
                            line_text += " " + double_angle_text + txt + "|"
                        }
                        else {
                            line_text += double_angle_text + txt + " |"
                        }
                    case FM_status.address.rawValue:
                        if line.text.prefix(2) == "電話" {
                            cnt = 0
                            receipt_line.store_information.phone_number += line.text.suffix(line.text.count-3)
                            txt = "電話:#{store_information.phone_number}"
                            status += 1
                        }
                        else {
                            receipt_line.store_information.address += line.text
                            txt = "#{store_information.address[\(cnt)-\(cnt+line.text.count-1)]}"
                            cnt += line.text.count
                        }
                        // true: 右端のものであると判断 false: 通常の表示
                        if j > 0 && Float(line.frame.origin.x) + Float(line.frame.size.width) >= Float(image!.size.width) * 5 / 7 {
                            line_text += " " + double_angle_text + txt + "|"
                        }
                        else {
                            line_text += double_angle_text + txt + " |"
                        }
                    case FM_status.daytime.rawValue:
                        if line.text.prefix(2) == "20" {
                            txt = line.text
                            receipt_line.store_information.daytime = getDayTime(text: line.text)
                            txt = "#{store_information.daytime.year}年#{store_information.daytime.month}月#{store_information.daytime.date}日(#{store_information.daytime.week})#{store_information.daytime.time}:#{store_information.daytime.minite}"
                            //print(receipt_line.store_information.daytime)
                            status += 1
                            cnt = 0
                            if j > 0 && Float(line.frame.origin.x) + Float(line.frame.size.width) >= Float(image!.size.width) * 5 / 7 {
                                line_text += " " + double_angle_text + txt + "|"
                            }
                            else {
                                line_text += double_angle_text + txt + " |"
                            }
                        }
                        else {
                            if j > 0 && Float(line.frame.origin.x) + Float(line.frame.size.width) >= Float(image!.size.width) * 5 / 7 {
                                line_text += " " + double_angle_text + line.text + "|"
                            }
                            else {
                                line_text += double_angle_text + line.text + " |"
                            }
                        }
                    case FM_status.registration.rawValue:
                        if line.text.prefix(2) == "レジ" {
                            receipt_line.register_information.register_number = String(line.text.suffix(line.text.count - 2))
                            txt = "レジ #{receipt_line.register_information.register_number}"
                        }
                        else if line.text.prefix(1) == "責" {
                            receipt_line.register_information.responsibily_number =  String(NumericalExtraction(line.text))
                            txt = "責No.#{receipt_line.register_information.register_number}"
                            status = -1
                        }
                        else {
                            txt = line.text
                        }
                        cnt = 0
                        if j > 0 && Float(line.frame.origin.x) + Float(line.frame.size.width) >= Float(image!.size.width) * 5 / 7 {
                            line_text += " " + double_angle_text + txt + "|"
                        }
                        else {
                            line_text += double_angle_text + txt + " |"
                        }
                    case FM_status.item.rawValue:
                        if line.text.prefix(1) == "合" && j == 0 {
                            new_item.unit_price = new_item.quantity == 1 ? new_item.subtotal : new_item.unit_price
                            receipt_line.item_information.items.append(new_item)
                            receipt_line.item_information.count = element_count + 1
                            new_item = Item(-1)
                            element_count = -1
                            status += 1
                            txt = line.text
                        }
                        else if line.text.contains("商品合計") && j == 0 {
                            item_total_flag = true
                            txt = line.text
                        }
                        else if line.text.contains("値引合計") && j == 0 {
                            discount_total_flag = true
                            txt = line.text
                        }
                        else if line.text.prefix(3) == "値引き" && j == 0 {
                            discount_flag = true
                            txt = line.text
                        }
                        else if isMultiple(text: line.text) && j == 0 {
                            getMultiple(text: line.text, item: &new_item)
                            txt = "@#{receipt_line.item_infotmation.items[\(element_count)].unit_price}× #{receipt_line.item_infotmation.items[\(element_count)].quantity}点"
                        }
                        else if j == 0 {
                            if(new_item.id != -1){
                                new_item.unit_price = new_item.quantity == 1 ? new_item.subtotal : new_item.unit_price
                                receipt_line.item_information.items.append(new_item)
                                receipt_line.item_information.count = element_count + 1
                            }
                            element_count += 1
                            new_item = Item(element_count)
                            new_item.name = line.text
                            txt = "#{receipt_line.item_infotmation.items[\(element_count)].name}"
                        }
                        else if(discount_flag){
                            discount_flag = false
                            new_item.discount = NumericalExtraction(line.text)
                            txt = "-#{receipt_line.item_infotmation.items[\(element_count)].discount}"
                        }
                        else if(discount_total_flag){
                            discount_total_flag = false
                            receipt_line.accounting_information.discount_total = NumericalExtraction(line.text)
                            txt = "-#{receipt_line.accounting_information.discount_total}"
                        }
                        else if(item_total_flag){
                            item_total_flag = false
                            receipt_line.accounting_information.item_total = NumericalExtraction(line.text)
                            txt = "-#{receipt_line.accounting_information.item_total}"
                        }
                        else {
                            new_item.subtotal = NumericalExtraction(line.text)
                            new_item.is_reduced_tax_rate =  line.text.suffix(1) == "軽"
                            txt = "¥#{receipt_line.item_infotmation.items[\(element_count)].subtotal}#{receipt_line.item_infotmation.items[\(element_count)].is_reduced_tax_rate?`軽`:``}"
                        }

                        if j > 0 && Float(line.frame.origin.x) + Float(line.frame.size.width) >= Float(image!.size.width) * 5 / 7 {
                            line_text += " " + double_angle_text + txt + "|"
                        }
                        else {
                            line_text += double_angle_text + txt + " |"
                        }
                    case FM_status.total_price.rawValue:
                        if line.text.prefix(1) == "計" {
                            txt = line.text
                        }
                        else {
                            receipt_line.accounting_information.total_sum = NumericalExtraction(line.text)
                            txt = "¥#{receipt_line.accounting_information.total_sum}"
                            status += 1
                        }
                        if j > 0 && Float(line.frame.origin.x) + Float(line.frame.size.width) >= Float(image!.size.width) * 5 / 7 {
                            line_text += " " + double_angle_text + txt + "|"
                        }
                        else {
                            line_text += double_angle_text + txt + " |"
                        }
                    case FM_status.accounting.rawValue:
                        if line.text.contains("10%対象") && j == 0 {
                            total_sum_10_flag = true
                            txt = line.text
                        }
                        else if line.text.contains("8%対象") && j == 0 {
                            total_sum_8_flag = true
                            txt = line.text
                        }
                        else if line.text.contains("消費税") && j == 0 {
                            internal_consumption_tex_flag = true
                            txt = line.text
                        }
                        else if line.text.contains("支払") && j == 0 {
                            payment_flag = true
                            element_count += 1
                            new_payment = PaymentMethod(element_count)
                            getPatmentName(text: line.text, payment: &new_payment)
                            txt = "#{receipt_line.payment_information.payment_methods[\(element_count)].name}支払"
                        }
                        else if line.text.contains("釣") {
                            change_flag = true
                            txt = line.text
                        }
                        else if line.text.contains("預") {
                            deposit_flag = true
                            txt = line.text
                        }
                        else if internal_consumption_tex_flag && j == 1 {
                            internal_consumption_tex_flag = false
                            receipt_line.accounting_information.internal_consumption_tex = NumericalExtraction(line.text)
                            txt = "¥#{receipt_line.accounting_information.internal_consumption_tex}"
                        }
                        else if total_sum_8_flag && j == 1 {
                            total_sum_8_flag = false
                            receipt_line.accounting_information.total_sum_8 = NumericalExtraction(line.text)
                            txt = "¥#{receipt_line.accounting_information.total_sum_8}"
                        }
                        else if total_sum_10_flag && j == 1 {
                            total_sum_10_flag = false
                            receipt_line.accounting_information.total_sum_10 = NumericalExtraction(line.text)
                            txt = "¥#{receipt_line.accounting_information.total_sum_10}"
                        }
                        else if payment_flag && j == 1 {
                            payment_flag = false
                            new_payment.paid = NumericalExtraction(line.text)
                            txt = "¥#{receipt_line.payment_information.payment_methods[\(element_count)].paid}"
                            if(new_payment.id != -1){
                                receipt_line.payment_information.payment_methods.append(new_payment)
                                receipt_line.payment_information.count = element_count + 1
                            }
//                            receipt_line.accounting_information.payment = NumericalExtraction(line.text)
//                            txt = "-#{receipt_line.accounting_information.payment}"
                        }
                        else if change_flag && j == g_lines.count - 1 {
                            change_flag = false
                            receipt_line.payment_information.change = NumericalExtraction(line.text)
                            txt = "¥#{receipt_line.payment_information.change}"
                        }
                        else if deposit_flag && j == g_lines.count - 1 {
                            deposit_flag = false
                            receipt_line.payment_information.deposit = NumericalExtraction(line.text)
                            txt = "¥#{receipt_line.payment_information.deposit}"
                        }
                        else {
                            txt = line.text
                        }
                        
                        if j > 0 && Float(line.frame.origin.x) + Float(line.frame.size.width) >= Float(image!.size.width) * 5 / 7 {
                            line_text += " " + double_angle_text + txt + "|"
                        }
                        else {
                            line_text += double_angle_text + txt + " |"
                        }
//                    case FM_status.payment.rawValue:
                    default:
                        // true: 右端のものであると判断 false: 通常の表示
                        if j > 0 && Float(line.frame.origin.x) + Float(line.frame.size.width) >= Float(image!.size.width) * 5 / 7 {
                            line_text += " " + double_angle_text + line.text + "|"
                        }
                        else {
                            line_text += double_angle_text + line.text + " |"
                        }
                    }
                }
                //座標比較用
                prev_x = line.frame.origin.x
            }
            line_width_text += String(Int((image!.size.width - prev_x) / image!.size.width * CGFloat(char_count))) + "}"
            receipt_line.receipt_line_information.lines.append(Line(line_width_text))
            receipt_line.receipt_line_information.lines.append(Line(line_text))
            receipt_line.receipt_line_information.count += 2
            print(line_width_text)
            print(line_text)
            
        }
        print(receipt_line)
    }
    
    func isBranchStore(text: String) -> Bool {
        let pattern = "店$"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return false }
        let checkingResults = regex.matches(in: text, range: NSRange(location: 0, length: text.count))
        return checkingResults.count > 0
    }
    
    func isPhone(text: String) -> Bool {
        let pattern = "^電話"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return false }
        let checkingResults = regex.matches(in: text, range: NSRange(location: 0, length: text.count))
        return checkingResults.count > 0
    }
    
    func isDateTime(text: String) -> Bool {
        let pattern = #"[0-9]{4}年\s*\d{1,2}月\s*\d{1,2}日\(.\)\s*\d{1,2}:\s*\d{1,2}"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return false }
        let checkingResults = regex.matches(in: text, range: NSRange(location: 0, length: text.count))
        return checkingResults.count > 0
    }
    
    func isReceipt(text: String) -> Bool {
        let pattern = #"^(領|収|書)"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return false }
        let checkingResults = regex.matches(in: text, range: NSRange(location: 0, length: text.count))
        return checkingResults.count > 0
    }
    
    func isRegisterNumber(text: String) -> Bool {
        let pattern = "^レジ"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return false }
        let checkingResults = regex.matches(in: text, range: NSRange(location: 0, length: text.count))
        return checkingResults.count > 0
    }
    
    func isResponsibilyNumber(text: String) -> Bool {
        let pattern = "^責"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return false }
        let checkingResults = regex.matches(in: text, range: NSRange(location: 0, length: text.count))
        return checkingResults.count > 0
    }
    
    func isMultiple(text: String) -> Bool {
        let pattern = #"^@(\d*)(×|x)\s*(\d*)点"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return false }
        let checkingResults = regex.matches(in: text, range: NSRange(location: 0, length: text.count))
        return checkingResults.count > 0
    }
    
    func getMultiple(text: String, item: inout Item) {
        let pattern = #"^@(\d*)(×|x)\s*(\d*)点"#
        if let regex = try? NSRegularExpression(pattern: pattern) {
            let r = regex.firstMatch(in: text, range: NSRange(location: 0, length: text.count))
            item.quantity = Int(NSString(string: text).substring(with: r!.range(at: 3)))!
            item.unit_price = Int(NSString(string: text).substring(with: r!.range(at: 1)))!
        }
    }
    
    func getPatmentName(text: String, payment: inout PaymentMethod) {
        let pattern = #"(.*)(支払)$"#
        if let regex = try? NSRegularExpression(pattern: pattern) {
            let r = regex.firstMatch(in: text, range: NSRange(location: 0, length: text.count))
            payment.name = NSString(string: text).substring(with: r!.range(at: 1))
        }
    }
    
    func getDayTime(text: String) -> DayTime {
        let pattern = #"(\d{4})年\s*(\d{1,2})月\s*(\d{1,2})日\((.)\)\s*(\d{1,2}):\s*(\d{1,2})"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return DayTime() }
        let r = regex.firstMatch(in: text, range: NSRange(location: 0, length: text.count))
        var daytime = DayTime()
        daytime.year = NSString(string: text).substring(with: r!.range(at: 1))
        daytime.month = NSString(string: text).substring(with: r!.range(at: 2))
        daytime.date = NSString(string: text).substring(with: r!.range(at: 3))
        daytime.week = NSString(string: text).substring(with: r!.range(at: 4))
        daytime.time = NSString(string: text).substring(with: r!.range(at: 5))
        daytime.minute = NSString(string: text).substring(with: r!.range(at: 6))
        return daytime
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
//        print(line.text)
//        print(count)
//        print(line.frame.size.width)
//        print(image!.size.width)
//        print(Int(Float(count) * Float(image!.size.width / line.frame.size.width)))
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


