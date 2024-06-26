//
//  MyPageView.swift
//  Salmonia3+
//  
//  Created by devonly on 2024/06/02.
//  Copyright © 2024 Magi. All rights reserved.
//

import SwiftUI
import Raccoon

struct MyPageView: View {
    @EnvironmentObject private var config: ThunderConfig

    var body: some View {
        ScrollView(content: {
            LazyVGrid(columns: .init(repeating: .init(.flexible(maximum: 69.13)), count: 4), content: {
                SignIn()
                RemoveAll()
            })
        })
    }
}

#Preview {
    MyPageView()
}
