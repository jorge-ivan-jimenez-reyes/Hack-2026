import SwiftUI

/// Dashboard del Centro de acopio. Mockup demoable — reemplaza la libreta de
/// papel con stats del día, lista de quién toca abono, ruta del día y reportes.
/// En prod estos datos vendrán de SwiftData / backend; aquí están hardcoded
/// para demo.
struct CentroHomeView: View {
    @AppStorage("centro.name") private var centroName = "Centro Roma Norte"

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack(spacing: Spacing.l) {
                    header
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
    }

    // MARK: - Sections

    private var header: some View {
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
            Text("Hoy")
                .font(.appHeadline.weight(.semibold))
                .foregroundStyle(.inkCharcoal)

            HStack(spacing: Spacing.l) {
                statBlock(value: "47", unit: "cubetas", icon: "circle.grid.3x3.fill", tint: .brand)
                statBlock(value: "312", unit: "kg", icon: "scalemass.fill", tint: .clay)
                statBlock(value: "8", unit: "recolectores", icon: "person.3.fill", tint: .moss)
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

    private func statBlock(value: String, unit: String, icon: String, tint: Color) -> some View {
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
                .font(.appCaption)
                .foregroundStyle(.inkCharcoal.opacity(0.55))
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
                    Text("Ruta de hoy")
                        .font(.appHeadline.weight(.semibold))
                        .foregroundStyle(.inkCharcoal)
                }
                Spacer()
                Text("60%")
                    .font(.appCaption.weight(.semibold))
                    .foregroundStyle(.inkCharcoal.opacity(0.55))
            }

            HStack(alignment: .firstTextBaseline) {
                Text("Roma · Condesa")
                    .font(.appBody)
                    .foregroundStyle(.inkCharcoal)
                Spacer()
                Text("23 paradas")
                    .font(.appCaption)
                    .foregroundStyle(.inkCharcoal.opacity(0.55))
            }

            ProgressView(value: 0.60)
                .tint(.brand)

            Text("Próxima parada: Calle Tabasco 124 — 8:30 am")
                .font(.appCaption)
                .foregroundStyle(.inkCharcoal.opacity(0.55))
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
