//
//  SchedulesView.swift
//  Salmonia3+
//  
//  Created by devonly on 2024/06/02.
//  Copyright © 2024 Magi. All rights reserved.
//

import SwiftUI
import RealmSwift
import Firebolt

struct SchedulesView: View {
    @Environment(\.realm) private var realm: RealmManager
    @ObservedResults(RealmCoopSchedule.self) var schedules

    var body: some View {
        NavigationView(content: {
            _body
        })
    }

    private var _body: some View {
        List(content: {
            ForEach(schedules, content: { schedule in
                ScheduleView(schedule: schedule)
            })
        })
        .listStyle(.plain)
        .navigationBarTitleDisplayMode(.inline)
        .refreshable(action: {
            try await realm.refresh()
        })
    }
}

#Preview {
    SchedulesView()
}
