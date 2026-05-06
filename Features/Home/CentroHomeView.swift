import SwiftUI

/// Dashboard del Centro de acopio. Mockup demoable — reemplaza la libreta de
/// papel con stats del día, lista de quién toca abono, ruta del día y reportes.
/// En prod estos datos vendrán de SwiftData / backend; aquí están hardcoded
/// para demo.
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
            .background(Color.cream)
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
                    colors: [.brand, .moss, .clay],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
            .clipShape(RoundedRectangle(cornerRadius: Radius.l))
            .shadow(color: Color.brand.opacity(0.30), radius: 18, y: 6)
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
                .foregroundStyle(.brand)
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
                    tint: .brand
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
                    tint: .moss
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

    private var abonoQueueCard: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .foregroundStyle(.brand)
                        .symbolEffect(.variableColor.iterative.reversing, options: .repeat(.continuous))
                    Text("Toca dar abono")
                        .font(.appHeadline.weight(.semibold))
                        .foregroundStyle(.inkCharcoal)
                }
                Spacer()
                Text("3 listos")
                    .font(.appCaption.weight(.semibold))
                    .foregroundStyle(.brand)
                    .padding(.horizontal, Spacing.s)
                    .padding(.vertical, 4)
                    .background(.brand.opacity(0.15), in: .capsule)
            }

            VStack(spacing: 8) {
                abonoQueueRow(name: "Jorge J.", progress: 15, total: 15, ready: true)
                abonoQueueRow(name: "Ana M.", progress: 14, total: 15, ready: false)
                abonoQueueRow(name: "Carlos R.", progress: 12, total: 15, ready: false)
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

    private func abonoQueueRow(name: String, progress: Int, total: Int, ready: Bool) -> some View {
        HStack {
            Text(name)
                .font(.appBody)
                .foregroundStyle(.inkCharcoal)
            Spacer()
            Text("\(progress)/\(total)")
                .font(.appCaption.weight(.semibold))
                .foregroundStyle(.inkCharcoal.opacity(0.55))
            if ready {
                Text("✨ Dar abono")
                    .font(.appCaption.weight(.semibold))
                    .foregroundStyle(.brand)
                    .padding(.horizontal, Spacing.s)
                    .padding(.vertical, 4)
                    .background(.brand.opacity(0.15), in: .capsule)
            }
        }
        .padding(.vertical, 4)
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
                .tint(.brand)

            HStack(spacing: 6) {
                Image(systemName: "clock.fill")
                    .font(.caption2)
                    .foregroundStyle(.brand)
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
                .regular.tint(Color.brand.opacity(0.92)).interactive(),
                in: .capsule
            )
            .shadow(color: Color.brand.opacity(0.30), radius: 16, y: 6)
        }
        .accessibilityLabel("Registrar entrada de cubeta vía QR")
    }
}

#Preview {
    CentroHomeView()
}
