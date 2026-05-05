import SwiftUI

/// Hero gigante que cambia según la etapa del recolector.
/// Es la pieza central del Home — siempre el primer foco visual.
struct HeroCubetaCard: View {
    let state: RecolectorState
    let onPrimaryAction: () -> Void

    var body: some View {
        ZStack {
            backdrop

            switch state.stage {
            case .filling, .waitingPickup, .justDelivered, .onboardingPending:
                fillingState
            case .bucketReady:
                bucketReadyState
            case .abonoReady:
                abonoReadyState
            }
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 240)
        .clipShape(RoundedRectangle(cornerRadius: Radius.xl, style: .continuous))
        .padding(.horizontal, Spacing.l)
    }

    // MARK: - Backdrop

    private var backdrop: some View {
        ZStack {
            LinearGradient(
                colors: [Color.brand, Color.brand.opacity(0.75)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Circle()
                .fill(.white.opacity(0.12))
                .blur(radius: 30)
                .frame(width: 280, height: 280)
                .offset(x: 110, y: -70)
        }
    }

    // MARK: - States

    private var fillingState: some View {
        VStack(alignment: .leading, spacing: Spacing.l) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Tu cubeta")
                        .font(.appCallout)
                        .foregroundStyle(.white.opacity(0.85))
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(Int(state.currentBucketProgress * 100))")
                            .font(.system(size: 64, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .contentTransition(.numericText())
                        Text("%")
                            .font(.appTitle2.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.85))
                    }
                }
                Spacer()
                Image(systemName: "leaf.fill")
                    .font(.system(size: 64, weight: .regular))
                    .foregroundStyle(.white.opacity(0.6))
                    .rotationEffect(.degrees(-15))
                    .symbolEffect(.pulse, options: .repeat(.continuous))
            }

            ProgressView(value: state.currentBucketProgress)
                .tint(.white)
                .scaleEffect(y: 1.6)
                .background(.white.opacity(0.18), in: .capsule)

            modalityChip
        }
        .padding(Spacing.xl)
    }

    /// Chip que cambia según la modalidad del usuario:
    /// - .pickup → "Pickup mié 6:00am" (tu cubeta llega a domicilio)
    /// - .dropOff → "Composta Roma Norte abre mañana 8am · 0.4 km"
    @ViewBuilder
    private var modalityChip: some View {
        switch state.serviceMode {
        case .pickup:
            if let next = state.nextPickupDate {
                chip(
                    icon: "shippingbox.fill",
                    text: "Pickup \(next.formatted(.dateTime.weekday(.wide).hour().minute()))"
                )
            }
        case .dropOff:
            if let center = state.nearestCenter {
                chip(
                    icon: "mappin.circle.fill",
                    text: "\(center.name) abre \(center.nextOpeningDate.formatted(.relative(presentation: .named))) · \(formattedDistance(center.distanceKm))"
                )
            }
        }
    }

    private func chip(icon: String, text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
            Text(text)
                .font(.appCallout.weight(.medium))
                .lineLimit(1)
                .truncationMode(.tail)
        }
        .foregroundStyle(.white.opacity(0.9))
        .padding(.horizontal, Spacing.m)
        .padding(.vertical, Spacing.s)
        .glassEffect(.regular.tint(.white.opacity(0.15)), in: .capsule)
    }

    private func formattedDistance(_ km: Double) -> String {
        if km < 1 {
            return "\(Int(km * 1000)) m"
        }
        return String(format: "%.1f km", km)
    }

    private var bucketReadyState: some View {
        VStack(spacing: Spacing.m) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 56))
                .foregroundStyle(.white)
                .symbolEffect(.bounce, options: .repeat(2))
            Text("Tu cubeta está lista")
                .font(.appTitle.weight(.bold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
            Button {
                Haptics.confirm()
                onPrimaryAction()
            } label: {
                HStack(spacing: Spacing.s) {
                    Text("Programar entrega")
                        .font(.appHeadline.weight(.semibold))
                    Image(systemName: "arrow.right")
                }
                .foregroundStyle(Color.brand)
                .padding(.horizontal, Spacing.xl)
                .padding(.vertical, Spacing.m)
                .glassEffect(.regular.tint(.white.opacity(0.95)).interactive(), in: .capsule)
            }
        }
        .padding(Spacing.xl)
    }

    private var abonoReadyState: some View {
        VStack(spacing: Spacing.m) {
            Text("🎉")
                .font(.system(size: 56))
            Text("¡Llegaste a 15!")
                .font(.appTitle.weight(.bold))
                .foregroundStyle(.white)
            Text("1 cubeta de tierra te espera")
                .font(.appCallout)
                .foregroundStyle(.white.opacity(0.85))
            Button {
                Haptics.success()
                onPrimaryAction()
            } label: {
                HStack(spacing: Spacing.s) {
                    Image(systemName: "sparkles")
                    Text("Recibir mi abono")
                        .font(.appHeadline.weight(.semibold))
                }
                .foregroundStyle(Color.brand)
                .padding(.horizontal, Spacing.xl)
                .padding(.vertical, Spacing.m)
                .glassEffect(.regular.tint(.white.opacity(0.95)).interactive(), in: .capsule)
            }
        }
        .padding(Spacing.xl)
    }
}
