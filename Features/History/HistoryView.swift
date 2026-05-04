import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(sort: \ScanRecord.createdAt, order: .reverse) private var records: [ScanRecord]
    @Environment(\.modelContext) private var context

    var body: some View {
        NavigationStack {
            Group {
                if records.isEmpty {
                    emptyState
                } else {
                    list
                }
            }
            .navigationTitle("Historial")
        }
    }

    private var emptyState: some View {
        ContentUnavailableView(
            "Sin escaneos aún",
            systemImage: "tray",
            description: Text("Tus escaneos aparecerán aquí.")
        )
    }

    private var list: some View {
        List {
            ForEach(records) { record in
                row(record)
            }
            .onDelete { indices in
                indices.map { records[$0] }.forEach(context.delete)
            }
        }
        .listStyle(.insetGrouped)
    }

    private func row(_ record: ScanRecord) -> some View {
        HStack(spacing: Spacing.m) {
            ZStack {
                Circle().fill(record.category.color.opacity(0.2))
                Image(systemName: record.category.symbolName)
                    .foregroundStyle(record.category.color)
            }
            .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 2) {
                Text(record.category.displayName).font(.appHeadline)
                Text(record.summary)
                    .font(.appCaption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            Spacer()
            Text(record.createdAt, style: .relative)
                .font(.appCaption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, Spacing.xs)
        .accessibleCard(label: "\(record.category.displayName), \(record.summary)")
    }
}

#Preview {
    HistoryView()
        .modelContainer(for: ScanRecord.self, inMemory: true)
}
