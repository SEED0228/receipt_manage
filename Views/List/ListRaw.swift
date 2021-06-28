//
//  ListRaw.swift
//  
//
//  Created by 多根直輝 on 2021/06/29.
//

import SwiftUI

struct ListRaw: View {
    var receipt_line: ReceiptLine
    @Binding var status: Status
    @Binding var edit_receipt_line: ReceiptLine
    var body: some View {
        Button(action: {editReceiptLine()}){
            ZStack {
                VStack() {
                    Spacer()
                    HStack {
                        Text(receipt_line.store_information.daytime.toStringTime())
                            .font(.system(size: 20))
                            .padding(.leading, 10)
                        Spacer()
                    }
                    
                    Spacer()
                }
                VStack() {
                    Spacer()
                    VStack {
                        HStack {
                            Text("¥\(receipt_line.accounting_information.total_sum)")
                                .bold()
                                .font(.system(size: 24))
                                
                            Spacer()
                        }
                        HStack {
                            Image(systemName: "location.circle")
                            Text("\(receipt_line.store_information.store_name),\(receipt_line.item_information.items[0].name)他\(receipt_line.item_information.count)件")
                                .font(.system(size: 15))
                                .lineLimit(1)
                                
                            Spacer()
                        }
                    }
                    .padding(.leading, 70)
                    
                    Spacer()
                }
            }
            .frame(height: 50)
        }
    }
    
    func editReceiptLine() {
        edit_receipt_line = receipt_line
        status = .createReceiptLine
    }
}

struct ListRaw_Previews: PreviewProvider {
    static var receipt_line: ReceiptLine = ReceiptLine()
    @State static var status: Status = .home
    @State static var edit_receipt_line: ReceiptLine = ReceiptLine()

    static var previews: some View {
        ListRaw(receipt_line: receipt_line, status: $status, edit_receipt_line: $edit_receipt_line)
    }
}
