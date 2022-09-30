//
//  ContentView.swift
//  Why Not SwiftUI
//
//  Created by Md. Mahmudul Hasan Shohag on 8/8/22.
//

import SwiftUI

struct MainScreen: View {
    @StateObject private var mainVM = MainViewModel()

    var body: some View {
        Text("Hello, world!")
            .padding()
            .onAppear {
                mainVM.getPosts()
            }
    }
}

struct MainScreen_Previews: PreviewProvider {
    static var previews: some View {
        MainScreen()
    }
}
