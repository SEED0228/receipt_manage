//
//  CurrentView2.swift
//  receipt_manage (iOS)
//
//  Created by 多根直輝 on 2021/06/26.
//

import SwiftUI
import PartialSheet

struct ContentView2: View {
    @State private var selection: Tab = .home
    @EnvironmentObject var userData: UserData

    enum Tab {
        case home
        case camera
        case list
    }

    var body: some View {
        TabView(selection: $selection) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(Tab.home)

            CameraView()
                .tabItem {
                    Label("Add", systemImage: "camera")
                }
                .tag(Tab.camera)
            ListContentView()
                .tabItem {
                    Label("List", systemImage: "list.bullet")
                }
                .tag(Tab.list)
        }
        .addPartialSheet()
        .onAppear{
            userData.load_receipt_lines()
        }
    }
    
}

struct ContentView2_Previews: PreviewProvider {
    static var previews: some View {
        ContentView2()
            .environmentObject(UserData())
    }
}
