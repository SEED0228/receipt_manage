//
//  receipt_manageApp.swift
//  Shared
//
//  Created by 多根直輝 on 2021/04/08.
//

import SwiftUI

import Firebase
import PartialSheet

@main
struct receipt_manageApp: App {
    let sheetManager: PartialSheetManager = PartialSheetManager()
    var body: some Scene {
        WindowGroup {
//            HomeView()
            
            ContentView2()
                .environmentObject(UserData())
                .environmentObject(sheetManager)
        }
    }
    init(){
        // Init Firebase
        FirebaseApp.configure()
    }
}
