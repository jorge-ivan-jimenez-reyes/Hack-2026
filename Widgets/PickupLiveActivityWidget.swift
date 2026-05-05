import WidgetKit
import SwiftUI
import ActivityKit

/// Live Activity para pickup — muestra ETA del camión en Lock Screen y Dynamic Island.
struct PickupLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PickupActivityAttributes.self) { context in
            // Lock Screen UI (full)
            lockScreenView(context: context)
                .activityBackgroundTint(.green.opacity(0.1))
                .activitySystemActionForegroundColor(.green)
        } dynamicIsland: { context in
            // Dynamic Island
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    HStack {
                        Image(systemName: "shippingbox.fill")
                            .foregroundStyle(.green)
                        VStack(alignment: .leading, spacing: 0) {
                            Text(context.attributes.centroName)
                                .font(.caption.weight(.semibold))
                                .lineLimit(1)
                            Text(context.state.driverName + " · " + context.state.truckPlate)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(etaText(context.state))
                        .font(.callout.weight(.bold))
                        .foregroundStyle(.green)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(stepText(context.state.step))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        ProgressView(value: progressForStep(context.state))
                            .tint(.green)
                    }
                }
            } compactLeading: {
                Image(systemName: "shippingbox.fill")
                    .foregroundStyle(.green)
            } compactTrailing: {
                Text(etaText(context.state))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.green)
            } minimal: {
                Image(systemName: "shippingbox.fill")
                    .foregroundStyle(.green)
            }
        }
    }

    private func lockScreenView(context: ActivityViewContext<PickupActivityAttributes>) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(.green.opacity(0.15))
                Image(systemName: iconForStep(context.state.step))
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.green)
            }
            .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: 2) {
                Text(stepText(context.state.step))
                    .font(.callout.weight(.semibold))
                Text("\(context.attributes.centroName) · \(context.state.driverName)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                ProgressView(value: progressForStep(context.state))
                    .tint(.green)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(etaText(context.state))
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.green)
                Text("ETA")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
    }

    private func iconForStep(_ step: PickupContentState.Step) -> String {
        switch step {
        case .scheduled: "calendar.badge.clock"
        case .arriving:  "shippingbox.fill"
        case .arrived:   "checkmark.circle.fill"
        case .completed: "checkmark.seal.fill"
        }
    }

    private func stepText(_ step: PickupContentState.Step) -> String {
        switch step {
        case .scheduled: "Pickup agendado"
        case .arriving:  "Tu camión llega pronto"
        case .arrived:   "Tu camión está afuera"
        case .completed: "Recolección completada"
        }
    }

    private func etaText(_ state: PickupContentState) -> String {
        switch state.step {
        case .completed: return "Listo"
        case .arrived:   return "0 min"
        case .arriving, .scheduled:
            return state.etaMinutes <= 1 ? "1 min" : "\(state.etaMinutes) min"
        }
    }

    private func progressForStep(_ state: PickupContentState) -> Double {
        switch state.step {
        case .scheduled: return 0.20
        case .arriving:  return max(0.40, 1.0 - Double(state.etaMinutes) / 30.0)
        case .arrived:   return 0.95
        case .completed: return 1.0
        }
    }
}
