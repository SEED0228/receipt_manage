//
//  ReceiptData.swift
//  receipt_manage (iOS)
//
//  Created by 多根直輝 on 2021/04/08.
//

import SwiftUI
import Foundation

class UserData: ObservableObject {
    @Published var receipts: [Receipt] = [
//        Receipt(store_name: "AEON", date: Date(timeInterval: 60*60*24*7, since: Date()), total_price: 600, items: [Display_Item()]),
//        Receipt(store_name: "Big A", date: Date(), total_price: 700, items: [Display_Item()]),
//        Receipt(store_name: "Test", date: Date(timeInterval: -60*60*24*7, since: Date()), total_price: 300, items: [Display_Item()])
    ]
    
    @Published var delete_option = false
    
    

    
    
}

