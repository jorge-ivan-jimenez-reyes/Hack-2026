import SwiftUI

/// Dashboard del Centro de acopio. Mockup demoable — reemplaza la libreta de
/// papel con stats del día, lista de quién toca abono, ruta del día y reportes.
/// En prod estos datos vendrán de SwiftData / backend; aquí están hardcoded
/// para demo.
///
/// Fondo `centroSurface` (mint sage) + acentos `forestDeep`/`clay`/`warning`
/// para diferenciar visualmente del recolector (cream + brand).
struct CentroHomeView: View {
    @AppStorage("centro.name") private var centroName = "Centro Roma Norte"

    @State private var showWrapped = false
    @State private var showSettings = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack(spacing: Spacing.l) {
                    header
                    wrappedTeaserCard
                    statsCard
                    abonoQueueCard
                    rutaCard
                    reportesCard
                    Color.clear.frame(height: 100)
                }
                .padding(.vertical, Spacing.s)
            }
            .background(Color.centroSurface)
            .scrollIndicators(.hidden)

            scanFAB
                .padding(.trailing, Spacing.l)
                .padding(.bottom, Spacing.l)
        }
        .fullScreenCover(isPresented: $showWrapped) {
            WrappedView(data: .mock)
        }
        .sheet(isPresented: $showSettings) {
            CentroSettingsView()
        }
    }

    /// Card prominente que invita a ver el wrapped del mes.
    private var wrappedTeaserCard: some View {
        Button {
            Haptics.confirm()
            showWrapped = true
        } label: {
            HStack(spacing: Spacing.m) {
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.20))
                    Image(systemName: "sparkles")
                        .font(.title2)
                        .foregroundStyle(.white)
                        .symbolEffect(.variableColor.iterative.reversing, options: .repeat(.continuous))
                }
                .frame(width: 52, height: 52)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Tu mes en composta")
                        .font(.appHeadline.weight(.bold))
                        .foregroundStyle(.white)
                    Text("Mayo 2026 · Mira tu impacto")
                        .font(.appCaption)
                        .foregroundStyle(.white.opacity(0.85))
                }

                Spacer()

                Image(systemName: "play.fill")
                    .font(.title3)
                    .foregroundStyle(.white)
            }
            .padding(Spacing.l)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                LinearGradient(
                    colors: [.forestDeep, .clay, .warning],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
            .clipShape(RoundedRectangle(cornerRadius: Radius.l))
            .shadow(color: Color.forestDeep.opacity(0.30), radius: 18, y: 6)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, Spacing.l)
    }

    // MARK: - Sections

    private var header: some View {
        Button {
            Haptics.tap()
            showSettings = true
        } label: {
            headerContent
        }
        .buttonStyle(.plain)
    }

    private var headerContent: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text(centroName.isEmpty ? "Centro de acopio" : centroName)
                    .font(.appTitle2)
                    .foregroundStyle(.inkCharcoal)
                HStack(spacing: 4) {
                    Image(systemName: "person.fill")
                        .font(.caption)
                    Text("Operador: María")
                        .font(.appCallout)
                }
                .foregroundStyle(.inkCharcoal.opacity(0.65))
            }
            Spacer()
            Image(systemName: "leaf.circle.fill")
                .font(.system(size: 32))
                .foregroundStyle(.forestDeep)
        }
        .padding(.horizontal, Spacing.l)
        .padding(.top, Spacing.s)
    }

    private var statsCard: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            HStack(alignment: .firstTextBaseline) {
                Text("Recibido hoy")
                    .font(.appHeadline.weight(.semibold))
                    .foregroundStyle(.inkCharcoal)
                Spacer()
                Text("Lun · 5 may")
                    .font(.appCaption)
                    .foregroundStyle(.inkCharcoal.opacity(0.55))
            }

            HStack(spacing: Spacing.l) {
                statBlock(
                    value: "47",
                    unit: "cubetas",
                    detail: "ingresadas hoy",
                    icon: "circle.grid.3x3.fill",
                    tint: .forestDeep
                )
                statBlock(
                    value: "312",
                    unit: "kg orgánico",
                    detail: "≈ 6.6 kg/cubeta",
                    icon: "scalemass.fill",
                    tint: .clay
                )
                statBlock(
                    value: "8",
                    unit: "recolectores",
                    detail: "activos hoy",
                    icon: "person.3.fill",
                    tint: .warning
                )
            }
        }
        .padding(Spacing.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: Radius.l)
                .fill(.white)
                .shadow(color: Color.inkCharcoal.opacity(0.06), radius: 10, y: 4)
        }
        .padding(.horizontal, Spacing.l)
    }

    private func statBlock(value: String, unit: String, detail: String, icon: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Image(systemName: icon)
                .font(.callout)
                .foregroundStyle(tint)
                .frame(width: 28, height: 28)
                .background(tint.opacity(0.15), in: .circle)
            Text(value)
                .font(.appTitle2.weight(.bold))
                .foregroundStyle(.inkCharcoal)
                .contentTransition(.numericText())
            Text(unit)
                .font(.appCaption.weight(.medium))
                .foregroundStyle(.inkCharcoal.opacity(0.75))
                .lineLimit(1)
                .minimumScaleFactor(0.85)
            Text(detail)
                .font(.appCaption)
                .foregroundStyle(tint.opacity(0.85))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// Datos mock de los usuarios y su progreso de cubetas (X / 15).
    /// En prod vendrán de SwiftData/backend filtrados por centro asignado.
    private let usuariosCubetas: [(name: String, progress: Int)] = [
        ("Jorge J.",    15),
        ("Ana M.",      14),
        ("Carlos R.",   12),
        ("Lucía P.",    11),
        ("Diego H.",     9),
        ("Sofía V.",     7),
        ("Mateo G.",     4),
        ("Paula T.",     2),
    ]

    private var totalCubetasUsuarios: Int { usuariosCubetas.reduce(0) { $0 + $1.progress } }
    private var promedioPct: Int {
        guard !usuariosCubetas.isEmpty else { return 0 }
        let sumPct = usuariosCubetas.reduce(0.0) { $0 + Double($1.progress) / 15.0 }
        return Int((sumPct / Double(usuariosCubetas.count)) * 100)
    }
    private var listosCount: Int { usuariosCubetas.filter { $0.progress >= 15 }.count }

    private var abonoQueueCard: some View {
        VStack(alignment: .leading, spacing: Spacing.l) {
            // Header
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "chart.bar.xaxis")
                        .foregroundStyle(.forestDeep)
                    Text("Progreso de cubetas")
                        .font(.appHeadline.weight(.semibold))
                        .foregroundStyle(.inkCharcoal)
                }
                Spacer()
                Text("\(usuariosCubetas.count) usuarios")
                    .font(.appCaption)
                    .foregroundStyle(.inkCharcoal.opacity(0.55))
            }

            // HERO: ring con promedio + mini stats al lado
            heroSection

            Divider()

            // Lista de usuarios — cada fila ES la barra de progreso
            VStack(spacing: Spacing.s) {
                ForEach(Array(usuariosCubetas.enumerated()), id: \.offset) { _, u in
                    abonoQueueRow(name: u.name, progress: u.progress, total: 15)
                }
            }
        }
        .padding(Spacing.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: Radius.l)
                .fill(.white)
                .shadow(color: Color.inkCharcoal.opacity(0.06), radius: 10, y: 4)
        }
        .padding(.horizontal, Spacing.l)
    }

    /// Sección hero: ring circular con avg % + dos mini stats a la derecha.
    private var heroSection: some View {
        HStack(spacing: Spacing.l) {
            // Ring de promedio
            ZStack {
                Circle()
                    .stroke(Color.forestDeep.opacity(0.12), lineWidth: 8)
                Circle()
                    .trim(from: 0, to: Double(promedioPct) / 100)
                    .stroke(
                        LinearGradient(
                            colors: [.forestDeep, .brand, .warning],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                VStack(spacing: 0) {
                    Text("\(promedioPct)%")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(.inkCharcoal)
                        .contentTransition(.numericText())
                    Text("avg")
                        .font(.system(.caption2))
                        .foregroundStyle(.inkCharcoal.opacity(0.55))
                }
            }
            .frame(width: 88, height: 88)

            // Mini stats verticales
            VStack(alignment: .leading, spacing: Spacing.s) {
                heroMiniStat(
                    icon: "checkmark.seal.fill",
                    value: "\(listosCount)",
                    label: "listos para abono",
                    tint: .brand
                )
                heroMiniStat(
                    icon: "circle.grid.3x3.fill",
                    value: "\(totalCubetasUsuarios)",
                    label: "cubetas en sistema",
                    tint: .clay
                )
            }
            Spacer(minLength: 0)
        }
    }

    private func heroMiniStat(icon: String, value: String, label: String, tint: Color) -> some View {
        HStack(spacing: Spacing.s) {
            Image(systemName: icon)
                .font(.callout)
                .foregroundStyle(tint)
                .frame(width: 28, height: 28)
                .background(tint.opacity(0.15), in: .circle)
            VStack(alignment: .leading, spacing: 0) {
                Text(value)
                    .font(.appHeadline.weight(.bold))
                    .foregroundStyle(.inkCharcoal)
                    .contentTransition(.numericText())
                Text(label)
                    .font(.appCaption)
                    .foregroundStyle(.inkCharcoal.opacity(0.60))
            }
        }
    }

    /// Fila de usuario al estilo Spotify Wrapped: la fila completa ES la barra
    /// de progreso (con fill tintado), y encima va el avatar + nombre + %.
    private func abonoQueueRow(name: String, progress: Int, total: Int) -> some View {
        let ratio = Double(progress) / Double(total)
        let pct = Int(ratio * 100)
        let ready = progress >= total
        let near = !ready && progress >= 13
        let tint: Color = ready ? .brand : (near ? .forestDeep : (ratio >= 0.5 ? .clay : .warning))

        return GeometryReader { geo in
            ZStack(alignment: .leading) {
                // Track
                RoundedRectangle(cornerRadius: Radius.m)
                    .fill(tint.opacity(0.10))

                // Fill (gradient sutil)
                RoundedRectangle(cornerRadius: Radius.m)
                    .fill(
                        LinearGradient(
                            colors: [tint.opacity(0.30), tint.opacity(0.18)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(geo.size.width * ratio, 44))

                // Contenido encima
                HStack(spacing: Spacing.s) {
                    // Avatar con iniciales
                    avatarCircle(name: name, tint: tint)

                    // Nombre + estado
                    VStack(alignment: .leading, spacing: 0) {
                        Text(name)
                            .font(.appBody.weight(.semibold))
                            .foregroundStyle(.inkCharcoal)
                        Text("\(progress) de \(total) cubetas")
                            .font(.appCaption)
                            .foregroundStyle(.inkCharcoal.opacity(0.60))
                    }

                    Spacer(minLength: Spacing.s)

                    // Badge de estado o pct
                    if ready {
                        statusPill(text: "✨ Dar abono", tint: .brand)
                    } else if near {
                        statusPill(text: "🔥 Cerca", tint: .forestDeep)
                    }

                    Text("\(pct)%")
                        .font(.appHeadline.weight(.bold))
                        .foregroundStyle(tint)
                        .monospacedDigit()
                }
                .padding(.horizontal, Spacing.s)
            }
        }
        .frame(height: 56)
    }

    private func avatarCircle(name: String, tint: Color) -> some View {
        let initials = name
            .split(separator: " ")
            .compactMap { $0.first }
            .prefix(2)
            .map(String.init)
            .joined()

        return ZStack {
            Circle()
                .fill(tint.opacity(0.85))
            Text(initials)
                .font(.appCaption.weight(.bold))
                .foregroundStyle(.cream)
        }
        .frame(width: 36, height: 36)
        .overlay {
            Circle().stroke(Color.white, lineWidth: 2)
        }
    }

    private func statusPill(text: String, tint: Color) -> some View {
        Text(text)
            .font(.system(.caption2, weight: .semibold))
            .foregroundStyle(tint)
            .padding(.horizontal, Spacing.s)
            .padding(.vertical, 3)
            .background {
                Capsule().fill(.white)
            }
            .overlay {
                Capsule().stroke(tint.opacity(0.30), lineWidth: 1)
            }
    }

    private var rutaCard: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "shippingbox.fill")
                        .foregroundStyle(.clay)
                    Text("Entregas de hoy")
                        .font(.appHeadline.weight(.semibold))
                        .foregroundStyle(.inkCharcoal)
                }
                Spacer()
                Text("14 / 23")
                    .font(.appCaption.weight(.semibold))
                    .foregroundStyle(.inkCharcoal.opacity(0.55))
            }

            HStack(alignment: .firstTextBaseline) {
                Text("Roma · Condesa")
                    .font(.appBody)
                    .foregroundStyle(.inkCharcoal)
                Spacer()
                Text("9 recolectores en ruta")
                    .font(.appCaption)
                    .foregroundStyle(.inkCharcoal.opacity(0.55))
            }

            ProgressView(value: 14.0 / 23.0)
                .tint(.forestDeep)

            HStack(spacing: 6) {
                Image(systemName: "clock.fill")
                    .font(.caption2)
                    .foregroundStyle(.forestDeep)
                Text("Próxima llegada: Carlos M. · 8:30 am · 12 cubetas")
                    .font(.appCaption)
                    .foregroundStyle(.inkCharcoal.opacity(0.65))
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
        }
        .padding(Spacing.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: Radius.l)
                .fill(.white)
                .shadow(color: Color.inkCharcoal.opacity(0.06), radius: 10, y: 4)
        }
        .padding(.horizontal, Spacing.l)
    }

    private var reportesCard: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.warning)
                    Text("Reportes ciudadanos")
                        .font(.appHeadline.weight(.semibold))
                        .foregroundStyle(.inkCharcoal)
                }
                Spacer()
                Text("3")
                    .font(.appCaption.weight(.semibold))
                    .foregroundStyle(.warning)
                    .padding(.horizontal, Spacing.s)
                    .padding(.vertical, 4)
                    .background(.warning.opacity(0.15), in: .capsule)
            }

            VStack(alignment: .leading, spacing: 8) {
                reporteRow(text: "Cubeta dañada", location: "Roma 124")
                reporteRow(text: "Olor inusual", location: "Condesa 88")
                reporteRow(text: "No pasaron", location: "Hipódromo 14")
            }
        }
        .padding(Spacing.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: Radius.l)
                .fill(.white)
                .shadow(color: Color.inkCharcoal.opacity(0.06), radius: 10, y: 4)
        }
        .padding(.horizontal, Spacing.l)
    }

    private func reporteRow(text: String, location: String) -> some View {
        HStack {
            Image(systemName: "circle.fill")
                .font(.system(size: 6))
                .foregroundStyle(.warning)
            Text(text)
                .font(.appBody)
                .foregroundStyle(.inkCharcoal)
            Spacer()
            Text(location)
                .font(.appCaption)
                .foregroundStyle(.inkCharcoal.opacity(0.55))
        }
    }

    private var scanFAB: some View {
        Button {
            Haptics.confirm()
        } label: {
            HStack(spacing: Spacing.s) {
                Image(systemName: "qrcode.viewfinder")
                    .font(.title3.weight(.semibold))
                Text("Registrar cubeta")
                    .font(.appHeadline.weight(.semibold))
            }
            .foregroundStyle(.cream)
            .padding(.horizontal, Spacing.l)
            .padding(.vertical, Spacing.m)
            .glassEffect(
                .regular.tint(Color.forestDeep.opacity(0.92)).interactive(),
                in: .capsule
            )
            .shadow(color: Color.forestDeep.opacity(0.30), radius: 16, y: 6)
        }
        .accessibilityLabel("Registrar entrada de cubeta vía QR")
    }
}

#Preview {
    CentroHomeView()
}
