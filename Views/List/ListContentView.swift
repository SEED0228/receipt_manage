//
//  ListContentView.swift
//  receipt_manage (iOS)
//
//  Created by 多根直輝 on 2021/06/29.
//

import SwiftUI

struct ListContentView: View {
    @State var status: Status = .home
    @State var receipt_line: ReceiptLine = ReceiptLine()
    var body: some View {
        switch status {
        case Status.home:
            ListView(status: $status, receipt_line: $receipt_line)
        case Status.createReceiptLine:
            CreateReceiptView(receipt_line: $receipt_line, status: $status)
        default:
            ListView(status: $status, receipt_line: $receipt_line)
        }
    }
}

struct ListContentView_Previews: PreviewProvider {
    static var previews: some View {
        ListContentView()
    }
}
