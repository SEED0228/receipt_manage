//
//  ReceiptLineStruct.swift
//  receipt_manage (iOS)
//
//  Created by 多根直輝 on 2021/06/10.
//

import Foundation
import SwiftUI
import XMLMapper

class ReceiptLine: XMLMappable {
    
    var nodeName: String! = "receipt"
    var nodesOrder: [String]? = ["store_information", "register_information", "item_information", "accounting_information", "payment_information", "receipt_line_information"]
    
    var uuid = UUID()
    
    var store_information: StoreInformation = StoreInformation()
    var register_information: RegisterInformation = RegisterInformation()
    var item_information: ItemInformation = ItemInformation()
    var accounting_information: AccountingInformation = AccountingInformation()
    var payment_information: PaymentInformation = PaymentInformation()
    var receipt_line_information: ReceiptLineInformation = ReceiptLineInformation()
    
    init(){
    }
    
    func createReceiptLineLangage() {
        
    }
    
    required init?(map: XMLMap) {}

    func mapping(map: XMLMap) {
        store_information <- map["store_information"]
        register_information <- map["register_information"]
        item_information <- map["item_information"]
        accounting_information <- map["accounting_information"]
        payment_information <- map["payment_information"]
        receipt_line_information <- map["receipt_line_information"]
        nodesOrder <- map.nodesOrder
    }
    
    func convertToOSS() -> String {
        var converted_text = ""
        for line in self.receipt_line_information.lines {
            let pattern = #"#\{.*?\}"#
            guard let regex = try? NSRegularExpression(pattern: pattern) else {
                print("error")
                return "error"
            }
            let results = regex.matches(in: line.line, range: NSRange(location: 0, length: line.line.count))
//            print(results.count)
            var elements: [String] = []
            for result in results {
                for i in 0..<result.numberOfRanges {
                    let start = line.line.index(line.line.startIndex, offsetBy: result.range(at: i).location)
                    let end = line.line.index(start, offsetBy: result.range(at: i).length)
                    let text = String(line.line[start..<end])
                    var fixed_text = String(text.prefix(text.count - 1).suffix(text.count-3))
                    fixed_text = fixed_text.replacingOccurrences(of: "`", with: "\"")
//                    print(fixed_text)
//                    print(getReceiptLineElement(receipt_line: receipt_line, text: fixed_text))
                    elements.append(getReceiptLineElement(text: fixed_text))
                }
            }
            let mstring = NSMutableString(string: line.line)
            regex.replaceMatches(in: mstring, options: [], range: NSRange(0..<line.line.count), withTemplate: "#")
//            print(mstring)
            let array = String(mstring).replacingOccurrences(of: "##", with: "# #").split(separator: "#")
//            print(array)
            converted_text += array[0]
//            print(array[0], terminator: "")
            for i in 0..<elements.count {
                converted_text += elements[i] + array[i+1]
//                print(elements[i], terminator: "")
//                print(array[i+1], terminator: "")
            }
            converted_text += "\n"
//            print("")
        }
//        print(converted_text)
        return converted_text
    }
    
    func getReceiptLineElement(text: String) -> String {
        let array = text.split(separator: ".")
        var index: Int = -1
//        print(array)
        switch array[0] {
        case "store_information":
            switch array[1] {
            case "store_name":
                return self.store_information.store_name
            case "branch_name":
                return self.store_information.branch_name
            case "phone_number":
                return self.store_information.phone_number
            case "daytime":
                switch array[2] {
                case "year":
                    return String(self.store_information.daytime.year)
                case "month":
                    return String(format: "%02d", self.store_information.daytime.month)
                case "date":
                    return String(format: "%02d", self.store_information.daytime.date)
                case "week":
                    return self.store_information.daytime.week
                case "time":
                    return String(format: "%02d", self.store_information.daytime.time)
                case "minute":
                    return String(format: "%02d", self.store_information.daytime.minute)
                case "minite":
                    return String(format: "%02d", self.store_information.daytime.minute)
                default:
                    return ""
                }
            default:
                if array[1].prefix(7) == "address" {
                    let pattern = #"\[(\d*)-(\d*)\]"#
                    let text = String(array[1])
                    let start: Int, end: Int
                    if let regex = try? NSRegularExpression(pattern: pattern) {
                        let r = regex.firstMatch(in: text, range: NSRange(location: 0, length: text.count))
                        start = Int(NSString(string: text).substring(with: r!.range(at: 1)))!
                        end = Int(NSString(string: text).substring(with: r!.range(at: 2)))!
                        return String(self.store_information.address.suffix(self.store_information.address.count - start).prefix(end - start + 1))
                    }
                }
                return ""
            }
        case "register_information":
            switch array[1] {
            case "register_number":
                return self.register_information.register_number
            case "responsibility_number":
                return self.register_information.responsibily_number
            default :
                return ""
            }
        case "item_infotmation":
            switch array[1] {
            case "count":
                return String(self.item_information.count)
            default:
                if String(array[1]).prefix(5) == "items" {
                    let pattern = #"\[(\d*)\]"#
                    let text = String(array[1])
                    if let regex = try? NSRegularExpression(pattern: pattern) {
                        let r = regex.firstMatch(in: text, range: NSRange(location: 0, length: text.count))
                        index = Int(NSString(string: text).substring(with: r!.range(at: 1)))!
//                        print(index)
                    }
                    switch array[2] {
                    case "name":
                        return self.item_information.items[index].name
                    case "subtotal":
                        return String(self.item_information.items[index].subtotal)
                    case "discount":
                        return String(self.item_information.items[index].discount)
                    case "unit_price":
                        return String(self.item_information.items[index].unit_price)
                    case "quantity":
                        return String(self.item_information.items[index].quantity)
                    default:
                        if String(array[2]).prefix(19) == "is_reduced_tax_rate" {
                            let pattern = #"\?\"(.*)\":\"(.*)\""#
                            let text = String(array[2])
                            if let regex = try? NSRegularExpression(pattern: pattern) {
                                let r = regex.firstMatch(in: text, range: NSRange(location: 0, length: text.count))
//                                print(String(NSString(string: text).substring(with: r!.range(at: 1))))
                                return self.item_information.items[index].is_reduced_tax_rate ? String(NSString(string: text).substring(with: r!.range(at: 1))) : String(NSString(string: text).substring(with: r!.range(at: 2)))
                            }
                        }
                    }
                }
            }
            return ""
        case "accounting_information":
            switch array[1] {
            case "total_sum":
                return String(self.accounting_information.total_sum)
            case "total_sum_8":
                return String(self.accounting_information.total_sum_8)
            case "total_sum_10":
                return String(self.accounting_information.total_sum_10)
            case "item_total":
                return String(self.accounting_information.item_total)
            case "discount_total":
                return String(self.accounting_information.discount_total)
            case "internal_consumption_tex":
                return String(self.accounting_information.internal_consumption_tex)
            default:
                return ""
            }
        case "payment_information":
            switch array[1] {
            case "count":
                return String(self.payment_information.count)
            case "change":
                return String(self.payment_information.change)
            case "deposit":
                return String(self.payment_information.deposit)
            default :
                if String(array[1]).prefix(15) == "payment_methods" {
                    let pattern = #"\[(\d*)\]"#
                    let text = String(array[1])
                    if let regex = try? NSRegularExpression(pattern: pattern) {
                        let r = regex.firstMatch(in: text, range: NSRange(location: 0, length: text.count))
                        index = Int(NSString(string: text).substring(with: r!.range(at: 1)))!
//                        print(index)
                    }
                    switch array[2] {
                    case "name" :
                        return self.payment_information.payment_methods[index].name
                    case "paid" :
                        return String(self.payment_information.payment_methods[index].paid)
                    default:
                        return ""
                    }
                }
                return ""
            }
        default :
            return ""
        }
    }
}

class StoreInformation: XMLMappable {
    var nodeName: String!
    var nodesOrder: [String]? = ["store_name", "branch_name", "address", "phone_number", "daytime"]
    
    var store_name: String = ""
    var branch_name: String = ""
    var address: String = ""
    var phone_number: String = ""
    var daytime: DayTime = DayTime()
    
    init(){
    }
    
    required init?(map: XMLMap) {}

    func mapping(map: XMLMap) {
        store_name <- map["store_name"]
        branch_name <- map["branch_name"]
        address <- map["address"]
        phone_number <- map["phone_number"]
        daytime <- map["daytime"]
        nodesOrder <- map.nodesOrder
    }
}

class DayTime: XMLMappable {
    var nodeName: String!
    var nodesOrder: [String]? = ["year", "month", "date", "week", "time", "minute"]
    
    var year: Int = 2021
    var month: Int = 1
    var date: Int = 1
    var week: String = ""
    var time: Int = 1
    var minute: Int = 0
    
    init(){
        let date = Date()
        let f = DateFormatter()
        f.locale = Locale(identifier: "ja_JP")
        f.timeZone = TimeZone(identifier: "Asia/Tokyo")
        f.dateFormat = "yyyy"
        self.year = Int(f.string(from: date))!
        f.dateFormat = "MM"
        self.month = Int(f.string(from: date))!
        f.dateFormat = "dd"
        self.date = Int(f.string(from: date))!
        f.dateFormat = "EEE"
        self.week = f.string(from: date)
        f.dateFormat = "HH"
        self.time = Int(f.string(from: date))!
        f.dateFormat = "mm"
        self.minute = Int(f.string(from: date))!
    }
    
    required init?(map: XMLMap) {}

    func mapping(map: XMLMap) {
        year <- map["year"]
        month <- map["month"]
        date <- map["date"]
        week <- map["week"]
        time <- map["time"]
        minute <- map["minute"]
        nodesOrder <- map.nodesOrder
    }
    
    func toString() -> String {
        String(year) + "/" + String(format: "%02d", month) + "/" + String(format: "%02d", date) + " " + String(format: "%02d", time) + ":" + String(format: "%02d", minute)
    }
    
    func toStringTime() -> String {
        String(format: "%02d", time) + ":" + String(format: "%02d", minute)
    }
    
    func toStringDate() -> String {
        String(year) + "/" + String(format: "%02d", month) + "/" + String(format: "%02d", date)
    }
    
    func toStringMonth() -> String {
        String(year) + "/" + String(format: "%02d", month)
    }
}

class RegisterInformation: XMLMappable {
    
    var nodeName: String!
    var nodesOrder: [String]? = ["register_number", "responsibily_number"]
    
    var register_number: String = ""
    var responsibily_number: String = ""
    
    init() {
    }
    
    required init?(map: XMLMap) {}

    func mapping(map: XMLMap) {
        register_number <- map["register_number"]
        responsibily_number <- map["responsibily_number"]
        nodesOrder <- map.nodesOrder
    }
}

class ItemInformation: XMLMappable {
    
    var nodeName: String!
    var nodesOrder: [String]? = ["count", "items"]
    var count: Int = 0
    var items: [Item] = []
    
    init() {
    }
    
    required init?(map: XMLMap) {}

    func mapping(map: XMLMap) {
        count <- map["count"]
        items <- map["items.item"]
        nodesOrder <- map.nodesOrder
    }
}

class Item: XMLMappable {
    
    var nodeName: String!
    var nodesOrder: [String]? = ["id", "name", "subtotal", "is_reduced_tax_rate", "discount", "unit_price", "quantity"]
    
    var id: Int = -1
    var name: String = ""
    var subtotal: Int = 0
    var is_reduced_tax_rate: Bool = false
    var discount: Int = 0
    var unit_price: Int = 0
    var quantity: Int = 1
    
    init(_ id: Int,_ name: String,_ subtotal: Int,_ is_reduced_tax_rate: Bool,_ discount: Int, unit_price: Int,_ quantity: Int){
        self.id = id
        self.name = name
        self.subtotal = subtotal
        self.is_reduced_tax_rate = is_reduced_tax_rate
        self.discount = discount
        self.unit_price = unit_price
        self.quantity = quantity
    }
    init(_ id: Int){
        self.id = id
        self.name = ""
        self.subtotal = 0
        self.is_reduced_tax_rate = true
        self.discount = 0
        self.unit_price = 0
        self.quantity = 1
    }
    required init?(map: XMLMap) {}

    func mapping(map: XMLMap) {
        id <- map.attributes["id"]
        name <- map["name"]
        subtotal <- map["subtotal"]
        is_reduced_tax_rate <- map["is_reduced_tax_rate"]
        discount <- map["discount"]
        unit_price <- map["unit_price"]
        quantity <- map["quantity"]
        nodesOrder <- map.nodesOrder
    }
}

class AccountingInformation: XMLMappable {
    var nodeName: String!
    var nodesOrder: [String]? = ["item_total", "discount_total", "total_sum", "total_sum_8", "total_sum_10", "internal_consumption_tax"]
    
    var item_total: Int = 0
    var discount_total: Int = 0
    var total_sum: Int = 0
    var total_sum_8: Int = 0
    var total_sum_10: Int = 0
    var internal_consumption_tex: Int = 0
    
    init() {
        
    }
    
    required init?(map: XMLMap) {}

    func mapping(map: XMLMap) {
        item_total <- map["item_total"]
        discount_total <- map["discount_total"]
        total_sum <- map["total_sum"]
        total_sum_8 <- map["total_sum_8"]
        total_sum_10 <- map["total_sum_10"]
        internal_consumption_tex <- map["internal_consumption_tax"]
        nodesOrder <- map.nodesOrder
    }
    
}

class PaymentInformation: XMLMappable {
    var nodeName: String!
    var nodesOrder: [String]? = ["count", "payment_methods", "deposit", "change"]
    var count: Int = 0
    var payment_methods: [PaymentMethod] = []
    var deposit: Int = 0
    var change: Int = 0
    init() {
        self.count = 0
    }
    
    required init?(map: XMLMap) {}

    func mapping(map: XMLMap) {
        count <- map["count"]
        payment_methods <- map["payment_methods.payment_method"]
        deposit <- map["deposit"]
        change <- map["change"]
        nodesOrder <- map.nodesOrder
    }
}

class PaymentMethod: XMLMappable {
    var nodeName: String!
    var nodesOrder: [String]? = ["id", "name", "paid"]
    var id: Int = -1
    var name: String = ""
    var paid: Int = 0
    
    init(_ id: Int,_ name: String,_ paid: Int){
        self.id = id
        self.name = name
        self.paid = paid
    }
    
    init(_ id: Int){
        self.id = id
        self.name = ""
        self.paid = 0
    }
    
    required init?(map: XMLMap) {}

    func mapping(map: XMLMap) {
        id <- map.attributes["id"]
        name <- map["name"]
        paid <- map["paid"]
        nodesOrder <- map.nodesOrder
    }
}

class ReceiptLineInformation: XMLMappable {
    var nodeName: String!
    var nodesOrder: [String]? = ["count", "lines"]
    var count: Int = 0
    var lines: [Line] = []
    init() {
        self.count = 0
    }
    
    required init?(map: XMLMap) {}

    func mapping(map: XMLMap) {
        count <- map["count"]
        lines <- map["lines.line"]
        nodesOrder <- map.nodesOrder
    }
}

class Line: XMLMappable {
    var nodeName: String! = "line"
    var line: String = ""
    var id: Int = -1
    
    init(_ id: Int,_ text: String){
        self.id = id
        self.line = text
    }
    
    required init?(map: XMLMap) {}

    func mapping(map: XMLMap) {
        id <- map.attributes["id"]
        line <- map.innerText
    }
}
