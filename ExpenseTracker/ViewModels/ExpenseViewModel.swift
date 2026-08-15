import Foundation
import Combine

@MainActor
final class ExpenseViewModel: ObservableObject {
    @Published var expenses: [Expense] = [] {
        didSet { save() }
    }
    @Published var monthlyBudget: Double = 1000 {
        didSet { UserDefaults.standard.set(monthlyBudget, forKey: budgetKey) }
    }

    private let storageKey = "expense_tracker_expenses"
    private let budgetKey = "expense_tracker_budget"

    init() {
        load()
        monthlyBudget = UserDefaults.standard.double(forKey: budgetKey)
        if monthlyBudget == 0 { monthlyBudget = 1000 }
    }

    // MARK: - CRUD

    func addExpense(_ expense: Expense) {
        expenses.append(expense)
    }

    func updateExpense(_ expense: Expense) {
        guard let index = expenses.firstIndex(where: { $0.id == expense.id }) else { return }
        expenses[index] = expense
    }

    func deleteExpense(at offsets: IndexSet, from filtered: [Expense]) {
        let idsToDelete = offsets.map { filtered[$0].id }
        expenses.removeAll { idsToDelete.contains($0.id) }
    }

    func delete(_ expense: Expense) {
        expenses.removeAll { $0.id == expense.id }
    }

    // MARK: - Computed

    var total: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }

    var currentMonthExpenses: [Expense] {
        let calendar = Calendar.current
        let now = Date()
        return expenses.filter {
            calendar.isDate($0.date, equalTo: now, toGranularity: .month) &&
            calendar.isDate($0.date, equalTo: now, toGranularity: .year)
        }
    }

    var currentMonthTotal: Double {
        currentMonthExpenses.reduce(0) { $0 + $1.amount }
    }

    var remainingBudget: Double {
        monthlyBudget - currentMonthTotal
    }

    func total(for category: ExpenseCategory, in scope: [Expense]? = nil) -> Double {
        let source = scope ?? expenses
        return source.filter { $0.category == category }.reduce(0) { $0 + $1.amount }
    }

    func totalsByCategory(in scope: [Expense]? = nil) -> [(category: ExpenseCategory, total: Double)] {
        let source = scope ?? expenses
        return ExpenseCategory.allCases
            .map { category in
                (
                    category,
                    source
                        .filter { expense in
                            expense.category == category
                        }
                        .reduce(0) { total, expense in
                            total + expense.amount
                        }
                )
            }
            .filter { $0.1 > 0 }
            .sorted { $0.1 > $1.1 }
    }

    var groupedByDay: [(date: Date, expenses: [Expense])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: expenses) { calendar.startOfDay(for: $0.date) }
        return grouped
            .map { (date: $0.key, expenses: $0.value.sorted { $0.date > $1.date }) }
            .sorted { $0.date > $1.date }
    }

    // MARK: - Persistence

    private func save() {
        if let data = try? JSONEncoder().encode(expenses) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([Expense].self, from: data) else {
            expenses = Self.sampleData
            return
        }
        expenses = decoded
    }

    static var sampleData: [Expense] {
        let now = Date()
        let cal = Calendar.current
        return [
            Expense(title: "Groceries", amount: 54.20, category: .food, date: now),
            Expense(title: "Uber ride", amount: 12.50, category: .transport, date: cal.date(byAdding: .day, value: -1, to: now) ?? now),
            Expense(title: "Netflix", amount: 15.99, category: .entertainment, date: cal.date(byAdding: .day, value: -2, to: now) ?? now),
            Expense(title: "Electricity bill", amount: 88.00, category: .bills, date: cal.date(byAdding: .day, value: -3, to: now) ?? now)
        ]
    }
}
