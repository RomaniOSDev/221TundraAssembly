import Combine
import Foundation

final class AppDataStore: ObservableObject {
    static let shared = AppDataStore()

    private enum Keys {
        static let hasSeenOnboarding = "hasSeenOnboarding"
        static let totalSessionsCompleted = "totalSessionsCompleted"
        static let totalMinutesUsed = "totalMinutesUsed"
        static let totalFocusSeconds = "totalFocusSeconds"
        static let streakDays = "streakDays"
        static let longestStreak = "longestStreak"
        static let lastActivityDate = "lastActivityDate"
        static let achievementsUnlocked = "achievementsUnlocked"
        static let tasksCompleted = "tasksCompleted"
        static let focusSessionsCompleted = "focusSessionsCompleted"
        static let tasks = "tasks"
        static let workDurationSec = "workDurationSec"
        static let breakDurationSec = "breakDurationSec"
        static let completedCyclesToday = "completedCyclesToday"
        static let lastSessionDate = "lastSessionDate"
        static let habits = "habits"
        static let habitCompletionLog = "habitCompletionLog"
        static let maxHabitStreak = "maxHabitStreak"
        static let focusSessions = "focusSessions"
        static let dailyPlanTaskIDs = "dailyPlanTaskIDs"
        static let dailyPlanDateKey = "dailyPlanDateKey"
        static let focusBlocks = "focusBlocks"
        static let linkedFocusSessionsCount = "linkedFocusSessionsCount"
        static let perfectDaysCount = "perfectDaysCount"
        static let lastPerfectDayKey = "lastPerfectDayKey"
    }

    private let defaults = UserDefaults.standard
    private let calendar = Calendar.current

    @Published var hasSeenOnboarding: Bool {
        didSet { defaults.set(hasSeenOnboarding, forKey: Keys.hasSeenOnboarding) }
    }

    @Published var totalSessionsCompleted: Int {
        didSet { defaults.set(totalSessionsCompleted, forKey: Keys.totalSessionsCompleted) }
    }

    @Published var totalMinutesUsed: Int {
        didSet { defaults.set(totalMinutesUsed, forKey: Keys.totalMinutesUsed) }
    }

    @Published var totalFocusSeconds: Int {
        didSet { defaults.set(totalFocusSeconds, forKey: Keys.totalFocusSeconds) }
    }

    @Published var streakDays: Int {
        didSet { defaults.set(streakDays, forKey: Keys.streakDays) }
    }

    @Published var longestStreak: Int {
        didSet { defaults.set(longestStreak, forKey: Keys.longestStreak) }
    }

    @Published var lastActivityDate: Date? {
        didSet {
            if let date = lastActivityDate {
                defaults.set(date, forKey: Keys.lastActivityDate)
            } else {
                defaults.removeObject(forKey: Keys.lastActivityDate)
            }
        }
    }

    @Published var achievementsUnlocked: [String: Date] {
        didSet { saveAchievements() }
    }

    @Published var tasksCompleted: Int {
        didSet { defaults.set(tasksCompleted, forKey: Keys.tasksCompleted) }
    }

    @Published var focusSessionsCompleted: Int {
        didSet { defaults.set(focusSessionsCompleted, forKey: Keys.focusSessionsCompleted) }
    }

    @Published var tasks: [TaskItem] {
        didSet { saveTasks() }
    }

    @Published var workDurationSec: Int {
        didSet { defaults.set(workDurationSec, forKey: Keys.workDurationSec) }
    }

    @Published var breakDurationSec: Int {
        didSet { defaults.set(breakDurationSec, forKey: Keys.breakDurationSec) }
    }

    @Published var completedCyclesToday: Int {
        didSet { defaults.set(completedCyclesToday, forKey: Keys.completedCyclesToday) }
    }

    @Published var lastSessionDate: Date? {
        didSet {
            if let date = lastSessionDate {
                defaults.set(date, forKey: Keys.lastSessionDate)
            } else {
                defaults.removeObject(forKey: Keys.lastSessionDate)
            }
        }
    }

    @Published var habits: [HabitItem] {
        didSet { saveHabits() }
    }

    @Published var habitCompletionLog: [String: [UUID]] {
        didSet { saveHabitLog() }
    }

    @Published var maxHabitStreak: Int {
        didSet { defaults.set(maxHabitStreak, forKey: Keys.maxHabitStreak) }
    }

    @Published var focusSessions: [FocusSessionRecord] {
        didSet { saveFocusSessions() }
    }

    @Published var dailyPlanTaskIDs: [UUID] {
        didSet { defaults.set(dailyPlanTaskIDs.map(\.uuidString), forKey: Keys.dailyPlanTaskIDs) }
    }

    @Published var dailyPlanDateKey: String {
        didSet { defaults.set(dailyPlanDateKey, forKey: Keys.dailyPlanDateKey) }
    }

    @Published var focusBlocks: [FocusBlockPlan] {
        didSet { saveFocusBlocks() }
    }

    @Published var linkedFocusSessionsCount: Int {
        didSet { defaults.set(linkedFocusSessionsCount, forKey: Keys.linkedFocusSessionsCount) }
    }

    @Published var perfectDaysCount: Int {
        didSet { defaults.set(perfectDaysCount, forKey: Keys.perfectDaysCount) }
    }

    @Published var lastPerfectDayKey: String {
        didSet { defaults.set(lastPerfectDayKey, forKey: Keys.lastPerfectDayKey) }
    }

    @Published var pendingAchievementBanners: [AchievementDefinition] = []

    var totalFocusMinutes: Int { totalFocusSeconds / 60 }

    init() {
        hasSeenOnboarding = defaults.bool(forKey: Keys.hasSeenOnboarding)
        totalSessionsCompleted = defaults.integer(forKey: Keys.totalSessionsCompleted)
        totalMinutesUsed = defaults.integer(forKey: Keys.totalMinutesUsed)
        totalFocusSeconds = defaults.integer(forKey: Keys.totalFocusSeconds)
        streakDays = defaults.integer(forKey: Keys.streakDays)
        longestStreak = defaults.integer(forKey: Keys.longestStreak)
        lastActivityDate = defaults.object(forKey: Keys.lastActivityDate) as? Date
        achievementsUnlocked = Self.loadAchievements(from: defaults)
        tasksCompleted = defaults.integer(forKey: Keys.tasksCompleted)
        focusSessionsCompleted = defaults.integer(forKey: Keys.focusSessionsCompleted)
        tasks = Self.loadTasks(from: defaults)
        workDurationSec = defaults.object(forKey: Keys.workDurationSec) as? Int ?? 1500
        breakDurationSec = defaults.object(forKey: Keys.breakDurationSec) as? Int ?? 300
        completedCyclesToday = defaults.integer(forKey: Keys.completedCyclesToday)
        lastSessionDate = defaults.object(forKey: Keys.lastSessionDate) as? Date
        habits = Self.loadHabits(from: defaults)
        habitCompletionLog = Self.loadHabitLog(from: defaults)
        maxHabitStreak = defaults.integer(forKey: Keys.maxHabitStreak)
        focusSessions = Self.loadFocusSessions(from: defaults)
        dailyPlanTaskIDs = Self.loadDailyPlanTaskIDs(from: defaults)
        dailyPlanDateKey = defaults.string(forKey: Keys.dailyPlanDateKey) ?? ""
        focusBlocks = Self.loadFocusBlocks(from: defaults)
        linkedFocusSessionsCount = defaults.integer(forKey: Keys.linkedFocusSessionsCount)
        perfectDaysCount = defaults.integer(forKey: Keys.perfectDaysCount)
        lastPerfectDayKey = defaults.string(forKey: Keys.lastPerfectDayKey) ?? ""

        refreshDayBoundaries()
    }

    // MARK: - Day Boundaries

    func refreshDayBoundaries() {
        resetDailyCyclesIfNeeded()
        refreshDailyPlanIfNeeded()
        refreshRecurringTasks()
    }

    func refreshDailyPlanIfNeeded() {
        let todayKey = dateKey(for: Date())
        guard dailyPlanDateKey != todayKey else { return }
        dailyPlanDateKey = todayKey
        dailyPlanTaskIDs = dailyPlanTaskIDs.filter { id in
            tasks.contains { $0.id == id && !$0.isCompleted }
        }
        focusBlocks = focusBlocks.filter { $0.dateKey == todayKey }
    }

    func refreshRecurringTasks() {
        let today = Date()
        var updatedTasks = tasks
        var didChange = false

        for index in updatedTasks.indices {
            guard updatedTasks[index].isCompleted, updatedTasks[index].recurrence != .none else { continue }
            if shouldResetRecurringTask(updatedTasks[index], today: today) {
                updatedTasks[index].isCompleted = false
                didChange = true
            }
        }

        if didChange {
            tasks = updatedTasks
        }
    }

    private func shouldResetRecurringTask(_ task: TaskItem, today: Date) -> Bool {
        guard let completed = task.lastCompletedDate else { return false }
        if calendar.isDate(completed, inSameDayAs: today) { return false }

        switch task.recurrence {
        case .none:
            return false
        case .daily:
            return true
        case .weekdays:
            let weekday = calendar.component(.weekday, from: today)
            return weekday != 1 && weekday != 7
        case .weekly:
            let days = calendar.dateComponents([.day], from: calendar.startOfDay(for: completed), to: calendar.startOfDay(for: today)).day ?? 0
            return days >= 7
        }
    }

    // MARK: - Onboarding

    func completeOnboarding() {
        hasSeenOnboarding = true
        recordActivity()
    }

    // MARK: - Tasks

    func addTask(_ task: TaskItem) {
        tasks.append(task)
        recordActivity()
        HapticManager.mediumTap()
        SoundManager.playSuccess()
    }

    func deleteTask(id: UUID) {
        tasks.removeAll { $0.id == id }
        dailyPlanTaskIDs.removeAll { $0 == id }
        focusBlocks.removeAll { $0.taskId == id }
    }

    func toggleTaskCompletion(id: UUID) {
        guard let index = tasks.firstIndex(where: { $0.id == id }) else { return }
        let wasCompleted = tasks[index].isCompleted
        tasks[index].isCompleted.toggle()

        if tasks[index].isCompleted && !wasCompleted {
            tasks[index].lastCompletedDate = Date()
            tasksCompleted += 1
            dailyPlanTaskIDs.removeAll { $0 == id }
            recordActivity()
            HapticManager.lightTap()
            SoundManager.playVibrate()
            evaluatePerfectDay()
            checkAchievements()
        }
    }

    func filteredTasks(searchText: String, filter: TaskFilterOption) -> [TaskItem] {
        tasks.filter { task in
            let matchesSearch = searchText.isEmpty || task.title.localizedCaseInsensitiveContains(searchText)
            guard matchesSearch else { return false }

            switch filter {
            case .all:
                return true
            case .today:
                return calendar.isDateInToday(task.dueDate) || calendar.isDate(task.dueDate, inSameDayAs: Date())
            case .highPriority:
                return task.priority == .high
            case .overdue:
                return !task.isCompleted && task.dueDate < calendar.startOfDay(for: Date())
            }
        }
    }

    func tasksDueToday() -> [TaskItem] {
        tasks.filter { task in
            !task.isCompleted && (calendar.isDateInToday(task.dueDate) || task.dueDate <= Date())
        }
        .sorted { lhs, rhs in
            if lhs.priority != rhs.priority {
                return priorityRank(lhs.priority) > priorityRank(rhs.priority)
            }
            return lhs.dueDate < rhs.dueDate
        }
    }

    func topPlanTasks(limit: Int = 3) -> [TaskItem] {
        let pinned = dailyPlanTaskIDs.compactMap { id in tasks.first { $0.id == id && !$0.isCompleted } }
        if pinned.count >= limit { return Array(pinned.prefix(limit)) }

        var result = pinned
        let pinnedIDs = Set(pinned.map(\.id))
        for task in tasksDueToday() where !pinnedIDs.contains(task.id) {
            result.append(task)
            if result.count >= limit { break }
        }
        return result
    }

    func toggleDailyPlanTask(_ taskID: UUID) {
        refreshDailyPlanIfNeeded()
        if dailyPlanTaskIDs.contains(taskID) {
            dailyPlanTaskIDs.removeAll { $0 == taskID }
        } else if dailyPlanTaskIDs.count < 3 {
            dailyPlanTaskIDs.append(taskID)
        }
        HapticManager.lightTap()
    }

    func isInDailyPlan(_ taskID: UUID) -> Bool {
        dailyPlanTaskIDs.contains(taskID)
    }

    func focusMinutesToday(for taskID: UUID) -> Int {
        focusSessions
            .filter { $0.taskId == taskID && calendar.isDateInToday($0.completedAt) }
            .reduce(0) { $0 + $1.durationSeconds } / 60
    }

    func focusMinutesTodayTotal() -> Int {
        focusSessions
            .filter { calendar.isDateInToday($0.completedAt) }
            .reduce(0) { $0 + $1.durationSeconds } / 60
    }

    private func priorityRank(_ priority: TaskPriority) -> Int {
        switch priority {
        case .high: return 3
        case .medium: return 2
        case .low: return 1
        }
    }

    // MARK: - Focus

    func resetDailyCyclesIfNeeded() {
        guard let lastDate = lastSessionDate else { return }
        if !calendar.isDateInToday(lastDate) {
            completedCyclesToday = 0
        }
    }

    func recordFocusSession(taskId: UUID?, taskTitle: String, workSeconds: Int, note: String) {
        let record = FocusSessionRecord(
            taskId: taskId,
            taskTitle: taskTitle,
            durationSeconds: workSeconds,
            note: note
        )
        focusSessions.insert(record, at: 0)

        completedCyclesToday += 1
        focusSessionsCompleted += 1
        totalSessionsCompleted += 1
        totalFocusSeconds += workSeconds
        totalMinutesUsed = totalFocusSeconds / 60
        lastSessionDate = Date()

        if taskId != nil {
            linkedFocusSessionsCount += 1
        }

        markFocusBlockCompleted(taskId: taskId, taskTitle: taskTitle)
        recordActivity()
        HapticManager.success()
        SoundManager.playFocusComplete()
        evaluatePerfectDay()
        checkAchievements()
    }

    func sessionsToday() -> [FocusSessionRecord] {
        focusSessions.filter { calendar.isDateInToday($0.completedAt) }
    }

    func recentSessions(limit: Int = 20) -> [FocusSessionRecord] {
        Array(focusSessions.prefix(limit))
    }

    // MARK: - Focus Blocks

    func todaysFocusBlocks() -> [FocusBlockPlan] {
        let key = dateKey(for: Date())
        return focusBlocks.filter { $0.dateKey == key }
    }

    func addFocusBlock(taskId: UUID?, taskTitle: String, plannedMinutes: Int) {
        refreshDailyPlanIfNeeded()
        let block = FocusBlockPlan(
            taskId: taskId,
            taskTitle: taskTitle,
            plannedMinutes: plannedMinutes,
            dateKey: dateKey(for: Date())
        )
        focusBlocks.append(block)
        HapticManager.mediumTap()
        SoundManager.playSuccess()
    }

    func removeFocusBlock(id: UUID) {
        focusBlocks.removeAll { $0.id == id }
    }

    private func markFocusBlockCompleted(taskId: UUID?, taskTitle: String) {
        let key = dateKey(for: Date())
        if let index = focusBlocks.firstIndex(where: {
            $0.dateKey == key && !$0.isCompleted &&
            (($0.taskId != nil && $0.taskId == taskId) || $0.taskTitle == taskTitle)
        }) {
            focusBlocks[index].isCompleted = true
        }
    }

    // MARK: - Habits

    func addHabit(_ habit: HabitItem) {
        habits.append(habit)
        recordActivity()
        HapticManager.mediumTap()
        SoundManager.playSuccess()
    }

    func deleteHabit(id: UUID) {
        habits.removeAll { $0.id == id }
        for key in habitCompletionLog.keys {
            habitCompletionLog[key]?.removeAll { $0 == id }
        }
    }

    func updateHabit(_ habit: HabitItem) {
        guard let index = habits.firstIndex(where: { $0.id == habit.id }) else { return }
        habits[index] = habit
    }

    func habitsDueToday(on date: Date = Date()) -> [HabitItem] {
        habits.filter { habit in
            HabitScheduleHelper.isDue(on: date, frequency: habit.frequency, anchorWeekday: habit.anchorWeekday, calendar: calendar)
        }
    }

    func isHabitDueToday(_ habit: HabitItem, date: Date = Date()) -> Bool {
        HabitScheduleHelper.isDue(on: date, frequency: habit.frequency, anchorWeekday: habit.anchorWeekday, calendar: calendar)
    }

    func isHabitCompletedToday(_ habitID: UUID, date: Date = Date()) -> Bool {
        let key = dateKey(for: date)
        return habitCompletionLog[key]?.contains(habitID) ?? false
    }

    func toggleHabitCompletion(id: UUID, date: Date = Date()) {
        let key = dateKey(for: date)
        var completed = habitCompletionLog[key] ?? []

        if completed.contains(id) {
            completed.removeAll { $0 == id }
            habitCompletionLog[key] = completed
            recalculateHabitStreaks()
            return
        }

        completed.append(id)
        habitCompletionLog[key] = completed
        recalculateHabitStreaks()
        recordActivity()
        HapticManager.mediumTap()
        SoundManager.playHabitComplete()
        evaluatePerfectDay()
        checkAchievements()
    }

    func recalculateHabitStreaks() {
        var bestStreak = 0
        for index in habits.indices {
            let streak = computeStreak(for: habits[index].id)
            habits[index].streak = streak
            bestStreak = max(bestStreak, streak)
        }
        maxHabitStreak = bestStreak
    }

    private func computeStreak(for habitID: UUID) -> Int {
        var streak = 0
        var date = calendar.startOfDay(for: Date())

        while true {
            let key = dateKey(for: date)
            if habitCompletionLog[key]?.contains(habitID) == true {
                streak += 1
                guard let previous = calendar.date(byAdding: .day, value: -1, to: date) else { break }
                date = previous
            } else if streak == 0, calendar.isDateInToday(date) {
                guard let previous = calendar.date(byAdding: .day, value: -1, to: date) else { break }
                date = previous
            } else {
                break
            }
        }
        return streak
    }

    // MARK: - Daily Progress

    func dayProgressPercentage(on date: Date = Date()) -> Int {
        var totalUnits = 0
        var completedUnits = 0

        var taskCandidates = dailyPlanTaskIDs.compactMap { id in tasks.first { $0.id == id } }
        if taskCandidates.count < 3 {
            let existing = Set(taskCandidates.map(\.id))
            for task in tasksDueToday() where !existing.contains(task.id) {
                taskCandidates.append(task)
                if taskCandidates.count >= 3 { break }
            }
        }
        if !taskCandidates.isEmpty {
            totalUnits += taskCandidates.count
            completedUnits += taskCandidates.filter(\.isCompleted).count
        }

        let dueHabits = habitsDueToday(on: date)
        if !dueHabits.isEmpty {
            totalUnits += dueHabits.count
            completedUnits += dueHabits.filter { isHabitCompletedToday($0.id, date: date) }.count
        }

        let blocks = focusBlocks.filter { $0.dateKey == dateKey(for: date) }
        if !blocks.isEmpty {
            totalUnits += blocks.count
            completedUnits += blocks.filter(\.isCompleted).count
        }

        guard totalUnits > 0 else { return 0 }
        return min(100, Int((Double(completedUnits) / Double(totalUnits)) * 100.0))
    }

    private func evaluatePerfectDay() {
        let todayKey = dateKey(for: Date())
        guard dayProgressPercentage() >= 100 else { return }
        guard lastPerfectDayKey != todayKey else { return }
        lastPerfectDayKey = todayKey
        perfectDaysCount += 1
        checkAchievements()
    }

    // MARK: - Weekly Insights

    func weeklyFocusStats() -> [DailyFocusStat] {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"

        return (0..<7).reversed().compactMap { offset -> DailyFocusStat? in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: calendar.startOfDay(for: Date())) else { return nil }
            let key = dateKey(for: date)
            let seconds = focusSessions
                .filter { dateKey(for: $0.completedAt) == key }
                .reduce(0) { $0 + $1.durationSeconds }
            return DailyFocusStat(
                id: key,
                date: date,
                minutes: seconds / 60,
                weekdayLabel: formatter.string(from: date)
            )
        }
    }

    func weeklyHabitCompletionRate() -> Int {
        var dueCount = 0
        var completedCount = 0

        for offset in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: -offset, to: Date()) else { continue }
            let due = habitsDueToday(on: date)
            dueCount += due.count
            completedCount += due.filter { isHabitCompletedToday($0.id, date: date) }.count
        }

        guard dueCount > 0 else { return 0 }
        return Int((Double(completedCount) / Double(dueCount)) * 100)
    }

    func weeklyTasksCompletedCount() -> Int {
        tasks.filter { task in
            guard task.isCompleted, let completed = task.lastCompletedDate else { return false }
            guard let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) else { return false }
            return completed >= weekAgo
        }.count
    }

    func bestFocusDayThisWeek() -> String {
        let stats = weeklyFocusStats()
        guard let best = stats.max(by: { $0.minutes < $1.minutes }), best.minutes > 0 else {
            return "No data yet"
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: best.date)
    }

    func habitHeatmap(days: Int = 84) -> [HabitHeatmapDay] {
        (0..<days).reversed().compactMap { offset -> HabitHeatmapDay? in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: calendar.startOfDay(for: Date())) else { return nil }
            let key = dateKey(for: date)
            let count = habitCompletionLog[key]?.count ?? 0
            return HabitHeatmapDay(id: key, date: date, completionCount: count)
        }
    }

    // MARK: - Activity & Streaks

    func recordActivity() {
        let today = calendar.startOfDay(for: Date())

        if let last = lastActivityDate {
            let lastDay = calendar.startOfDay(for: last)
            if calendar.isDate(lastDay, inSameDayAs: today) {
                return
            }

            if let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
               calendar.isDate(lastDay, inSameDayAs: yesterday) {
                streakDays += 1
            } else {
                streakDays = 1
            }
        } else {
            streakDays = 1
        }

        longestStreak = max(longestStreak, streakDays)
        lastActivityDate = today
        checkAchievements()
    }

    var currentAppUsageStreak: Int {
        guard let last = lastActivityDate else { return 0 }
        let today = calendar.startOfDay(for: Date())
        let lastDay = calendar.startOfDay(for: last)

        if calendar.isDate(lastDay, inSameDayAs: today) {
            return streakDays
        }
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
           calendar.isDate(lastDay, inSameDayAs: yesterday) {
            return streakDays
        }
        return 0
    }

    // MARK: - Achievements

    func isAchievementUnlocked(_ id: String) -> Bool {
        achievementsUnlocked[id] != nil
    }

    func checkAchievements() {
        let conditions: [(String, Bool)] = [
            ("first_step", tasksCompleted >= 1),
            ("focus_starter", focusSessionsCompleted >= 1),
            ("routine_builder", maxHabitStreak >= 7),
            ("getting_going", tasksCompleted >= 10),
            ("power_user", tasksCompleted >= 50),
            ("three_day_streak", longestStreak >= 3),
            ("week_long_habit", longestStreak >= 7),
            ("time_invested", totalFocusSeconds >= 3600),
            ("linked_focus", linkedFocusSessionsCount >= 1),
            ("perfect_day", perfectDaysCount >= 1)
        ]

        for (id, met) in conditions where met && !isAchievementUnlocked(id) {
            unlockAchievement(id: id)
        }
    }

    private func unlockAchievement(id: String) {
        achievementsUnlocked[id] = Date()
        if let definition = AchievementDefinition.all.first(where: { $0.id == id }) {
            pendingAchievementBanners.append(definition)
        }
        HapticManager.success()
        SoundManager.playSuccess()
    }

    func dequeueAchievementBanner() -> AchievementDefinition? {
        guard !pendingAchievementBanners.isEmpty else { return nil }
        return pendingAchievementBanners.removeFirst()
    }

    // MARK: - Reset

    func resetAllData() {
        let domain = Bundle.main.bundleIdentifier ?? ""
        defaults.removePersistentDomain(forName: domain)
        defaults.synchronize()

        hasSeenOnboarding = false
        totalSessionsCompleted = 0
        totalMinutesUsed = 0
        totalFocusSeconds = 0
        streakDays = 0
        longestStreak = 0
        lastActivityDate = nil
        achievementsUnlocked = [:]
        tasksCompleted = 0
        focusSessionsCompleted = 0
        tasks = []
        workDurationSec = 1500
        breakDurationSec = 300
        completedCyclesToday = 0
        lastSessionDate = nil
        habits = []
        habitCompletionLog = [:]
        maxHabitStreak = 0
        focusSessions = []
        dailyPlanTaskIDs = []
        dailyPlanDateKey = ""
        focusBlocks = []
        linkedFocusSessionsCount = 0
        perfectDaysCount = 0
        lastPerfectDayKey = ""
        pendingAchievementBanners = []
    }

    // MARK: - Persistence Helpers

    func dateKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: calendar.startOfDay(for: date))
    }

    private func saveTasks() {
        if let data = try? JSONEncoder().encode(tasks) {
            defaults.set(data, forKey: Keys.tasks)
        }
    }

    private static func loadTasks(from defaults: UserDefaults) -> [TaskItem] {
        guard let data = defaults.data(forKey: Keys.tasks),
              let items = try? JSONDecoder().decode([TaskItem].self, from: data) else {
            return []
        }
        return items
    }

    private func saveHabits() {
        if let data = try? JSONEncoder().encode(habits) {
            defaults.set(data, forKey: Keys.habits)
        }
    }

    private static func loadHabits(from defaults: UserDefaults) -> [HabitItem] {
        guard let data = defaults.data(forKey: Keys.habits),
              let items = try? JSONDecoder().decode([HabitItem].self, from: data) else {
            return []
        }
        return items
    }

    private func saveHabitLog() {
        if let data = try? JSONEncoder().encode(habitCompletionLog) {
            defaults.set(data, forKey: Keys.habitCompletionLog)
        }
    }

    private static func loadHabitLog(from defaults: UserDefaults) -> [String: [UUID]] {
        guard let data = defaults.data(forKey: Keys.habitCompletionLog),
              let log = try? JSONDecoder().decode([String: [UUID]].self, from: data) else {
            return [:]
        }
        return log
    }

    private func saveFocusSessions() {
        if let data = try? JSONEncoder().encode(focusSessions) {
            defaults.set(data, forKey: Keys.focusSessions)
        }
    }

    private static func loadFocusSessions(from defaults: UserDefaults) -> [FocusSessionRecord] {
        guard let data = defaults.data(forKey: Keys.focusSessions),
              let items = try? JSONDecoder().decode([FocusSessionRecord].self, from: data) else {
            return []
        }
        return items.sorted { $0.completedAt > $1.completedAt }
    }

    private static func loadDailyPlanTaskIDs(from defaults: UserDefaults) -> [UUID] {
        guard let strings = defaults.stringArray(forKey: Keys.dailyPlanTaskIDs) else { return [] }
        return strings.compactMap(UUID.init(uuidString:))
    }

    private func saveFocusBlocks() {
        if let data = try? JSONEncoder().encode(focusBlocks) {
            defaults.set(data, forKey: Keys.focusBlocks)
        }
    }

    private static func loadFocusBlocks(from defaults: UserDefaults) -> [FocusBlockPlan] {
        guard let data = defaults.data(forKey: Keys.focusBlocks),
              let items = try? JSONDecoder().decode([FocusBlockPlan].self, from: data) else {
            return []
        }
        return items
    }

    private func saveAchievements() {
        let encoded = achievementsUnlocked.mapValues { $0.timeIntervalSince1970 }
        if let data = try? JSONEncoder().encode(encoded) {
            defaults.set(data, forKey: Keys.achievementsUnlocked)
        }
    }

    private static func loadAchievements(from defaults: UserDefaults) -> [String: Date] {
        guard let data = defaults.data(forKey: Keys.achievementsUnlocked),
              let encoded = try? JSONDecoder().decode([String: TimeInterval].self, from: data) else {
            return [:]
        }
        return encoded.mapValues { Date(timeIntervalSince1970: $0) }
    }
}
