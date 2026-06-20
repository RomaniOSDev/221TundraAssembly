import Combine
import SwiftUI

struct FocusCycleView: View {
    @EnvironmentObject private var store: AppDataStore
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var viewModel = FocusCycleViewModel()

    var body: some View {
        NavigationStack {
            AppScreenBackground {
                ScrollView {
                    VStack(spacing: 20) {
                        timerSection
                        configCards
                        historySection
                        AppPrimaryButton(
                            title: viewModel.isRunning ? "Pause Focus Session" : "Start Focus Session",
                            icon: viewModel.isRunning ? "pause.fill" : "play.fill"
                        ) {
                            if viewModel.isRunning {
                                viewModel.pauseSession()
                            } else {
                                viewModel.requestStartSession()
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Focus Cycle Manager")
            .navigationBarTitleDisplayMode(.inline)
            .appNavigationStyle()
            .onAppear {
                viewModel.configure(store: store)
            }
            .onChange(of: scenePhase) { phase in
                if phase != .active {
                    viewModel.pauseForBackground()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .dataReset)) { _ in
                viewModel.resetSession()
                viewModel.configure(store: store)
            }
            .sheet(isPresented: $viewModel.showTaskPicker) {
                FocusTaskPickerSheet { taskId, title in
                    viewModel.selectTask(id: taskId, title: title)
                }
            }
            .sheet(isPresented: $viewModel.showSessionNoteSheet) {
                FocusSessionNoteSheet(
                    note: $viewModel.pendingNote,
                    taskTitle: viewModel.selectedTaskTitle.isEmpty ? "General Focus" : viewModel.selectedTaskTitle,
                    durationMinutes: viewModel.completedWorkSeconds / 60
                ) { note in
                    viewModel.saveSessionNote(note)
                }
            }
            .sheet(isPresented: $viewModel.editingWork) {
                durationEditor(
                    title: "Work Duration",
                    value: $viewModel.tempWorkMinutes,
                    range: 1...60
                ) {
                    viewModel.saveWorkDuration()
                }
            }
            .sheet(isPresented: $viewModel.editingBreak) {
                durationEditor(
                    title: "Break Duration",
                    value: $viewModel.tempBreakMinutes,
                    range: 1...30
                ) {
                    viewModel.saveBreakDuration()
                }
            }
            .overlay {
                SuccessCheckmarkOverlay(isVisible: $viewModel.showSuccessCheckmark)
            }
        }
    }

    private var timerSection: some View {
        FocusTimerHeroCard(
            timerDisplay: viewModel.timerDisplay,
            phaseLabel: phaseLabel,
            linkedTaskLabel: viewModel.linkedTaskLabel,
            progress: viewModel.timerProgress,
            isRunning: viewModel.isRunning,
            onPlayPause: {
                if viewModel.isRunning {
                    viewModel.pauseSession()
                } else {
                    viewModel.requestStartSession()
                }
            },
            onReset: { viewModel.resetSession() },
            onChangeTask: !viewModel.selectedTaskTitle.isEmpty && viewModel.phase == .work
                ? { viewModel.showTaskPicker = true }
                : nil,
            showTip: viewModel.phase == .idle && viewModel.completedCyclesToday == 0
        )
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { date in
            viewModel.tick(now: date)
        }
    }

    private var phaseLabel: String {
        switch viewModel.phase {
        case .idle: return "Ready"
        case .work: return "Focus Time"
        case .breakTime: return "Break Time"
        }
    }

    private var configCards: some View {
        VStack(spacing: 12) {
            FocusConfigCell(
                title: "Work Duration",
                value: viewModel.workDurationLabel,
                icon: "briefcase.fill"
            ) {
                viewModel.tempWorkMinutes = Double(store.workDurationSec) / 60.0
                viewModel.editingWork = true
            }

            FocusConfigCell(
                title: "Break Duration",
                value: viewModel.breakDurationLabel,
                icon: "cup.and.saucer.fill"
            ) {
                viewModel.tempBreakMinutes = Double(store.breakDurationSec) / 60.0
                viewModel.editingBreak = true
            }

            FocusConfigCell(
                title: "Completed Cycles Today",
                value: "\(viewModel.completedCyclesToday)",
                icon: "repeat.circle.fill",
                showEdit: false
            ) {}
        }
    }

    private var historySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            AppSectionHeader(title: "Focus History", icon: "clock.arrow.circlepath")

            if store.recentSessions(limit: 10).isEmpty {
                AppEmptyStateView(
                    icon: "clock",
                    title: "No sessions yet",
                    subtitle: "Complete a focus cycle to build your history."
                )
            } else {
                LazyVStack(spacing: 10) {
                    ForEach(store.recentSessions(limit: 10)) { session in
                        FocusSessionCell(session: session)
                    }
                }
            }
        }
    }

    private func durationEditor(title: String, value: Binding<Double>, range: ClosedRange<Double>, onSave: @escaping () -> Void) -> some View {
        NavigationStack {
            AppSheetBackground {
                VStack(spacing: 24) {
                    AppProgressRing(progress: value.wrappedValue / range.upperBound, size: 120)
                    Text("\(Int(value.wrappedValue)) min")
                        .font(.largeTitle.bold())
                        .foregroundStyle(Color("AppPrimary"))
                    Slider(value: value, in: range, step: 1)
                        .tint(Color("AppAccent"))
                        .padding(.horizontal, 24)
                    Spacer()
                }
                .padding(.top, 40)
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { onSave() }
                        .foregroundStyle(Color("AppPrimary"))
                }
            }
        }
        .presentationDetents([.medium])
    }
}
