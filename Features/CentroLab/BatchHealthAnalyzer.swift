import Foundation

/// Diagnóstico generado por el "Coach IA on-device" para un lote.
/// En prod este sería Foundation Models con prompt; aquí es heurístico
/// que imita el razonamiento del agrónomo.
struct BatchDiagnostic: Hashable {
    let risk: RiskLevel
    let title: String           // "Temperatura baja para etapa activa"
    let cause: String           // "Posible falta de nitrógeno o baja aireación"
    let action: String          // "Agregar residuos verdes y voltear hoy"
    let detail: String?         // info opcional del sensor culpable
}

/// Analiza un lote y produce un diagnóstico accionable. Toma en cuenta:
/// - Temperatura vs rango ideal de la fase
/// - Humedad vs ideal (50-60%)
/// - Días desde último volteo vs máximo permitido
/// - Olor reportado
/// - Tipo de mezcla
/// - Color/tono de foto (si hay)
///
/// Prioriza el problema MÁS GRAVE para la acción. Devuelve un diagnóstico
/// con risk level + frase tipo agrónomo.
enum BatchHealthAnalyzer {

    static func diagnose(_ batch: CompostBatch) -> BatchDiagnostic {
        let phase = batch.phase

        // Recopilamos hallazgos
        var findings: [BatchDiagnostic] = []

        // 1. Temperatura
        let tempRange = phase.idealTempRange
        if batch.temperatureCelsius < tempRange.lowerBound - 5 {
            findings.append(.init(
                risk: phase == .thermophilic ? .high : .medium,
                title: "Temperatura baja",
                cause: "En fase \(phase.rawValue) deberías estar entre \(Int(tempRange.lowerBound))-\(Int(tempRange.upperBound))°C. Está a \(Int(batch.temperatureCelsius))°C.",
                action: batch.mixType == .brownHeavy
                    ? "Agregar verdes (cáscaras, café) y voltear para reactivar."
                    : "Voltear el lote para airear. Si en 24h no sube, agregar verdes.",
                detail: "Posible falta de nitrógeno o aireación."
            ))
        } else if batch.temperatureCelsius > tempRange.upperBound + 8 {
            findings.append(.init(
                risk: .high,
                title: "Temperatura excesiva",
                cause: "Está a \(Int(batch.temperatureCelsius))°C, arriba de \(Int(tempRange.upperBound))°C. Riesgo de matar microorganismos.",
                action: "Voltear inmediatamente para liberar calor. Agregar marrón si persiste.",
                detail: "Sobre 70°C los microbios benéficos mueren."
            ))
        }

        // 2. Humedad
        let humRange = phase.idealHumidityRange
        if batch.humidityPercent < humRange.lowerBound - 5 {
            findings.append(.init(
                risk: .medium,
                title: "Humedad baja",
                cause: "Está al \(Int(batch.humidityPercent))%, ideal es \(Int(humRange.lowerBound))-\(Int(humRange.upperBound))%.",
                action: "Regar ligeramente y voltear. Cubrir si está al sol directo.",
                detail: "Lote seco no descompone."
            ))
        } else if batch.humidityPercent > humRange.upperBound + 10 {
            findings.append(.init(
                risk: batch.smell == .strong ? .high : .medium,
                title: "Humedad excesiva",
                cause: "Está al \(Int(batch.humidityPercent))%. Provoca anaerobiosis y mal olor.",
                action: "Agregar marrón seco (papel, hojas) y voltear para airear.",
                detail: "Demasiada agua sofoca a las bacterias aeróbicas."
            ))
        }

        // 3. Volteo
        if batch.lastTurnDaysAgo > phase.maxTurnDays {
            findings.append(.init(
                risk: batch.lastTurnDaysAgo > phase.maxTurnDays * 2 ? .high : .medium,
                title: "Necesita volteo",
                cause: "Han pasado \(batch.lastTurnDaysAgo) días desde el último. Para fase \(phase.rawValue) recomendamos máximo \(phase.maxTurnDays) días.",
                action: "Voltear el lote hoy mismo para reactivar oxígeno.",
                detail: nil
            ))
        }

        // 4. Olor
        if batch.smell == .strong {
            findings.append(.init(
                risk: .high,
                title: "Olor fuerte detectado",
                cause: batch.humidityPercent > 65
                    ? "Probable anaerobiosis por exceso de humedad."
                    : "Probable amoniaco por exceso de nitrógeno (verdes).",
                action: batch.humidityPercent > 65
                    ? "Agregar marrón + voltear urgente."
                    : "Agregar marrón (papel, hojas) para balancear nitrógeno.",
                detail: "Composta sana huele a tierra húmeda, no a podrido."
            ))
        }

        // 5. Mezcla
        if batch.mixType == .greenHeavy && phase == .thermophilic && batch.smell != .normal {
            findings.append(.init(
                risk: .medium,
                title: "Demasiado nitrógeno",
                cause: "La mezcla es muy verde y ya estás en fase activa. Esto sobre-acelera y provoca olores.",
                action: "Mezclar con marrón seco para llevar ratio C:N a ~30:1.",
                detail: nil
            ))
        }

        // 6. Foto (si hay)
        if let tone = batch.photoTone {
            switch tone {
            case .green where phase == .thermophilic || phase == .cooling:
                findings.append(.init(
                    risk: .medium,
                    title: "Material aún muy verde",
                    cause: "Para esta fase ya debería verse café oscuro homogéneo. Tu foto muestra mucho material reciente.",
                    action: "Triturar más fino + voltear bien para acelerar descomposición.",
                    detail: nil
                ))
            case .lightDry:
                findings.append(.init(
                    risk: .medium,
                    title: "Color claro / textura seca",
                    cause: "Visualmente se ve seco. Confirma con dedos: si se desmorona sin formar bola, falta agua.",
                    action: "Regar moderadamente y voltear. Cubrir si se evapora rápido.",
                    detail: nil
                ))
            case .darkBrown where phase == .thermophilic:
                findings.append(.init(
                    risk: .low,
                    title: "Color avanzado",
                    cause: "Tu foto se ve más oscura que típico de fase activa. Posible que ya esté entrando en cooling.",
                    action: "Reducir frecuencia de volteo. Próxima medición en 5 días.",
                    detail: nil
                ))
            default:
                break
            }
        }

        // Si no hay hallazgos, todo bien
        guard let worst = findings.max(by: { $0.risk < $1.risk }) else {
            return .init(
                risk: .low,
                title: "Lote saludable",
                cause: "Temperatura, humedad, volteo y olor en rangos óptimos para fase \(phase.rawValue).",
                action: phase == .curing
                    ? "Casi listo. Voltear cada 10-15 días, próxima foto en 1 semana."
                    : "Mantén ritmo de volteo y mediciones. Próxima revisión en 3 días.",
                detail: nil
            )
        }

        return worst
    }
}
