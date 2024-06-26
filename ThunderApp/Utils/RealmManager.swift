//
//  RealmManager.swift
//  ThunderApp
//
//  Created by devonly on 2024/06/14.
//  Copyright © 2024 Magi. All rights reserved.
//

import Foundation
import Firebolt
import SwiftUI
import SwiftyLogger
import RealmSwift
import Raccoon

@Observable
final class RealmManager: Firebolt {
    private var realm: Realm = try! Realm()

    @discardableResult
    /// ブキ画像取得
    /// - Returns: <#description#>
    override func getWeaponRecord() async throws -> WeaponRecordQuery.Response {
        let response = try await super.getWeaponRecord()
        try await Raccoon.fetch(urls: response.assetURLs)
        return response
    }

    @discardableResult
    /// <#Description#>
    /// - Returns: <#description#>
    override func getCoopRecord() async throws -> CoopRecordQuery.Response {
        let response = try await super.getCoopRecord()
        try await Raccoon.fetch(urls: response.assetURLs)
        return response
    }

    @MainActor
    func refresh() async throws {
        try await getCoopRecord()
        try await getWeaponRecord()
        let schedules: [CoopScheduleQuery.Schedule] = try await getCoopSchedules().schedules
        inWriteTransaction(transaction: { [self] in
            schedules.forEach({ schedule in
                realm.update(RealmCoopSchedule.self, value: schedule, update: .modified)
            })
        })
        let histories: [CoopResultQuery.CoopHistory] = try await getCoopResults().histories
        inWriteTransaction(transaction: { [self] in
            histories.forEach({ history in
                // スケジュールがあればそれを使う、なければ作成して利用する
                let schedule: RealmCoopSchedule = {
                    realm.object(ofType: RealmCoopSchedule.self, forPrimaryKey: history.schedule.id) ?? .init(schedule: history.schedule)
                }()
                history.results.forEach({ result in
                    let result: RealmCoopResult = .init(result: result)
                    let data: RealmCoopResult = realm.create(RealmCoopResult.self, value: result, update: .modified)
                    if !schedule.results.contains(data) {
                        schedule.results.append(data)
                    }
                })
            })
        })
    }

    @MainActor
    private func inWriteTransaction(transaction writeBlock: @escaping () -> Void) {
        if realm.isInWriteTransaction {
            writeBlock()
        } else {
            realm.beginWrite()
            writeBlock()
            realm.commitAsyncWrite()
        }
    }
    
    @MainActor
    func removeAll() {
        inWriteTransaction(transaction: { [self] in
            realm.deleteAll()
        })
    }
}

extension EnvironmentValues {
    var realm: RealmManager {
        get { self[RealmKey.self] }
        set { self[RealmKey.self] = newValue }
    }
}

private struct RealmKey: EnvironmentKey {
    static var defaultValue: RealmManager = .init()
}
