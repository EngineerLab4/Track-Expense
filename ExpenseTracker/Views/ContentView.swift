import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ExpenseViewModel()

    var body: some View {
        TabView {
            ExpenseListView()
                .tabItem {
                    Label("Expenses", systemImage: "list.bullet")
                }

            SummaryView()
                .tabItem {
                    Label("Summary", systemImage: "chart.pie.fill")
                }
        }
        .environmentObject(viewModel)
    }
}

struct ExpenseListView: View {
    @EnvironmentObject var viewModel: ExpenseViewModel
    @State private var showingAddExpense = false
    @State private var expenseToEdit: Expense?

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Total Spent")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Text(
                                viewModel.total,
                                format: .currency(code: currencyCode)
                            )
                            .font(.title2.weight(.bold))
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 4) {
                            Text("This Month")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Text(
                                viewModel.currentMonthTotal,
                                format: .currency(code: currencyCode)
                            )
                            .font(.title3.weight(.semibold))
                        }
                    }
                    .padding(.vertical, 6)
                }

                if viewModel.expenses.isEmpty {
                    Section {
                        Text("No expenses yet. Tap + to add your first one.")
                            .foregroundColor(.secondary)
                            .padding(.vertical, 20)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                } else {
                    ForEach(viewModel.groupedByDay, id: \.date) { group in
                        Section(
                            header: Text(
                                group.date,
                                format: .dateTime.month(.wide).day().year()
                            )
                        ) {
                            ForEach(group.expenses) { expense in
                                ExpenseRowView(expense: expense)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        expenseToEdit = expense
                                    }
                            }
                            .onDelete { offsets in
                                viewModel.deleteExpense(
                                    at: offsets,
                                    from: group.expenses
                                )
                            }
                        }
                    }
                }
            }
            .navigationTitle("Expenses")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddExpense = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingAddExpense) {
                AddExpenseView()
            }
            .sheet(item: $expenseToEdit) { expense in
                AddExpenseView(expenseToEdit: expense)
            }
        }
    }

    private var currencyCode: String {
        Locale.current.currency?.identifier ?? "USD"
    }
}

#Preview {
    ContentView()
}
