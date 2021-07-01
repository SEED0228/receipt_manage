//
//  CreateReceiptView.swift
//  receipt_manage (iOS)
//
//  Created by 多根直輝 on 2021/06/26.
//

import SwiftUI
import PartialSheet

struct CreateReceiptView: View {
    @Binding var receipt_line: ReceiptLine
    @Binding var status: Status
    @EnvironmentObject var partialSheetManager: PartialSheetManager
    
    // 表示設定
    @State var showAllStoreInformation = false
    @State var showAllRegisterInformation = false
    @State var showAllAccountingInformation = false
    @State var showAllPaymentInformation = false
    @State var showAllReceiptLineInformation = false
    
    // 商品関係
    @State var edittingItemId = -1
    @State var isEdittingItem = false
    
    // 購入日
    @State var isEdittingDayTime = false
    
    var body: some View {
        ZStack {
            CreateReceiptHeaderView(status: $status)
            Form {
                Section(header: Text("店舗情報")){
                    FormElement(variable: $receipt_line.store_information.store_name, placeholder: "〇〇マート", labelText: "店名")
                    Button(action:{
                        isEdittingDayTime = true
                    }){
                        ElementRow(title: "購入日", text: receipt_line.store_information.daytime.toString()+"(\(receipt_line.store_information.daytime.week))")
                    }
                    
                    if showAllStoreInformation {
                        FormElement(variable: $receipt_line.store_information.branch_name, placeholder: "〇〇店", labelText: "支店名")
                        FormElement(variable: $receipt_line.store_information.address, placeholder: "〇〇県△△市", labelText: "住所")
                        FormElement(variable: $receipt_line.store_information.phone_number, placeholder: "000-0000-0000", labelText: "電話番号")
                    }
                    ShowingButton(flag: $showAllStoreInformation)
                }
                
                Section(header: Text("支払い情報")){
                    NumberFormElement(variable: $receipt_line.accounting_information.total_sum, labelText: "合計")
                    if showAllAccountingInformation {
                        NumberFormElement(variable: $receipt_line.accounting_information.item_total, labelText: "商品合計")
                        NumberFormElement(variable: $receipt_line.accounting_information.discount_total, labelText: "値引き合計")
                        NumberFormElement(variable: $receipt_line.accounting_information.total_sum_8, labelText: "8%合計")
                        NumberFormElement(variable: $receipt_line.accounting_information.total_sum_10, labelText: "10%合計")
                        NumberFormElement(variable: $receipt_line.accounting_information.internal_consumption_tex, labelText: "内消費税")
                        
                    }
                    ShowingButton(flag: $showAllAccountingInformation)
                }
                
                
                
                Section(header: Text("商品情報(計\(receipt_line.item_information.count)個)")){
                    ForEach(0..<receipt_line.item_information.count) { i in
                        Button(action:{
                            edittingItemId = i
                            isEdittingItem = true
                        }){
                            ElementRow(title: receipt_line.item_information.items[i].name, text: "¥\(receipt_line.item_information.items[i].subtotal)")
                        }
                    }
                }
                
                Section(header: Text("レジ情報")){

                    if showAllRegisterInformation {
                        FormElement(variable: $receipt_line.register_information.register_number, placeholder: "0-0000", labelText: "レジ番号")
                        FormElement(variable: $receipt_line.register_information.responsibily_number, placeholder: "000", labelText: "責任番号")
                    }
                    ShowingButton(flag: $showAllRegisterInformation)
                }
                
                Section(header: Text("決済情報(計\(receipt_line.payment_information.count)個)")){
                    
                    if showAllPaymentInformation {
                        NumberFormElement(variable: $receipt_line.payment_information.deposit, labelText: "お預かり")
                        NumberFormElement(variable: $receipt_line.payment_information.change, labelText: "お釣り")
                        ForEach(0..<receipt_line.payment_information.count) { i in
                            ElementRow(title: receipt_line.payment_information.payment_methods[i].name, text: "¥\(receipt_line.payment_information.payment_methods[i].paid)")
                        }
                    }
                    ShowingButton(flag: $showAllPaymentInformation)
                }
                
                Section(header: Text("レシート描画情報(計\(receipt_line.receipt_line_information.count)個)")){
                    
                    if showAllReceiptLineInformation {
                        ForEach(0..<receipt_line.receipt_line_information.count) { i in
                            ElementRow(title: "\(i)", text: receipt_line.receipt_line_information.lines[i].line)
                        }
                    }
                    ShowingButton(flag: $showAllReceiptLineInformation)
                }
            }
            .padding(.top, 50)
            .padding(.bottom, 100)
            VStack(alignment: .center){
                Spacer()
                ZStack {
                    Color("blackwhite")
                        .opacity(0.8)
                        .frame(width: .infinity, height: 100)
                    Button(action: {
                        saveReceiptLineToDevise()
                        status = Status.home
                    } ) {
                        Text("保存")
                            .foregroundColor(Color.white)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(30)
                    }.frame(width: 100, height: 100, alignment: .center)
                }
            }
            
            if isEdittingDayTime {
                VStack {
                    Spacer()
                    DayTimeForm(daytime: $receipt_line.store_information.daytime, isShown: $isEdittingDayTime)
                }
            }
        }
        .partialSheet(isPresented: $isEdittingItem) {
            ItemForm(item: $receipt_line.item_information.items[edittingItemId])
        }
        
    }
    func saveReceiptLineToDevise() {
        do {
            let fileManager = FileManager.default
            let docs = fileManager.urls(for: .documentDirectory,
                                           in: .userDomainMask)[0]
            let path = docs.appendingPathComponent(receipt_line.uuid.uuidString + ".xml")
            let data = (receipt_line.toXMLString() ?? "nil").data(using: .utf8)!
            fileManager.createFile(atPath: path.path,
                                   contents: data, attributes: nil)
//            try data.write(to: path)
//            print("success")
//            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//            let contentURLs = try FileManager.default.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
//            print(contentURLs)
        } catch {
            print(error)
        }
    }
    
    func addItem() {
        receipt_line.item_information.items.append(Item(receipt_line.item_information.count))
        receipt_line.item_information.count += 1
    }
}

struct ItemForm: View {
    
    @Binding var item: Item
    @State var isShown: Bool = false
    @State var height: CGFloat = 300
    
    var body: some View {
        Form {
            FormElement(variable: $item.name, placeholder: "スナック", labelText: "商品名")
            NumberFormElement(variable: $item.subtotal, labelText: "値段")
            if isShown {
                NumberFormElement(variable: $item.discount, labelText: "値引き額")
                NumberFormElement(variable: $item.unit_price, labelText: "単価")
                NumberFormElement(variable: $item.quantity, labelText: "個数")
                Toggle(isOn: $item.is_reduced_tax_rate) {
                    Text("軽減税率対象")
                }
            }
            ShowingButton(flag: $isShown)
        }
        .onChange(of: isShown, perform: { value in
            height = isShown ? 500 : 300
        })
        .frame(height: height)
    }
}

struct DayTimeForm: View {
    
    @Binding var daytime: DayTime
    @State var date: Date = Date()
    @Binding var isShown: Bool
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                Form {
                    DatePicker("購入日　:", selection: $date, in: ...Date())
                        .datePickerStyle(WheelDatePickerStyle())
                        
                }
                .onChange(of: date, perform: { value in
                    convertFromDateToDayTime()
                })
                .onAppear{
                    convertFromDayTimeToDate()
                }
                .frame(height: 400)
            }
            VStack {
                Spacer()
                Button(action: {isShown.toggle()} ) {
                    Text("閉じる")
                        .foregroundColor(Color.white)
                        .padding()
                        .background(Color.gray)
                        .cornerRadius(100)
                }.frame(width: 100, height: 100, alignment: .center)
            }
            
        }
        
        
    }
    
    func convertFromDayTimeToDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        date = dateFormatter.date(from: daytime.toString())!
        
    }
    
    func convertFromDateToDayTime() {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ja_JP")
        f.timeZone = TimeZone(identifier: "Asia/Tokyo")
        f.dateFormat = "yyyy"
        daytime.year = Int(f.string(from: date))!
        f.dateFormat = "MM"
        daytime.month = Int(f.string(from: date))!
        f.dateFormat = "dd"
        daytime.date = Int(f.string(from: date))!
        f.dateFormat = "EEE"
        daytime.week = f.string(from: date)
        f.dateFormat = "HH"
        daytime.time = Int(f.string(from: date))!
        f.dateFormat = "mm"
        daytime.minute = Int(f.string(from: date))!
    }
}

struct FormElement: View {
    
    @Binding var variable: String
    var placeholder: String
    var labelText: String
    @State var cnt: Int = 0
    
    var body: some View  {
        HStack {
            Text(labelText)
            Divider()
                .padding(.leading, 18 * CGFloat(cnt))
            TextField("\(placeholder)", text: $variable)
            Spacer()
        }
        .onAppear{
            if labelText.count < 4 {
                cnt = 4-labelText.count
            }
        }
    }
}

struct NumberFormElement: View {
    
    @Binding var variable: Int
    @State var cnt = 0
    @State var labelText: String

    var body: some View  {
        HStack {
            Text(labelText)
            Divider()
                .padding(.leading, 18 * CGFloat(cnt))
            TextField("0", value: $variable, formatter: NumberFormatter())
            Spacer()
        }
        .onAppear{
            if labelText.count < 12 {
                cnt = 12-labelText.count
            }
        }
    }
}

struct ElementRow: View {
    
    var title: String
    var text: String
    
    
    var body: some View  {
        HStack {
            Text(title)
            Spacer()
            Text(text)
        }
    }
}

struct ShowingButton: View {
    
    @Binding var flag: Bool
    
    var body: some View  {
        Button(action: {flag.toggle()}){
            HStack {
                Spacer()
                Text(flag ? "-" : "+")
                    .foregroundColor(Color("labelText"))
                    .bold()
                Spacer()
            }
        }
    }
    
}

struct CreateReceiptView_Previews: PreviewProvider {
    @State static var receipt_line: ReceiptLine = ReceiptLine()
    @State static var status: Status = Status.home
    static var previews: some View {
        CreateReceiptView(receipt_line: $receipt_line, status: $status)
    }
}
