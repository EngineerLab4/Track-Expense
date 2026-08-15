import SwiftUI

struct ExpenseRowView: View {
    let expense: Expense

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(expense.category.color.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: expense.category.icon)
                    .foregroundColor(expense.category.color)
                    .font(.system(size: 16, weight: .semibold))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(expense.title)
                    .font(.body.weight(.medium))
                Text(expense.category.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(expense.amount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                .font(.body.weight(.semibold))
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ExpenseRowView(expense: Expense(title: "Groceries", amount: 54.20, category: .food, date: .now))
        .padding()
}
