//
//  CameraView.swift
//  receipt_manage (iOS)
//
//  Created by 多根直輝 on 2021/06/26.
//

import SwiftUI
import UIKit
import SwiftyTesseract
import Firebase
import XMLMapper


struct CameraView: View {
    
    @State var status: Status = .home
    @State var scanned_images: [UIImage]?
    @State private var selected_image: UIImage?
    @State var receipt_line: ReceiptLine = ReceiptLine()
    @State var processing: Bool = false
    
    
    var body: some View {
        ZStack {
            switch status {
            case Status.home:
                CameraSelectView(status: $status, receipt_line: $receipt_line)
            case Status.scan:
                CameraScanView(status: $status, scanned_images: $scanned_images)
            case Status.selectImages:
                SelectImageView(scanned_images: $scanned_images, selected_image: $selected_image, status: $status)
            case Status.photoLibrary:
                ImagePicker(sourceType: .photoLibrary, selectedImage: $selected_image, status: $status)
            case Status.createReceiptLine:
                CreateReceiptView(receipt_line: $receipt_line, status: $status)
            default:
                CameraSelectView(status: $status, receipt_line: $receipt_line)
            }
            if selected_image != nil {
                Color.black
                    .opacity(0.6)
                    .edgesIgnoringSafeArea(.all)
                    .onAppear{getReceiptInformation()}
            }
            ActivityIndicator(isAnimating: $processing, style: .large)
        }
    }
    
    func getReceiptInformation() {
        self.processing = true
        let vision = Vision.vision()
        let options = VisionCloudTextRecognizerOptions()
        options.languageHints = ["en", "ja"]
        let textRecognizer = vision.cloudTextRecognizer(options: options)
        let visionimage = VisionImage(image: selected_image!)
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
            if false && Float(lines[i].frame.origin.x) >= Float(selected_image!.size.width) / 2.0
                && Float(lines[i].frame.origin.x) + Float(lines[i].frame.size.width) >= Float(selected_image!.size.width) * 5 / 7 {
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
                line_width_text += String(Int((line.frame.origin.x - prev_x) / selected_image!.size.width * CGFloat(char_count))) + ","
                if i > 0 && Float(line.frame.origin.x) + Float(line.frame.size.width) >= Float(selected_image!.size.width) * 5 / 7 {
                    line_text += " " + double_angle_text + line.text + "|"
                }
                else {
                    line_text += double_angle_text + line.text + " |"
                }
                prev_x = line.frame.origin.x
            }
            line_width_text += String(Int((selected_image!.size.width - prev_x) / selected_image!.size.width * CGFloat(char_count))) + "}"
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
        receipt_line.store_information.store_name = "familymart"
        var processing_status: Int = FM_status.branch.rawValue
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
                processing_status = -1
            }
            // 領収証の後かどうか
            if existsReceipt + 1 == i {
                processing_status = FM_status.item.rawValue
            }
            for (j, line) in g_lines.enumerated() {
                //文字の大きさを決定
                for _ in 1..<max(1, Int(floor(line.frame.size.height / min_height * 2 / 3))) {
                    double_angle_text += "^"
                }
                // 座標を指定(全体の文字数からどのくらいの幅を取るべきか)
                line_width_text += String(Int((line.frame.origin.x - prev_x) / selected_image!.size.width * CGFloat(char_count))) + ","
                if i == 0 { // ロゴかどうか
                    // true: 右端のものであると判断 false: 通常の表示
                    if j > 0 && Float(line.frame.origin.x) + Float(line.frame.size.width) >= Float(selected_image!.size.width) * 5 / 7 {
                        line_text += " " + double_angle_text + line.text + "|"
                    }
                    else {
                        line_text += double_angle_text + line.text + " |"
                    }
                }
                else {
                    
                    // 要素の抽出処理
                    switch processing_status {
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
                            processing_status += 1
                            //print("branch="+receipt_line.store_information.branch_name)
                            
                        }
                        else {
                            receipt_line.store_information.branch_name += line.text
                            txt = "#{store_information.branch_name[\(cnt)-\(cnt+line.text.count-1)]}"
                            cnt += line.text.count
                        }
                        // true: 右端のものであると判断 false: 通常の表示
                        if j > 0 && Float(line.frame.origin.x) + Float(line.frame.size.width) >= Float(selected_image!.size.width) * 5 / 7 {
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
                            processing_status += 1
                        }
                        else {
                            receipt_line.store_information.address += line.text
                            txt = "#{store_information.address[\(cnt)-\(cnt+line.text.count-1)]}"
                            cnt += line.text.count
                        }
                        // true: 右端のものであると判断 false: 通常の表示
                        if j > 0 && Float(line.frame.origin.x) + Float(line.frame.size.width) >= Float(selected_image!.size.width) * 5 / 7 {
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
                            processing_status += 1
                            cnt = 0
                            if j > 0 && Float(line.frame.origin.x) + Float(line.frame.size.width) >= Float(selected_image!.size.width) * 5 / 7 {
                                line_text += " " + double_angle_text + txt + "|"
                            }
                            else {
                                line_text += double_angle_text + txt + " |"
                            }
                        }
                        else {
                            if j > 0 && Float(line.frame.origin.x) + Float(line.frame.size.width) >= Float(selected_image!.size.width) * 5 / 7 {
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
                            processing_status = -1
                        }
                        else {
                            txt = line.text
                        }
                        cnt = 0
                        if j > 0 && Float(line.frame.origin.x) + Float(line.frame.size.width) >= Float(selected_image!.size.width) * 5 / 7 {
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
                            processing_status += 1
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

                        if j > 0 && Float(line.frame.origin.x) + Float(line.frame.size.width) >= Float(selected_image!.size.width) * 5 / 7 {
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
                            processing_status += 1
                        }
                        if j > 0 && Float(line.frame.origin.x) + Float(line.frame.size.width) >= Float(selected_image!.size.width) * 5 / 7 {
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
                        
                        if j > 0 && Float(line.frame.origin.x) + Float(line.frame.size.width) >= Float(selected_image!.size.width) * 5 / 7 {
                            line_text += " " + double_angle_text + txt + "|"
                        }
                        else {
                            line_text += double_angle_text + txt + " |"
                        }
//                    case FM_status.payment.rawValue:
                    default:
                        // true: 右端のものであると判断 false: 通常の表示
                        if j > 0 && Float(line.frame.origin.x) + Float(line.frame.size.width) >= Float(selected_image!.size.width) * 5 / 7 {
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
            line_width_text += String(Int((selected_image!.size.width - prev_x) / selected_image!.size.width * CGFloat(char_count))) + "}"
            receipt_line.receipt_line_information.lines.append(Line(receipt_line.receipt_line_information.count,line_width_text))
            receipt_line.receipt_line_information.count += 1
            receipt_line.receipt_line_information.lines.append(Line(receipt_line.receipt_line_information.count,line_text))
            receipt_line.receipt_line_information.count += 1
            print(line_width_text)
            print(line_text)
        }
        
        self.processing = false
        status = Status.createReceiptLine
        self.selected_image = nil
        
        //print(receipt_line.toXMLString() ?? "nil")
//        let xmlString = receipt_line.toXMLString() ?? "nil"
//        let data = Data(xmlString.utf8) // Data for deserialization (from XML to object)
//        do {
//            let xml = try XMLSerialization.xmlObject(with: data, options: [.default, .cdataAsString])
//            let rl = XMLMapper<ReceiptLine>().map(XMLObject: xml)
//            print(rl!)
//            //print("test")
//        } catch {
//            print(error)
//        }
        //print(receipt_line)
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
        let daytime = DayTime()
        daytime.year = Int(NSString(string: text).substring(with: r!.range(at: 1)))!
        daytime.month = Int(NSString(string: text).substring(with: r!.range(at: 2)))!
        daytime.date = Int(NSString(string: text).substring(with: r!.range(at: 3)))!
        daytime.week = NSString(string: text).substring(with: r!.range(at: 4))
        daytime.time = Int(NSString(string: text).substring(with: r!.range(at: 5)))!
        daytime.minute = Int(NSString(string: text).substring(with: r!.range(at: 6)))!
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
//        print(selected_image!.size.width)
//        print(Int(Float(count) * Float(selected_image!.size.width / line.frame.size.width)))
        return Int(Float(count) * Float(selected_image!.size.width / line.frame.size.width) )
    }
    
    

    //パターン認識でロゴをチェック（予定）
    func LogoCheck() -> String {
        return "familymart"
    }
}

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
    }
}

struct ActivityIndicator: UIViewRepresentable {
    @Binding var isAnimating: Bool

    let style: UIActivityIndicatorView.Style

    func makeUIView(context: Context) -> UIActivityIndicatorView {
        UIActivityIndicatorView(style: style)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}
