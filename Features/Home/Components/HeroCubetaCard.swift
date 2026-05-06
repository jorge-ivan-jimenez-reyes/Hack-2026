import SwiftUI

/// Hero gigante que cambia según la etapa del recolector.
/// Es la pieza central del Home — siempre el primer foco visual.
struct HeroCubetaCard: View {
    let state: RecolectorState
    let onPrimaryAction: () -> Void
    var onTapModalityChip: (() -> Void)? = nil

    var body: some View {
        ZStack {
            backdrop

            // Family-style: cada stage se cross-fade + scale ligero al cambiar.
            // Evita el hard-cut entre filling → bucketReady → abonoReady.
            Group {
                switch state.stage {
                case .filling, .waitingPickup, .justDelivered, .onboardingPending:
                    fillingState
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .scale(scale: 0.96)),
                            removal: .opacity.combined(with: .scale(scale: 1.04))
                        ))
                case .bucketReady:
                    bucketReadyState
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.85).combined(with: .opacity),
                            removal: .opacity
                        ))
                case .abonoReady:
                    abonoReadyState
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.85).combined(with: .opacity),
                            removal: .opacity
                        ))
                }
            }
            .animation(.spring(duration: 0.55, bounce: 0.30), value: state.stage)
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 240)
        .clipShape(RoundedRectangle(cornerRadius: Radius.xl, style: .continuous))
        .padding(.horizontal, Spacing.l)
    }

    // MARK: - Backdrop
    //
    // Base en gradiente + brillo animado solo con formas **radiales** difuminadas
    // (sin LinearGradient rotado ni .screen sobre rectángulos — eso marcaba “cuadrados”).
    // TimelineView ~10 fps, acotado al tamaño real de la card.

    private var backdrop: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            ZStack {
                LinearGradient(
                    stops: [
                        .init(color: .forestDeep, location: 0),
                        .init(color: .brand, location: 0.38),
                        .init(color: .moss, location: 0.78),
                        .init(color: .forestDeep.opacity(0.92), location: 1)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                TimelineView(.animation(minimumInterval: 0.1, paused: false)) { context in
                    let t = context.date.timeIntervalSince1970
                    let driftX = CGFloat(sin(t * 0.42)) * (w * 0.07)
                    let driftY = CGFloat(cos(t * 0.35)) * (h * 0.06)
                    let drift2 = CGFloat(sin(t * 0.31 + 1.2)) * (w * 0.05)

                    ZStack {
                        softGlowBlob(
                            colors: [.white.opacity(0.22), .white.opacity(0.06), .clear],
                            size: max(w, h) * 0.95,
                            blur: 38,
                            x: w * 0.78 + driftX,
                            y: h * 0.22 + driftY
                        )
                        softGlowBlob(
                            colors: [.limeSpark.opacity(0.28), .limeSpark.opacity(0.08), .clear],
                            size: max(w, h) * 0.75,
                            blur: 44,
                            x: w * 0.18 - driftX * 0.6,
                            y: h * 0.72 - driftY
                        )
                        softGlowBlob(
                            colors: [.brand.opacity(0.35), .clear],
                            size: max(w, h) * 0.55,
                            blur: 32,
                            x: w * 0.52 + drift2,
                            y: h * 0.48 + driftY * 0.4
                        )
                    }
                    .frame(width: w, height: h)
                    .compositingGroup()
                    .blendMode(.plusLighter)
                    .opacity(0.85)
                }
            }
        }
    }

    private func softGlowBlob(
        colors: [Color],
        size: CGFloat,
        blur: CGFloat,
        x: CGFloat,
        y: CGFloat
    ) -> some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: colors,
                    center: .center,
                    startRadius: 0,
                    endRadius: size * 0.52
                )
            )
            .frame(width: size, height: size)
            .blur(radius: blur)
            .position(x: x, y: y)
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
                LottiePlayer(name: "loading-leaf", fallbackSymbol: "leaf.fill")
                    .frame(width: 92, height: 92)
                    .shadow(color: .black.opacity(0.18), radius: 6, y: 3)
            }

            ProgressView(value: state.currentBucketProgress)
                .tint(.white)
                .scaleEffect(y: 1.6)
                .background(.white.opacity(0.18), in: .capsule)
                .animation(.smooth(duration: 0.6), value: state.currentBucketProgress)

            modalityChip
        }
        .padding(Spacing.xl)
    }

    /// Chip que cambia según la modalidad del usuario:
    /// - .pickup → "Pickup mié 6:00am" (tu cubeta llega a domicilio)
    /// - .dropOff → "Composta Roma Norte abre mañana 8am · 0.4 km" (tappable → mapa)
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
                Button {
                    Haptics.tap()
                    onTapModalityChip?()
                } label: {
                    chip(
                        icon: "mappin.circle.fill",
                        text: "\(center.name) · \(formattedDistance(center.distanceKm))"
                    )
                }
                .buttonStyle(.plain)
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
