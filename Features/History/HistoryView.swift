import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(sort: \ScanRecord.createdAt, order: .reverse) private var records: [ScanRecord]
    @Environment(\.modelContext) private var context

    @State private var bouncePulse = 0

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
            .animation(AppAnimation.smooth, value: records.count)
        }
    }

    private var emptyState: some View {
        VStack(spacing: Spacing.l) {
            Image(systemName: "tray")
                .font(.system(size: 64))
                .foregroundStyle(.tertiary)
                .symbolEffect(.bounce, value: bouncePulse)
                .onAppear {
                    Task {
                        while !Task.isCancelled {
                            try? await Task.sleep(for: .seconds(2.5))
                            bouncePulse += 1
                        }
                    }
                }
            Text("Sin escaneos aún")
                .font(.appTitle2)
            Text("Tus escaneos aparecerán aquí.")
                .font(.appBody)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }

    private var list: some View {
        List {
            ForEach(records) { record in
                row(record)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .top)),
                        removal: .opacity.combined(with: .move(edge: .leading))
                    ))
            }
            .onDelete { indices in
                Haptics.warning()
                withAnimation(AppAnimation.spring) {
                    indices.map { records[$0] }.forEach(context.delete)
                }
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
