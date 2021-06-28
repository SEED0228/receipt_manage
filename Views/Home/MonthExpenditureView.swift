//
//  MonthExpenditureView.swift
//  receipt_manage (iOS)
//
//  Created by 多根直輝 on 2021/06/26.
//

import SwiftUI

struct MonthExpenditureView: View {
    @State var total_sum: Int = 0
    @State var count: Int = 0
    @EnvironmentObject var userData: UserData
    var date: Date = Date()
    var body: some View {
        GeometryReader { geometry in
            
            ZStack {
                Color("background")
                        .edgesIgnoringSafeArea(.all)
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .frame(width: geometry.size.width * 4 / 5, height: 200)
                    VStack {
                        Text("今月の支出")
                            .padding(.bottom, 30)
                            .foregroundColor(.black)
                        Text("¥\(total_sum)")
                            .font(.largeTitle)
                            .padding(.bottom, 30)
                            .foregroundColor(.black)
                        Text("登録されたレシート: \(count)件")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }
                .padding(geometry.size.width / 10)
            }
            
       }
        .onAppear{
            count = 0
            total_sum = 0
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "ja_JP")
            dateFormatter.dateFormat = "yyyy/MM"
            dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
            let receipt_lines = userData.receipt_lines.filter {
                $0.store_information.daytime.toStringMonth() == dateFormatter.string(from: date)
            }
            for receipt_line in receipt_lines {
                total_sum += receipt_line.accounting_information.total_sum
                count += 1
            }
        }
    }
}

struct MonthExpenditureView_Previews: PreviewProvider {
    static var previews: some View {
        MonthExpenditureView()
            .environmentObject(UserData())
    }
}
