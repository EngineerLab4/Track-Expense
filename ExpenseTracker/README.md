# Expense Tracker (SwiftUI)

A native iOS/macOS expense tracker built with Swift + SwiftUI. Requires iOS 16+ / macOS 13+ (uses the Charts framework).

## Features
- Add, edit, and delete expenses (title, amount, category, date, note)
- Expenses grouped by day, with a running total and this-month total
- Category picker with icons and colors (Food, Transport, Shopping, Bills, Entertainment, Health, Other)
- Summary tab with a donut chart and per-category breakdown for the current month
- Monthly budget with a progress bar (turns orange near the limit, red when over)
- Data persists automatically to `UserDefaults` as JSON — no backend needed
- Sample data included on first launch so the app isn't empty

## Project structure
```
ExpenseTracker/
├── ExpenseTrackerApp.swift        # App entry point
├── Models/
│   └── Expense.swift              # Expense + ExpenseCategory
├── ViewModels/
│   └── ExpenseViewModel.swift     # State, persistence, totals
└── Views/
    ├── ContentView.swift          # Tab bar + expense list
    ├── ExpenseRowView.swift       # Single row in the list
    ├── AddExpenseView.swift       # Add/edit form (sheet)
    └── SummaryView.swift          # Charts + budget card
```

## How to run it

1. Open Xcode → **File → New → Project** → choose **iOS → App**.
2. Name it "ExpenseTracker", interface **SwiftUI**, language **Swift**.
3. Delete the default `ContentView.swift` Xcode generates.
4. Drag the `Models`, `ViewModels`, and `Views` folders (and `ExpenseTrackerApp.swift`) from this download into your Xcode project navigator — check "Copy items if needed."
5. Set the deployment target to iOS 16.0 or later (Project settings → General → Minimum Deployments) since the Summary tab uses `Charts`.
6. Build and run (⌘R) on a simulator or device.

## Notes / possible next steps
- Swap `UserDefaults` for SwiftData or Core Data if you want more robust storage or iCloud sync.
- Add recurring expenses or multi-currency support if needed.
- The budget is a single global monthly figure — could be extended to per-category budgets.
