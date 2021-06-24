//
//  ReceiptLineStruct.swift
//  receipt_manage (iOS)
//
//  Created by 多根直輝 on 2021/06/10.
//

import Foundation
import SwiftUI

struct ReceiptLine {
    var store_information: StoreInformation
    var register_information: RegisterInformation
    var item_information: ItemInformation
    var accounting_information: AccountingInformation
    var payment_information: PaymentInformation
    var receipt_line_information: ReceiptLineInformation
    init(){
        self.store_information = StoreInformation()
        self.register_information = RegisterInformation()
        self.item_information = ItemInformation()
        self.accounting_information = AccountingInformation()
        self.payment_information = PaymentInformation()
        self.receipt_line_information = ReceiptLineInformation()
    }
    func createReceiptLineLangage() {
        
    }
}

struct StoreInformation {
    var store_name: String
    var branch_name: String
    var address: String
    var phone_number: String
    var daytime: DayTime
    init(){
        self.store_name = ""
        self.branch_name = ""
        self.address = ""
        self.phone_number = ""
        self.daytime = DayTime()
    }
}

struct DayTime {
    var year: String
    var month: String
    var date: String
    var week: String
    var time: String
    var minute: String
    init(){
        self.year = ""
        self.month = ""
        self.date = ""
        self.week = ""
        self.time = ""
        self.minute = ""
    }
}

struct RegisterInformation {
    var register_number: String
    var responsibily_number: String
    init() {
        self.register_number = ""
        self.responsibily_number = ""
    }
}

struct ItemInformation {
    var count: Int
    var items: [Item] = []
    init() {
        self.count = 0
    }
}

struct Item {
    var id: Int
    var name: String
    var subtotal: Int
    var is_reduced_tax_rate: Bool
    var discount: Int
    var unit_price: Int
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
}

struct AccountingInformation {
    var item_total: Int = 0
    var discount_total: Int = 0
    var total_sum: Int = 0
    var total_sum_8: Int = 0
    var total_sum_10: Int = 0
    var internal_consumption_tex: Int = 0
    
    init() {
        
    }
    
}

struct PaymentInformation {
    var count: Int = 0
    var payment_methods: [PaymentMethod] = []
    var deposit: Int = 0
    var change: Int = 0
    init() {
        self.count = 0
    }
}

struct PaymentMethod {
    var id: Int
    var name: String
    var paid: Int
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
}

struct ReceiptLineInformation {
    var count: Int = 0
    var lines: [Line] = []
    init() {
        self.count = 0
    }
}

struct Line {
    var line: String
    init(_ text: String){
        self.line = text
    }
}
