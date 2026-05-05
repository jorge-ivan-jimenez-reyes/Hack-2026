import SwiftUI

/// Orquesta cuándo aparecen los banners. Para demo: cada 12s muestra uno
/// random del banco. En prod los dispararía Foundation Models en base a
/// eventos reales del usuario (cubeta llena, día de pickup, etc).
@MainActor
@Observable
final class ReminderManager {
    var current: Reminder?

    private var timer: Timer?
    private var bank: [Reminder] = Reminder.bank.shuffled()
    private var bankIndex = 0

    private let initialDelay: TimeInterval = 4
    private let interval: TimeInterval = 14
    private let visibleDuration: TimeInterval = 5.5

    func start() {
        // Primera reminder a los 4s, después cada 14s
        DispatchQueue.main.asyncAfter(deadline: .now() + initialDelay) { [weak self] in
            self?.popNext()
            self?.scheduleNext()
        }
    }

    func dismiss() {
        withAnimation(.smooth(duration: 0.4)) {
            current = nil
        }
    }

    // MARK: - Private

    private func scheduleNext() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.popNext() }
        }
    }

    private func popNext() {
        guard !bank.isEmpty else { return }

        let next = bank[bankIndex % bank.count]
        bankIndex += 1

        Haptics.tap()
        withAnimation(.smooth(duration: 0.55, extraBounce: 0.05)) {
            current = next
        }

        // Auto-dismiss después de visibleDuration
        DispatchQueue.main.asyncAfter(deadline: .now() + visibleDuration) { [weak self] in
            guard let self else { return }
            // Solo dismiss si sigue siendo el mismo reminder
            if self.current?.id == next.id {
                self.dismiss()
            }
        }
    }
}
