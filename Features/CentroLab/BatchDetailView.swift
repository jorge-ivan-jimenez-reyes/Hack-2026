import SwiftUI

/// Detalle de un lote con todos los gauges + AI diagnostic + acciones.
/// Es el centro de la experiencia "Health Monitor" del centro.
struct BatchDetailView: View {
    let batch: CompostBatch

    @Environment(\.dismiss) private var dismiss

    private var diagnostic: BatchDiagnostic {
        BatchHealthAnalyzer.diagnose(batch)
    }

    var body: some View {
        ZStack {
            Color.cream.ignoresSafeArea()

            ScrollView {
                VStack(spacing: Spacing.l) {
                    header
                    aiDiagnosticCard
                    gaugesSection
                    photoSection
                    actionsSection
                    Color.clear.frame(height: 40)
                }
                .padding(.vertical, Spacing.s)
            }
            .scrollIndicators(.hidden)
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(batch.name)
                    .font(.appLargeTitle)
                    .foregroundStyle(.inkCharcoal)
                HStack(spacing: 6) {
                    Image(systemName: "clock")
                        .font(.caption)
                    Text("\(batch.daysInProcess) días en proceso")
                        .font(.appCallout)
                    Text("·")
                    Text("Fase \(batch.phase.rawValue)")
                        .font(.appCallout.weight(.semibold))
                        .foregroundStyle(.brand)
                }
                .foregroundStyle(.inkCharcoal.opacity(0.65))
            }
            Spacer()
        }
        .padding(.horizontal, Spacing.l)
        .padding(.top, Spacing.s)
    }

    // MARK: - AI Diagnostic Card

    private var aiDiagnosticCard: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            HStack(spacing: Spacing.s) {
                Image(systemName: "sparkles")
                    .font(.headline)
                    .foregroundStyle(diagnostic.risk.tint)
                    .symbolEffect(.variableColor.iterative.reversing, options: .repeat(.continuous))
                Text("Coach IA")
                    .font(.appHeadline.weight(.semibold))
                    .foregroundStyle(.inkCharcoal)
                Spacer()
                Text("on-device")
                    .font(.appCaption.weight(.medium))
                    .foregroundStyle(.inkCharcoal.opacity(0.55))
                    .padding(.horizontal, Spacing.s)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial, in: .capsule)
            }

            // Risk badge
            HStack(spacing: 6) {
                Image(systemName: diagnostic.risk.symbol)
                    .font(.body.weight(.bold))
                Text("Riesgo \(diagnostic.risk.rawValue)")
                    .font(.appBody.weight(.bold))
            }
            .foregroundStyle(diagnostic.risk.tint)
            .padding(.horizontal, Spacing.m)
            .padding(.vertical, 6)
            .background(diagnostic.risk.tint.opacity(0.15), in: .capsule)

            // Title
            Text(diagnostic.title)
                .font(.appTitle2.weight(.bold))
                .foregroundStyle(.inkCharcoal)

            // Cause
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "magnifyingglass.circle.fill")
                        .foregroundStyle(.inkCharcoal.opacity(0.55))
                    Text("Análisis")
                        .font(.appCallout.weight(.semibold))
                        .foregroundStyle(.inkCharcoal.opacity(0.55))
                }
                Text(diagnostic.cause)
                    .font(.appBody)
                    .foregroundStyle(.inkCharcoal)
                    .fixedSize(horizontal: false, vertical: true)
            }

            // Action
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "checklist")
                        .foregroundStyle(diagnostic.risk.tint)
                    Text("Acción recomendada")
                        .font(.appCallout.weight(.semibold))
                        .foregroundStyle(diagnostic.risk.tint)
                }
                Text(diagnostic.action)
                    .font(.appBody.weight(.medium))
                    .foregroundStyle(.inkCharcoal)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if let detail = diagnostic.detail {
                HStack(alignment: .top, spacing: 4) {
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(.inkCharcoal.opacity(0.45))
                    Text(detail)
                        .font(.appCaption)
                        .foregroundStyle(.inkCharcoal.opacity(0.65))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(Spacing.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: Radius.l)
                .fill(.white)
                .shadow(color: diagnostic.risk.tint.opacity(0.18), radius: 18, y: 6)
        }
        .overlay {
            RoundedRectangle(cornerRadius: Radius.l)
                .stroke(diagnostic.risk.tint.opacity(0.25), lineWidth: 1.5)
        }
        .padding(.horizontal, Spacing.l)
    }

    // MARK: - Gauges

    private var gaugesSection: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            Text("Lecturas actuales")
                .font(.appHeadline.weight(.semibold))
                .foregroundStyle(.inkCharcoal)
                .padding(.horizontal, Spacing.l)

            HStack(spacing: Spacing.m) {
                gauge(
                    icon: "thermometer",
                    label: "Temp.",
                    value: "\(Int(batch.temperatureCelsius))",
                    unit: "°C",
                    progress: min(batch.temperatureCelsius / 80, 1),
                    inRange: batch.phase.idealTempRange.contains(batch.temperatureCelsius),
                    rangeText: "Ideal \(Int(batch.phase.idealTempRange.lowerBound))-\(Int(batch.phase.idealTempRange.upperBound))°C"
                )
                gauge(
                    icon: "humidity.fill",
                    label: "Humedad",
                    value: "\(Int(batch.humidityPercent))",
                    unit: "%",
                    progress: batch.humidityPercent / 100,
                    inRange: batch.phase.idealHumidityRange.contains(batch.humidityPercent),
                    rangeText: "Ideal 50-60%"
                )
            }
            .padding(.horizontal, Spacing.l)

            HStack(spacing: Spacing.m) {
                infoBlock(icon: "arrow.triangle.2.circlepath", label: "Volteo", value: "Hace \(batch.lastTurnDaysAgo)d", note: "Max \(batch.phase.maxTurnDays)d")
                infoBlock(icon: batch.smell.symbol, label: "Olor", value: batch.smell.rawValue, note: batch.smell == .normal ? "Saludable" : "Revisar")
                infoBlock(icon: batch.mixType.symbol, label: "Mezcla", value: batch.mixType.rawValue, note: nil)
            }
            .padding(.horizontal, Spacing.l)
        }
    }

    private func gauge(icon: String, label: String, value: String, unit: String, progress: Double, inRange: Bool, rangeText: String) -> some View {
        let tint: Color = inRange ? .brand : .warning
        return VStack(alignment: .leading, spacing: Spacing.s) {
            HStack(spacing: 4) {
                Image(systemName: icon).font(.callout)
                    .foregroundStyle(tint)
                Text(label).font(.appCaption.weight(.semibold))
                    .foregroundStyle(.inkCharcoal.opacity(0.65))
                Spacer()
            }
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.inkCharcoal)
                    .contentTransition(.numericText())
                Text(unit)
                    .font(.appCallout)
                    .foregroundStyle(.inkCharcoal.opacity(0.55))
            }
            ProgressView(value: progress)
                .tint(tint)
            Text(rangeText)
                .font(.appCaption)
                .foregroundStyle(.inkCharcoal.opacity(0.55))
        }
        .padding(Spacing.m)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: Radius.l)
                .fill(.white)
                .shadow(color: Color.inkCharcoal.opacity(0.04), radius: 6, y: 2)
        }
    }

    private func infoBlock(icon: String, label: String, value: String, note: String?) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Image(systemName: icon).font(.callout).foregroundStyle(.brand)
            Text(label).font(.appCaption.weight(.semibold)).foregroundStyle(.inkCharcoal.opacity(0.65))
            Text(value).font(.appCallout.weight(.semibold)).foregroundStyle(.inkCharcoal)
            if let note = note {
                Text(note).font(.appCaption).foregroundStyle(.inkCharcoal.opacity(0.55))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.m)
        .background {
            RoundedRectangle(cornerRadius: Radius.l)
                .fill(.white)
                .shadow(color: Color.inkCharcoal.opacity(0.04), radius: 6, y: 2)
        }
    }

    // MARK: - Photo

    private var photoSection: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            HStack {
                Text("Foto del lote")
                    .font(.appHeadline.weight(.semibold))
                    .foregroundStyle(.inkCharcoal)
                Spacer()
                if let agoDays = batch.photoCapturedAgo {
                    Text(agoDays == 0 ? "Hoy" : "Hace \(agoDays)d")
                        .font(.appCaption)
                        .foregroundStyle(.inkCharcoal.opacity(0.55))
                }
            }
            .padding(.horizontal, Spacing.l)

            if let tone = batch.photoTone {
                photoCard(tone: tone)
            } else {
                noPhotoCard
            }
        }
    }

    private func photoCard(tone: PhotoTone) -> some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            // Mock photo (rectangle con tono del análisis)
            RoundedRectangle(cornerRadius: Radius.m)
                .fill(photoTint(for: tone))
                .frame(height: 140)
                .overlay {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(.white.opacity(0.65))
                }

            HStack(spacing: 4) {
                Image(systemName: "eye.fill").font(.caption)
                    .foregroundStyle(.brand)
                Text("Análisis visual:")
                    .font(.appCallout.weight(.semibold))
                    .foregroundStyle(.inkCharcoal)
                Text(tone.rawValue)
                    .font(.appCallout)
                    .foregroundStyle(.inkCharcoal.opacity(0.65))
            }
            Text(tone.interpretation)
                .font(.appCaption)
                .foregroundStyle(.inkCharcoal.opacity(0.65))
        }
        .padding(Spacing.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: Radius.l)
                .fill(.white)
                .shadow(color: Color.inkCharcoal.opacity(0.05), radius: 6, y: 2)
        }
        .padding(.horizontal, Spacing.l)
    }

    private var noPhotoCard: some View {
        VStack(spacing: Spacing.s) {
            Image(systemName: "camera.fill")
                .font(.system(size: 32))
                .foregroundStyle(.inkCharcoal.opacity(0.35))
            Text("Sin foto reciente")
                .font(.appBody)
                .foregroundStyle(.inkCharcoal.opacity(0.65))
            Text("Sube una foto para análisis visual del color y textura — la AI usa esto para refinar el diagnóstico.")
                .font(.appCaption)
                .foregroundStyle(.inkCharcoal.opacity(0.55))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(Spacing.l)
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: Radius.l)
                .fill(.white)
                .shadow(color: Color.inkCharcoal.opacity(0.04), radius: 6, y: 2)
        }
        .padding(.horizontal, Spacing.l)
    }

    private func photoTint(for tone: PhotoTone) -> Color {
        switch tone {
        case .darkBrown: return Color(red: 0.35, green: 0.22, blue: 0.10)
        case .green:     return Color(red: 0.30, green: 0.55, blue: 0.30)
        case .lightDry:  return Color(red: 0.78, green: 0.70, blue: 0.55)
        case .mixed:     return Color(red: 0.40, green: 0.32, blue: 0.20)
        }
    }

    // MARK: - Actions

    private var actionsSection: some View {
        VStack(spacing: Spacing.s) {
            actionButton(label: "Tomar foto del lote", icon: "camera.fill", tint: .brand) {
                Haptics.tap()
            }
            actionButton(label: "Marcar como volteado", icon: "arrow.triangle.2.circlepath", tint: .info) {
                Haptics.success()
            }
            actionButton(label: "Actualizar lecturas", icon: "thermometer.sun.fill", tint: .clay) {
                Haptics.tap()
            }
        }
        .padding(.horizontal, Spacing.l)
    }

    private func actionButton(label: String, icon: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: Spacing.s) {
                Image(systemName: icon).font(.body.weight(.semibold))
                Text(label).font(.appBody.weight(.semibold))
                Spacer()
                Image(systemName: "chevron.right").font(.caption.weight(.semibold)).foregroundStyle(.inkCharcoal.opacity(0.30))
            }
            .foregroundStyle(.inkCharcoal)
            .padding(Spacing.m)
            .background {
                RoundedRectangle(cornerRadius: Radius.l)
                    .fill(.white)
                    .shadow(color: tint.opacity(0.10), radius: 6, y: 2)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    BatchDetailView(batch: CompostBatch.mock[2])
}
