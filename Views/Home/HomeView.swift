//
//  HomeView.swift
//  receipt_manage (iOS)
//
//  Created by 多根直輝 on 2021/06/26.
//

import SwiftUI

struct HomeView: View {
    
    @State var currentPage = 1
    @EnvironmentObject var userData: UserData
    
    init() {
        setupNavigationBar()
    }
     
    func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color("background"))
        appearance.titleTextAttributes = [.foregroundColor: UIColor(Color("labelText"))]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(Color("labelText"))]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        NavigationView {
             ZStack {
                Color("background")
                        .edgesIgnoringSafeArea(.all)
                VStack {
                    PageView(pages: [AnyView(ExpenditureView()),
                                     AnyView(MonthExpenditureView())], currentPage: $currentPage)
                        .aspectRatio(3 / 2, contentMode: .fit)
                        .listRowInsets(EdgeInsets())
                    Spacer()
                }
                
            }
            .listStyle(InsetListStyle())
            .navigationTitle("ReceiptLine")
            
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(UserData())
    }
}
