import SwiftUI
import Charts

struct SummaryView: View {
    @EnvironmentObject var viewModel: ExpenseViewModel
    @State private var editingBudget = false
    @State private var budgetText = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    budgetCard

                    if viewModel.currentMonthExpenses.isEmpty {
                        ContentUnavailableCompat(message: "No expenses this month yet.")
                            .padding(.top, 40)
                    } else {
                        chartCard
                        categoryBreakdown
                    }
                }
                .padding()
            }
            .navigationTitle("Summary")
        }
    }

    private var budgetCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Monthly Budget")
                    .font(.headline)
                Spacer()
                Button(editingBudget ? "Done" : "Edit") {
                    if editingBudget {
                        if let value = Double(budgetText) { viewModel.monthlyBudget = value }
                    } else {
                        budgetText = String(format: "%.0f", viewModel.monthlyBudget)
                    }
                    editingBudget.toggle()
                }
                .font(.subheadline)
            }

            if editingBudget {
                TextField("Budget amount", text: $budgetText)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
            }

            let progress = viewModel.monthlyBudget > 0 ? min(viewModel.currentMonthTotal / viewModel.monthlyBudget, 1) : 0
            ProgressView(value: progress)
                .tint(progress >= 1 ? .red : (progress > 0.8 ? .orange : .green))

            HStack {
                Text(viewModel.currentMonthTotal, format: .currency(code: currencyCode))
                    .font(.subheadline.weight(.semibold))
                Text("of")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(viewModel.monthlyBudget, format: .currency(code: currencyCode))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text(viewModel.remainingBudget >= 0 ? "Remaining" : "Over budget")
                    .font(.caption)
                    .foregroundColor(viewModel.remainingBudget >= 0 ? .secondary : .red)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))
    }

    private var chartCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("This Month by Category")
                .font(.headline)

            Chart(viewModel.totalsByCategory(in: viewModel.currentMonthExpenses), id: \.category) { item in
                SectorMark(
                    angle: .value("Total", item.total),
                    innerRadius: .ratio(0.6),
                    angularInset: 1.5
                )
                .foregroundStyle(item.category.color)
                .cornerRadius(4)
            }
            .frame(height: 220)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))
    }

    private var categoryBreakdown: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Breakdown")
                .font(.headline)

            ForEach(viewModel.totalsByCategory(in: viewModel.currentMonthExpenses), id: \.category) { item in
                HStack {
                    Image(systemName: item.category.icon)
                        .foregroundColor(item.category.color)
                        .frame(width: 24)
                    Text(item.category.rawValue)
                    Spacer()
                    Text(item.total, format: .currency(code: currencyCode))
                        .fontWeight(.semibold)
                }
                .padding(.vertical, 4)
                if item.category != viewModel.totalsByCategory(in: viewModel.currentMonthExpenses).last?.category {
                    Divider()
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))
    }

    private var currencyCode: String {
        Locale.current.currency?.identifier ?? "USD"
    }
}

/// Lightweight stand-in for ContentUnavailableView so this targets iOS 16+ as well as 17+.
struct ContentUnavailableCompat: View {
    let message: String
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "chart.pie")
                .font(.system(size: 36))
                .foregroundColor(.secondary)
            Text(message)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    SummaryView()
        .environmentObject(ExpenseViewModel())
}
