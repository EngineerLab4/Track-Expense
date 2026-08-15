import SwiftUI

struct AddExpenseView: View {
    @EnvironmentObject var viewModel: ExpenseViewModel
    @Environment(\.dismiss) private var dismiss

    var expenseToEdit: Expense?

    @State private var title: String = ""
    @State private var amountText: String = ""
    @State private var category: ExpenseCategory = .food
    @State private var date: Date = .now
    @State private var note: String = ""

    private var isEditing: Bool { expenseToEdit != nil }

    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty && (Double(amountText) ?? 0) > 0
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Title", text: $title)
                    HStack {
                        Text(Locale.current.currencySymbol ?? "$")
                            .foregroundColor(.secondary)
                        TextField("Amount", text: $amountText)
                            .keyboardType(.decimalPad)
                    }
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }

                Section("Category") {
                    Picker("Category", selection: $category) {
                        ForEach(ExpenseCategory.allCases) { cat in
                            Label(cat.rawValue, systemImage: cat.icon).tag(cat)
                        }
                    }
                    .pickerStyle(.navigationLink)
                }

                Section("Note (optional)") {
                    TextField("Add a note", text: $note, axis: .vertical)
                        .lineLimit(3, reservesSpace: false)
                }
            }
            .navigationTitle(isEditing ? "Edit Expense" : "New Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(!isValid)
                }
            }
            .onAppear(perform: populateIfEditing)
        }
    }

    private func populateIfEditing() {
        guard let expense = expenseToEdit else { return }
        title = expense.title
        amountText = String(expense.amount)
        category = expense.category
        date = expense.date
        note = expense.note
    }

    private func save() {
        guard let amount = Double(amountText) else { return }
        if var existing = expenseToEdit {
            existing.title = title
            existing.amount = amount
            existing.category = category
            existing.date = date
            existing.note = note
            viewModel.updateExpense(existing)
        } else {
            let new = Expense(title: title, amount: amount, category: category, date: date, note: note)
            viewModel.addExpense(new)
        }
        dismiss()
    }
}

#Preview {
    AddExpenseView()
        .environmentObject(ExpenseViewModel())
}
