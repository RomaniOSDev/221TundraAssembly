import Foundation

struct AchievementDefinition: Identifiable {
    let id: String
    let title: String
    let description: String
    let iconName: String

    static let all: [AchievementDefinition] = [
        AchievementDefinition(
            id: "first_step",
            title: "First Step",
            description: "Completed the first task.",
            iconName: "checkmark.circle.fill"
        ),
        AchievementDefinition(
            id: "focus_starter",
            title: "Focus Starter",
            description: "Completed the first focus session.",
            iconName: "timer"
        ),
        AchievementDefinition(
            id: "routine_builder",
            title: "Routine Builder",
            description: "Checked in a habit for a week straight.",
            iconName: "calendar.badge.checkmark"
        ),
        AchievementDefinition(
            id: "getting_going",
            title: "Getting Going",
            description: "Reached 10 items.",
            iconName: "star.fill"
        ),
        AchievementDefinition(
            id: "power_user",
            title: "Power User",
            description: "Reached 50 items.",
            iconName: "bolt.fill"
        ),
        AchievementDefinition(
            id: "three_day_streak",
            title: "Three-Day Streak",
            description: "Used the app 3 days in a row.",
            iconName: "flame.fill"
        ),
        AchievementDefinition(
            id: "week_long_habit",
            title: "Week-Long Habit",
            description: "Used the app 7 days in a row.",
            iconName: "flame.circle.fill"
        ),
        AchievementDefinition(
            id: "time_invested",
            title: "Time Invested",
            description: "Spent 60 minutes total in the app.",
            iconName: "clock.fill"
        ),
        AchievementDefinition(
            id: "linked_focus",
            title: "Deep Work",
            description: "Completed a focus session linked to a task.",
            iconName: "link.circle.fill"
        ),
        AchievementDefinition(
            id: "perfect_day",
            title: "Perfect Day",
            description: "Reached 100% daily plan progress.",
            iconName: "sun.max.fill"
        )
    ]
}
