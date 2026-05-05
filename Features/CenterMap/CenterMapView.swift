import SwiftUI
import MapKit

/// Mapa de centros de acopio con Apple Maps. Bottom sheet con la lista
/// ordenada (más cerca primero). Tap en marker → highlight en lista.
/// Tap en card de la lista → centra el mapa en ese centro.
struct CenterMapView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 19.41, longitude: -99.16),
            span: MKCoordinateSpan(latitudeDelta: 0.06, longitudeDelta: 0.06)
        )
    )
    @State private var selectedCenter: CenterLocation?
    @State private var showSheet: Bool = true

    private let centers = CenterLocation.mock

    var body: some View {
        ZStack(alignment: .top) {
            mapView
            topBar
        }
        .sheet(isPresented: $showSheet) {
            centersSheet
                .presentationDetents([.height(220), .medium, .large])
                .presentationDragIndicator(.visible)
                .presentationBackgroundInteraction(.enabled)
                .interactiveDismissDisabled()
        }
    }

    // MARK: - Map

    private var mapView: some View {
        Map(position: $cameraPosition, selection: $selectedCenter) {
            ForEach(centers) { center in
                Marker(center.name, systemImage: "leaf.fill", coordinate: center.coordinate)
                    .tint(center.acceptsAbono ? .brand : .clay)
                    .tag(center)
            }
        }
        .mapStyle(.standard(elevation: .realistic, pointsOfInterest: .excludingAll))
        .ignoresSafeArea(edges: .bottom)
    }

    // MARK: - Top bar

    private var topBar: some View {
        HStack {
            Button {
                Haptics.tap()
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.inkCharcoal)
                    .frame(width: 40, height: 40)
                    .glassEffect(.regular.tint(.cream.opacity(0.85)).interactive(), in: .circle)
            }

            Spacer()

            VStack(spacing: 0) {
                Text("Centros cercanos")
                    .font(.appHeadline.weight(.semibold))
                    .foregroundStyle(.inkCharcoal)
                Text("\(centers.count) disponibles")
                    .font(.appCaption)
                    .foregroundStyle(.inkCharcoal.opacity(0.65))
            }
            .padding(.horizontal, Spacing.l)
            .padding(.vertical, Spacing.s)
            .glassEffect(.regular.tint(.cream.opacity(0.85)), in: .capsule)

            Spacer()

            Color.clear.frame(width: 40, height: 40)
        }
        .padding(.horizontal, Spacing.l)
        .padding(.top, Spacing.s)
    }

    // MARK: - Bottom sheet

    private var centersSheet: some View {
        ScrollView {
            VStack(spacing: Spacing.s) {
                ForEach(centers) { center in
                    centerRow(center)
                }
            }
            .padding(.horizontal, Spacing.l)
            .padding(.top, Spacing.s)
            .padding(.bottom, Spacing.xl)
        }
        .background(Color.cream)
        .scrollIndicators(.hidden)
    }

    private func centerRow(_ center: CenterLocation) -> some View {
        Button {
            Haptics.tap()
            withAnimation(.smooth(duration: 0.5)) {
                selectedCenter = center
                cameraPosition = .region(
                    MKCoordinateRegion(
                        center: center.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.012, longitudeDelta: 0.012)
                    )
                )
            }
        } label: {
            HStack(spacing: Spacing.m) {
                ZStack {
                    Circle()
                        .fill((center.acceptsAbono ? Color.brand : Color.clay).opacity(0.15))
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(center.acceptsAbono ? .brand : .clay)
                }
                .frame(width: 44, height: 44)

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(center.name)
                            .font(.appBody.weight(.semibold))
                            .foregroundStyle(.inkCharcoal)
                            .lineLimit(1)
                        Spacer()
                        if center.acceptsAbono {
                            tag(text: "Abono", tint: .brand)
                        }
                    }
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption2)
                        Text(center.openHours)
                            .font(.appCaption)
                        Text("·")
                            .font(.appCaption)
                        Text(center.openDaysShort)
                            .font(.appCaption)
                    }
                    .foregroundStyle(.inkCharcoal.opacity(0.55))
                }

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.inkCharcoal.opacity(0.30))
            }
            .padding(Spacing.m)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: Radius.l)
                    .fill(.white)
                    .shadow(color: Color.inkCharcoal.opacity(0.05), radius: 6, y: 2)
            }
            .overlay {
                RoundedRectangle(cornerRadius: Radius.l)
                    .stroke(
                        selectedCenter?.id == center.id ? Color.brand.opacity(0.45) : Color.clear,
                        lineWidth: 1.5
                    )
            }
        }
        .buttonStyle(.plain)
    }

    private func tag(text: String, tint: Color) -> some View {
        Text(text)
            .font(.appCaption.weight(.semibold))
            .foregroundStyle(tint)
            .padding(.horizontal, Spacing.s)
            .padding(.vertical, 3)
            .background(tint.opacity(0.15), in: .capsule)
    }
}

#Preview {
    CenterMapView()
}
