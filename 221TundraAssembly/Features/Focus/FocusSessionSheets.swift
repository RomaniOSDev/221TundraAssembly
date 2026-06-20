import SwiftUI

struct FocusTaskPickerSheet: View {
    @EnvironmentObject private var store: AppDataStore
    @Environment(\.dismiss) private var dismiss

    let onSelect: (UUID?, String) -> Void

    var body: some View {
        NavigationStack {
            AppSheetBackground {
                ScrollView {
                    VStack(spacing: 10) {
                        TaskPickerCell(
                            title: "General Focus",
                            subtitle: "Untimed deep work without a linked task",
                            icon: "timer"
                        ) {
                            onSelect(nil, "General Focus")
                            dismiss()
                        }

                        if store.tasks.filter({ !$0.isCompleted }).isEmpty {
                            AppEmptyStateView(
                                icon: "list.bullet.rectangle",
                                title: "No active tasks",
                                subtitle: "Create a task in the Tasks tab first."
                            )
                        } else {
                            ForEach(store.tasks.filter { !$0.isCompleted }) { task in
                                TaskPickerCell(
                                    title: task.title,
                                    subtitle: "\(task.category.rawValue) • \(task.priority.rawValue)",
                                    icon: "link.circle.fill"
                                ) {
                                    onSelect(task.id, task.title)
                                    dismiss()
                                }
                            }
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Select Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        HapticManager.lightTap()
                        dismiss()
                    }
                    .foregroundStyle(Color("AppTextSecondary"))
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

struct FocusSessionNoteSheet: View {
    @Binding var note: String
    let taskTitle: String
    let durationMinutes: Int
    let onSave: (String) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            AppSheetBackground {
                VStack(alignment: .leading, spacing: 18) {
                    HStack(spacing: 14) {
                        AppIconBadge(icon: "checkmark.seal.fill", size: 52, style: .success)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Session Complete")
                                .font(.title3.bold())
                                .foregroundStyle(Color("AppTextPrimary"))
                            Text("Worked on: \(taskTitle) — \(durationMinutes) min")
                                .font(.subheadline)
                                .foregroundStyle(Color("AppTextSecondary"))
                                .lineLimit(2)
                                .minimumScaleFactor(0.7)
                        }
                    }
                    .padding(16)
                    .appCard()

                    Text("How did it go?")
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))

                    TextField("Optional reflection...", text: $note, axis: .vertical)
                        .lineLimit(3...5)
                        .foregroundStyle(Color("AppTextPrimary"))
                        .padding(14)
                        .appCard(cornerRadius: 14, elevated: false)

                    Spacer()
                }
                .padding(16)
            }
            .navigationTitle("Reflection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        HapticManager.mediumTap()
                        SoundManager.playSuccess()
                        onSave(note)
                        dismiss()
                    }
                    .foregroundStyle(Color("AppPrimary"))
                }
            }
        }
        .presentationDetents([.medium])
        .interactiveDismissDisabled()
    }
}
