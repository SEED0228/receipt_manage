//
//  ListView.swift
//  receipt_manage (iOS)
//
//  Created by 多根直輝 on 2021/06/28.
//

import SwiftUI

struct ListView: View {
    @Binding var status: Status
    @Binding var receipt_line: ReceiptLine
    @EnvironmentObject var userData: UserData
    @State var receipt_lines: [String: [ReceiptLine]] = [:]
    @State var keys: [String] = []
    @State var values: [[ReceiptLine]] = []
    var body: some View {
            List {
                ForEach(keys, id: \.self) { key in
                    Section(header: SectionHeaderView(key: key, receipt_lines: $receipt_lines)) {
                        ForEach(0..<(receipt_lines[key] == nil ? 0 : receipt_lines[key]!.count), id: \.self) { j in
//                            Text(getStringDate(receipt_line: (receipt_lines[keys[i]]?[j])!))
                            ListRaw(receipt_line: receipt_lines[key]?[j] ?? ReceiptLine(), status: $status, edit_receipt_line: $receipt_line)
                        }
                        .onDelete(perform: { indexSet in
                            let uuid = receipt_lines[key]?[indexSet.first!].uuid.uuidString
                            let fileManager = FileManager.default
                            let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
                            let path = docs.appendingPathComponent(uuid! + ".xml")
                            do {
                                try FileManager.default.removeItem(at: path)
                                userData.load_receipt_lines()
                                setReceiptLineDictionary()
                            } catch {
                                print(error)
                            }
                        })
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .onAppear{
                userData.load_receipt_lines()
                setReceiptLineDictionary()
            }
            .onChange(of: userData.receipt_lines.count, perform: { value in
                setReceiptLineDictionary()
            })
    }
    
    func getStringDate(receipt_line: ReceiptLine) -> String {
        print(receipt_line.store_information.store_name)
        return receipt_line.store_information.daytime.toString()
    }
    
    
    func setReceiptLineDictionary() {
        receipt_lines = [:]
        for receipt_line in userData.receipt_lines {
            let string_date = receipt_line.store_information.daytime.toStringDate()
            if receipt_lines[string_date] == nil {
                receipt_lines[string_date] = [receipt_line]
            }
            else {
                receipt_lines[string_date]!.append(receipt_line)
            }
        }
        for receipt_line in receipt_lines {
            let rls = receipt_line.value.sorted(by:{(($0.store_information.daytime.year * 365 + $0.store_information.daytime.month * 31 + $0.store_information.daytime.date) * 24 + $0.store_information.daytime.time) * 60 + $0.store_information.daytime.minute > (($1.store_information.daytime.year * 365 + $1.store_information.daytime.month * 31 + $1.store_information.daytime.date) * 24 + $1.store_information.daytime.time) * 60 + $1.store_information.daytime.minute})
            receipt_lines[receipt_line.key] = rls
        }
        keys = receipt_lines.map { $0.key }
        keys.sort(by: {$0 > $1})
        values = keys.compactMap { receipt_lines[$0] }
        for i in values {
            for j in i {
                print(j.store_information.daytime.toStringDate())
            }
        }
    }
}

struct SectionHeaderView: View {
    var key: String
    @State var dateString: String = ""
    @EnvironmentObject var userData: UserData
    @Binding var receipt_lines: [String: [ReceiptLine]]
    @State var cnt = 0
    var body: some View {
        HStack {
            Text("\(dateString)")
            Spacer()
            Text("(計: ¥\(cnt))")
                .padding(.trailing, 25)
        }
        .onChange(of: userData.receipt_lines.count, perform: { value in
            updateHeader()
        })
        .onAppear{
            updateHeader()
        }
        
    }
    
    func updateHeader() {
        cnt = 0
        if receipt_lines[key] != nil {
            for receipt_line in receipt_lines[key]! {
                cnt += receipt_line.accounting_information.total_sum
            }
        }
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateFormat = "yyyy"
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        if key.prefix(4) ==  dateFormatter.string(from: Date()) {
            dateString = String(key.suffix(5))
            dateFormatter.dateFormat = "yyyy/MM/dd"
            if dateFormatter.string(from: Date()) == key {
                dateString = "今日"
            }
            else if dateFormatter.string(from: Calendar.current.date(byAdding: .day, value: -1, to: Date())!) == key {
                dateString = "昨日"
            }
        }
        else {
            dateString = key
        }
    }
}

struct ListView_Previews: PreviewProvider {
    @State static var status: Status = .home
    @State static var receipt_line: ReceiptLine = ReceiptLine()
    static var previews: some View {
        ListView(status: $status, receipt_line: $receipt_line)
            .environmentObject(UserData())
    }
}
