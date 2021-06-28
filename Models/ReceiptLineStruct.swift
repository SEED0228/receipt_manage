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
    var nodesOrder: [String]? = ["store_information", " register_information", "item_information", "accounting_information", "payment_information", "receipt_line_information"]
    
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
    var nodesOrder: [String]? = ["reister_number", "responsibility_number"]
    
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
