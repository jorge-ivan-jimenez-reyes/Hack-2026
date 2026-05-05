import Foundation
import WidgetKit

/// Bridge entre el state del recolector y el widget. Escribe los datos al
/// UserDefaults compartido y refresca todas las timelines del widget.
///
/// TODO día del hack: configurar App Group para usar
/// `UserDefaults(suiteName: "group.mx.up.ioslab.hacknacional2026")`
/// y compartir datos entre app y widget extension.
enum WidgetState {
    static func sync(bucketProgress: Double, bucketsCompleted: Int, totalKgDiverted: Double) {
        let defaults = UserDefaults.standard
        defaults.set(bucketProgress, forKey: "widget.bucketProgress")
        defaults.set(bucketsCompleted, forKey: "widget.bucketsCompleted")
        defaults.set(totalKgDiverted, forKey: "widget.totalKg")
        WidgetCenter.shared.reloadAllTimelines()
    }
}
