//
//  receipt_manageApp.swift
//  Shared
//
//  Created by 多根直輝 on 2021/04/08.
//

import SwiftUI

import Firebase

@main
struct receipt_manageApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(UserData())
        }
    }
    init(){
        // Init Firebase
        FirebaseApp.configure()
    }
}
