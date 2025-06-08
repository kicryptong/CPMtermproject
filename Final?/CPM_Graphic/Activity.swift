import Foundation
import SwiftData

@Model
class Activity {
    // Basic info
    public var id: Int
    public var name: String
    public var duration: Int

    // SwiftData relationship helpers
    public var parentPred: [Activity] = []
    public var parentSucc: [Activity] = []

    @Relationship(deleteRule: .nullify, inverse: \Activity.parentPred)
    public var predecessors: [Activity] = []

    @Relationship(deleteRule: .nullify, inverse: \Activity.parentSucc)
    public var successors: [Activity] = []

    // CPM fields
    public var earlyStart: Int = 0
    public var earlyFinish: Int = 0
    public var lateStart: Int = 0
    public var lateFinish: Int = 0
    public var totalFloat: Int = 0
    public var freeFloat: Int = 0
    public var actualStart: Int = 0
    public var actualFinish: Int = 0

    // Cost-related inputs
    public var materialCost: Double = 0.0
    public var overheadCost: Double = 0.0  // Used as Indirect Cost
    public var equipmentCost: Double = 0.0
    public var markup: Double = 0.0

    public var laborCount: Int = 0
    public var hourlyWage: Double = 0.0  // 👈 user-defined per activity
    public var totalBilled: Double {
        return subtotal * (1 + markup)
    }

    // MARK: 💰 Computed Cost Properties

    /// Labor Cost = workers × duration × 8 hours/day × hourly wage
    public var laborCost: Double {
        return Double(laborCount) * Double(duration) * 8.0 * hourlyWage
    }

    /// Direct = material + equipment + labor
    public var directCost: Double {
        return materialCost + equipmentCost + laborCost
    }

    /// Subtotal = direct + indirect (overhead)
    public var subtotal: Double {
        return directCost + overheadCost
    }

    /// Subtotal Daily Cost = subtotal / duration
    public var subtotalDailyCost: Double {
        guard duration > 0 else { return 0.0 }
        return subtotal / Double(duration)
    }

    /// Markup Daily Cost = (subtotal × markup) / duration
    public var markupDailyCost: Double {
        guard duration > 0 else { return 0.0 }
        return (subtotal * markup) / Double(duration)
    }

    
    // MARK: Initializers

    init(
        id: Int,
        name: String,
        duration: Int,
        predecessors: [Activity] = [],
        successors: [Activity] = [],
        hourlyWage: Double = 0.0
    ) {
        self.id = id
        self.name = name
        self.duration = duration
        self.predecessors = predecessors
        self.successors = successors
        self.hourlyWage = hourlyWage
    }

    init(id: Int, name: String, duration: Int) {
        self.id = id
        self.name = name
        self.duration = duration
    }

    // MARK: Time setters
    public func setEarlyTime(earlyStart: Int, earlyFinish: Int) {
        self.earlyStart = earlyStart
        self.earlyFinish = earlyFinish
    }

    public func setLateTime(lateStart: Int, lateFinish: Int) {
        self.lateStart = lateStart
        self.lateFinish = lateFinish
    }

    // MARK: Logic helpers

    public func isFirst() -> Bool {
        return predecessors.isEmpty || predecessors.allSatisfy { $0.actualFinish > 0 }
    }

    public func setRelation(
        predecessors: [Activity] = [],
        successors: [Activity] = []
    ) {
        self.predecessors = predecessors
        self.successors = successors
    }
}

// MARK: - Monthly Cost Breakdown Utility


func monthlyCostBreakdown(for activities: [Activity], projectDuration: Int) -> [(month: Int, subtotal: Double, markup: Double)] {
    var monthlyCosts: [(Int, Double, Double)] = []

    guard projectDuration > 0 else {
        return monthlyCosts
    }

    let daysInMonth = 30
    let numberOfMonths = Int(ceil(Double(projectDuration) / Double(daysInMonth)))

    for month in 1...numberOfMonths {
        let monthStart = (month - 1) * daysInMonth
        let monthEnd = month * daysInMonth - 1

        var subtotalSum: Double = 0
        var markupSum: Double = 0

        for activity in activities {
            let activityStart = activity.earlyStart
            let activityEnd = activity.earlyFinish

            if activityEnd < monthStart || activityStart > monthEnd {
                continue
            }

            let effectiveStart = max(monthStart, activityStart)
            let effectiveEnd = min(monthEnd, activityEnd)
            let activeDays = max(0, effectiveEnd - effectiveStart + 1)

            subtotalSum += Double(activeDays) * activity.subtotalDailyCost
            markupSum += Double(activeDays) * activity.markupDailyCost
        }

        monthlyCosts.append((month, subtotalSum, markupSum))
    }

    return monthlyCosts
}
