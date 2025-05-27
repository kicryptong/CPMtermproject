// Activity.swift

import Foundation
import SwiftData

@Model
class Activity {
    public var id: Int
    public var name: String
    public var duration: Int

    // SwiftData 관계 매핑용 백업 배열
    public var parentPred: [Activity] = []
    public var parentSucc: [Activity] = []

    @Relationship(deleteRule: .nullify, inverse: \Activity.parentPred)
    public var predecessors: [Activity] = []

    @Relationship(deleteRule: .nullify, inverse: \Activity.parentSucc)
    public var successors: [Activity] = []

    // CPM 계산용 필드
    public var earlyStart: Int = 0
    public var earlyFinish: Int = 0
    public var lateStart: Int = 0
    public var lateFinish: Int = 0
    public var totalFloat: Int = 0
    public var freeFloat: Int = 0
    public var actualStart: Int = 0
    public var actualFinish: Int = 0

    // 비용 관련 속성 (단위: USD)
    public var materialCost: Double = 0.0
    public var overheadCost: Double = 0.0
    public var equipmentCost: Double = 0.0

    // 인력 투입 인원수
    public var laborCount: Int = 0

    // 최저시급 (달러/시간) — 필요에 따라 변경
    static let hourlyWage: Double = 15.0

    // 계산된 총비용
    public var totalCost: Double {
        let laborCost = Double(laborCount) * 8.0 * Activity.hourlyWage
        return materialCost + overheadCost + equipmentCost + laborCost
    }

    // MARK: 초기화
    init(
        id: Int,
        name: String,
        duration: Int,
        predecessors: [Activity] = [],
        successors: [Activity] = []
    ) {
        self.id = id
        self.name = name
        self.duration = duration
        self.predecessors = predecessors
        self.successors = successors
    }

    init(id: Int, name: String, duration: Int) {
        self.id = id
        self.name = name
        self.duration = duration
    }

    // MARK: 시간 설정 메서드
    public func setEarlyTime(earlyStart: Int, earlyFinish: Int) {
        self.earlyStart = earlyStart
        self.earlyFinish = earlyFinish
    }
    public func setLateTime(lateStart: Int, lateFinish: Int) {
        self.lateStart = lateStart
        self.lateFinish = lateFinish
    }

    // MARK: 첫 활동 판단
    public func isFirst() -> Bool {
        if predecessors.isEmpty { return true }
        return predecessors.map { $0.actualFinish }.allSatisfy { $0 > 0 }
    }

    // MARK: 관계 설정
    public func setRelation(
        predecessors: [Activity] = [],
        successors: [Activity] = []
    ) {
        self.predecessors = predecessors
        self.successors = successors
    }
}
