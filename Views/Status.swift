//
//  Status.swift
//  receipt_manage (iOS)
//
//  Created by 多根直輝 on 2021/06/27.
//

import SwiftUI

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

enum Status {
    case home
    case scan
    case photoLibrary
    case selectImages
    case createReceiptLine
}
