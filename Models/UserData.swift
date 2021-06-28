//
//  ReceiptData.swift
//  receipt_manage (iOS)
//
//  Created by 多根直輝 on 2021/04/08.
//

import SwiftUI
import Foundation
import XMLMapper

class UserData: ObservableObject {
    @Published var receipts: [Receipt] = [
//        Receipt(store_name: "AEON", date: Date(timeInterval: 60*60*24*7, since: Date()), total_price: 600, items: [Display_Item()]),
//        Receipt(store_name: "Big A", date: Date(), total_price: 700, items: [Display_Item()]),
//        Receipt(store_name: "Test", date: Date(timeInterval: -60*60*24*7, since: Date()), total_price: 300, items: [Display_Item()])
    ]
    
    @Published var delete_option = false
    @Published var receipt_lines: [ReceiptLine] = []
    
    func sortReceiptLine() {
        receipt_lines.sort(by: {(($0.store_information.daytime.year * 365 + $0.store_information.daytime.month * 31 + $0.store_information.daytime.date) * 24 + $0.store_information.daytime.time) * 60 + $0.store_information.daytime.minute < (($1.store_information.daytime.year * 365 + $1.store_information.daytime.month * 31 + $1.store_information.daytime.date) * 24 + $1.store_information.daytime.time) * 60 + $1.store_information.daytime.minute})
    }
    
    func load_receipt_lines() {
        do {
            receipt_lines = []
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let contentURLs = try FileManager.default.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            for url in contentURLs {
                let data = readFromFile(url: url)
//                print(url.path.suffix(40).prefix(36)) //uuidの取得
                do {
                    let xml = try XMLSerialization.xmlObject(with: data, options: [.default, .cdataAsString])
                    let rl = XMLMapper<ReceiptLine>().map(XMLObject: xml)!
                    rl.uuid = UUID(uuidString: String(url.path.suffix(40).prefix(36)))!
                    receipt_lines.append(rl)
//                    print(rl!.uuid)
                } catch {
                    print(error)
                }
//                print(receipt_line)
                
            }
            sortReceiptLine()
            print(receipt_lines)
            for i in receipt_lines {
                print(i.store_information.daytime.toString())
            }
//            print(contentURLs)
        } catch {
            print(error)
        }
    }
    
    func readFromFile(url: URL) -> Data {
        guard let fileContents = try? Data(contentsOf: url) else {
            fatalError("ファイル読み込みエラー")
        }
        return fileContents
    }


    
    
}

