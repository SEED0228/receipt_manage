//
//  ItemListRow.swift
//  receipt_manage (iOS)
//
//  Created by 多根直輝 on 2021/04/09.
//

import SwiftUI

struct ItemListRow: View {
    let item: Display_Item
    
    var body: some View {
        HStack {
            Text(item.name)
                .font(.system(size: 12))
                .foregroundColor(.gray)
            Text("¥\(item.price)")
                .font(.system(size: 12))
                .foregroundColor(.gray)
        }
    }
}

struct ItemListRow_Previews: PreviewProvider {
    static var previews: some View {
        ItemListRow(item: Display_Item())
    }
}
