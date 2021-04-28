//
//  UserReceipt.swift
//  receipt_manage (iOS)
//
//  Created by 多根直輝 on 2021/04/08.
//

import Foundation
import SwiftUI

struct Receipt:Identifiable, Equatable, Codable{
    var id = UUID()
    var store_name: String
    var date: Date
    var total_price: Int
    var is_selected: Bool = false // for selecting receipts
    var is_deleted: Bool = false
    var items: [Item] = []
    init(store_name: String, date: Date, total_price: Int, items: [Item]){
        self.store_name = store_name
        self.date = date
        self.total_price = total_price
        self.items = items
    }
    init(){
        self.store_name = ""
        self.date = Date()
        self.total_price = 0
    }
}

struct Item:Identifiable, Equatable, Codable{
    var id = UUID()
    var name: String
    var price: Int
    //var receipt_uuid: String
    init(name: String, price: Int/*, receipt_uuid: String*/){
        self.name = name
        self.price = price
        //self.receipt_uuid = receipt_uuid
    }
    init() {
        self.name = ""
        self.price = 0
        //self.receipt_uuid = "uuid"
    }
}


