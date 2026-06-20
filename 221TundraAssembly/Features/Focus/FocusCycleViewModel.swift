import Combine
import Foundation
import SwiftUI

enum FocusPhase {
    case idle
    case work
    case breakTime
}

@MainActor
final class FocusCycleViewModel: ObservableObject {
    @Published var phase: FocusPhase = .idle
    @Published var remainingSeconds: Int = 1500
    @Published var isRunning = false
    @Published var showSuccessCheckmark = false
    @Published var editingWork = false
    @Published var editingBreak = false
    @Published var tempWorkMinutes: Double = 25
    @Published var tempBreakMinutes: Double = 5
    @Published var showTaskPicker = false
    @Published var showSessionNoteSheet = false
    @Published var selectedTaskId: UUID?
    @Published var selectedTaskTitle: String = ""
    @Published var pendingNote: String = ""

    private var store: AppDataStore?
    private var endDate: Date?
    private var pendingWorkSeconds = 0

    var completedWorkSeconds: Int {
        pendingWorkSeconds > 0 ? pendingWorkSeconds : (store?.workDurationSec ?? 1500)
    }

    var timerProgress: Double {
        guard let store else { return 0 }
        let total: Int
        switch phase {
        case .work:
            total = store.workDurationSec
        case .breakTime:
            total = store.breakDurationSec
        case .idle:
            total = store.workDurationSec
        }
        guard total > 0 else { return 0 }
        return 1.0 - (Double(remainingSeconds) / Double(total))
    }

    func configure(store: AppDataStore) {
        self.store = store
        remainingSeconds = store.workDurationSec
        tempWorkMinutes = Double(store.workDurationSec) / 60.0
        tempBreakMinutes = Double(store.breakDurationSec) / 60.0
        Task { @MainActor in
            store.resetDailyCyclesIfNeeded()
        }
    }

    var workDurationLabel: String {
        formatDuration(store?.workDurationSec ?? 1500)
    }

    var breakDurationLabel: String {
        formatDuration(store?.breakDurationSec ?? 300)
    }

    var completedCyclesToday: Int {
        store?.completedCyclesToday ?? 0
    }

    var timerDisplay: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var linkedTaskLabel: String {
        if selectedTaskTitle.isEmpty {
            return "No task selected"
        }
        return selectedTaskTitle
    }

    func requestStartSession() {
        guard let store else { return }
        if phase == .idle && selectedTaskTitle.isEmpty {
            showTaskPicker = true
            return
        }
        startSession(store: store)
    }

    func selectTask(id: UUID?, title: String) {
        selectedTaskId = id
        selectedTaskTitle = title
        showTaskPicker = false
        HapticManager.mediumTap()
        if let store, phase == .idle {
            startSession(store: store)
        }
    }

    private func startSession(store: AppDataStore) {
        if phase == .idle {
            phase = .work
            remainingSeconds = store.workDurationSec
        }
        endDate = Date().addingTimeInterval(TimeInterval(remainingSeconds))
        isRunning = true
        HapticManager.mediumTap()
        SoundManager.playTick()
    }

    func pauseSession() {
        if let end = endDate {
            remainingSeconds = max(0, Int(end.timeIntervalSinceNow))
        }
        endDate = nil
        isRunning = false
        HapticManager.lightTap()
    }

    func resetSession() {
        guard let store else { return }
        phase = .idle
        isRunning = false
        endDate = nil
        remainingSeconds = store.workDurationSec
        selectedTaskId = nil
        selectedTaskTitle = ""
        HapticManager.lightTap()
    }

    func tick(now: Date) {
        guard isRunning, let end = endDate else { return }
        let left = max(0, Int(end.timeIntervalSince(now)))
        remainingSeconds = left

        if left == 0 {
            handlePhaseComplete()
        }
    }

    func pauseForBackground() {
        if isRunning {
            pauseSession()
        }
    }

    private func handlePhaseComplete() {
        guard let store else { return }
        isRunning = false
        endDate = nil

        switch phase {
        case .work:
            pendingWorkSeconds = store.workDurationSec
            pendingNote = ""
            showSessionNoteSheet = true
            showSuccessCheckmark = true
        case .breakTime:
            phase = .idle
            remainingSeconds = store.workDurationSec
            HapticManager.success()
            SoundManager.playSuccess()
            showSuccessCheckmark = true
        case .idle:
            break
        }
    }

    func saveSessionNote(_ note: String) {
        guard let store else { return }
        let title = selectedTaskTitle.isEmpty ? "General Focus" : selectedTaskTitle
        store.recordFocusSession(
            taskId: selectedTaskId,
            taskTitle: title,
            workSeconds: pendingWorkSeconds,
            note: note
        )
        showSessionNoteSheet = false
        phase = .breakTime
        remainingSeconds = store.breakDurationSec
        endDate = Date().addingTimeInterval(TimeInterval(remainingSeconds))
        isRunning = true
    }

    func saveWorkDuration() {
        guard let store else { return }
        let seconds = max(60, Int(tempWorkMinutes) * 60)
        store.workDurationSec = seconds
        if phase == .idle {
            remainingSeconds = seconds
        }
        editingWork = false
        HapticManager.mediumTap()
        SoundManager.playSuccess()
    }

    func saveBreakDuration() {
        guard let store else { return }
        let seconds = max(60, Int(tempBreakMinutes) * 60)
        store.breakDurationSec = seconds
        editingBreak = false
        HapticManager.mediumTap()
        SoundManager.playSuccess()
    }

    private func formatDuration(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        if s == 0 { return "\(m) min" }
        return String(format: "%d:%02d", m, s)
    }
}
