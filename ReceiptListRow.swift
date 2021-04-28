//
//  ListRow.swift
//  receipt_manage (iOS)
//
//  Created by 多根直輝 on 2021/04/08.
//

import SwiftUI

struct ReceiptListRow: View {
    let receipt: Receipt
    let delete_option: Bool
    @Environment(\.timeZone) var timeZone
    
    var dateFormat: DateFormatter {
        let dformat = DateFormatter()
        dformat.dateStyle = .medium
        dformat.timeStyle = .medium
        dformat.dateFormat = "yyyy-MM-dd HH:mm"
        dformat.timeZone  = timeZone
        return dformat
    }

    
    var body: some View {
        HStack {
            if delete_option {
                if receipt.is_deleted {
                    Text("☑︎")
                }
                else {
                    Text("□")
                }
            }
            VStack(alignment: .leading) {
                Text(receipt.store_name)
                Text(dateFormat.string(from: receipt.date))
                    .foregroundColor(.gray)
                    .font(.system(size: 10))
            }
        
            Spacer()
            Text("\(receipt.items.count) items")
                .foregroundColor(.gray)
            Text("¥\(receipt.total_price)")
        }
    }
}

struct ReceiptListRow_Previews: PreviewProvider {
    static var previews: some View {
        ReceiptListRow(receipt: Receipt(), delete_option: true)
    }
}
