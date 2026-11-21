import SwiftUI
import UIKit

struct HomeView: View {
    private let modules: [(title: String, icon: String, color: Color)] = [
        ("VoiceOver", "speaker.wave.2.fill", .blue),
        ("Dynamic Type", "textformat.size", .blue),
        ("Contraste", "circle.lefthalf.filled", .orange),
        ("Accesibilidad Motora", "figure.stand", .yellow),
        ("Accesibilidad Auditiva", "ear", .purple),
        ("Configuración", "gearshape.fill", .gray)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(modules, id: \.title) { item in
                    NavigationLink(destination: destination(for: item.title)) {
                        HStack(spacing: 14) {
                            Image(systemName: item.icon)
                                .foregroundColor(item.color)
                                .frame(width: 28)
                            Text(item.title).font(.headline)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .accessibilityHidden(true)
                        }
                        .padding(.horizontal, 18)
                        .frame(maxWidth: .infinity, minHeight: 64)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(16)
                        .foregroundColor(.primary)
                    }
                    .accessibilityHint("Abre la demostración")
                }
            }
            .padding()
        }
        .navigationTitle("Accesibilidad iOS")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func destination(for title: String) -> some View {
        switch title {
        case "VoiceOver": VoiceOverView()
        case "Dynamic Type": DynamicTypeView()
        case "Contraste": ContrastView()
        case "Accesibilidad Motora": MotorView()
        case "Accesibilidad Auditiva": HearingView()
        default: SettingsView()
        }
    }
}

struct VoiceOverView: View {
    @State private var demoActive = false
    @State private var demoIndex = 0
    @State private var showingInfo = false
    private let labels = ["Título", "Descripción", "Manzana", "Iniciar demostración", "Más información"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                DemoCard(
                    title: "¿Qué es VoiceOver?",
                    text: "Es un lector de pantalla basado en gestos que permite usar el dispositivo sin ver la pantalla."
                )

                Button {
                    UIAccessibility.post(notification: .announcement,
                                         argument: "Manzana. Elemento accesible. Toca dos veces para interactuar.")
                } label: {
                    Label("Manzana (Elemento accesible)", systemImage: "applelogo")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.blue, lineWidth: 2))
                .accessibilityLabel("Manzana")
                .accessibilityHint("Elemento de imagen. Toca dos veces para interactuar")

                Button(demoActive ? "Detener demostración" : "Iniciar demostración") {
                    demoActive.toggle()
                    demoIndex = 0
                    runDemoStep()
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)

                if demoActive {
                    Text("Foco VoiceOver: \(labels[demoIndex])")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.12))
                        .cornerRadius(12)
                }

                Button("Más información") { showingInfo = true }
                    .buttonStyle(.bordered)
                    .frame(maxWidth: .infinity)
            }
            .padding()
        }
        .navigationTitle("VoiceOver")
        .sheet(isPresented: $showingInfo) {
            NavigationView {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("En el iPhone:")
                            .font(.headline)
                        Text("Ajustes > Accesibilidad > VoiceOver")
                        Text("Desplázate por los elementos con gestos de un dedo.")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                }
                .navigationTitle("Más información")
                .toolbar { Button("Cerrar") { showingInfo = false } }
            }
        }
    }

    private func runDemoStep() {
        guard demoActive else { return }
        UIAccessibility.post(notification: .announcement, argument: labels[demoIndex])
        guard demoIndex < labels.count - 1 else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { demoActive = false }
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            demoIndex += 1
            runDemoStep()
        }
    }
}

struct DynamicTypeView: View {
    @EnvironmentObject var preferences: AppPreferences

    var body: some View {
        VStack(spacing: 24) {
            Text("Ajusta el tamaño del texto para ver cómo responde la interfaz.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)

            HStack {
                Text("A").font(.system(size: 12))
                Slider(value: $preferences.textSize, in: 14...32, step: 1)
                    .accessibilityValue("\(Int(preferences.textSize)) puntos")
                Text("A").font(.system(size: 24))
            }

            Button("Restablecer") { preferences.textSize = 18 }
                .buttonStyle(.bordered)

            VStack(alignment: .leading, spacing: 12) {
                Text("Vista previa del texto ajustado.")
                    .font(.system(size: preferences.textSize, weight: .bold))
                Text("Así se visualiza el contenido con la configuración seleccionada.")
                    .font(.system(size: preferences.textSize))
            }
            .frame(maxWidth: .infinity, minHeight: 180, alignment: .topLeading)
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(16)
            Spacer()
        }
        .padding()
        .navigationTitle("Dynamic Type")
    }
}

struct ContrastView: View {
    @EnvironmentObject var preferences: AppPreferences

    var body: some View {
        VStack(spacing: 14) {
            contrastButton("Contraste normal", mode: .normal)
            contrastButton("Contraste alto", mode: .high)
            contrastButton("Contraste oscuro", mode: .dark)

            let palette = previewPalette
            VStack(alignment: .leading, spacing: 10) {
                Text("Vista previa").font(.headline)
                Text("Así se visualiza el contenido con la configuración seleccionada.")
            }
            .foregroundColor(palette.foreground)
            .frame(maxWidth: .infinity, minHeight: 170, alignment: .topLeading)
            .padding()
            .background(palette.background)
            .overlay(RoundedRectangle(cornerRadius: 16)
                .stroke(palette.border, lineWidth: preferences.contrast == .high ? 3 : 1))
            .cornerRadius(16)
            Spacer()
        }
        .padding()
        .navigationTitle("Contraste")
    }

    private func contrastButton(_ title: String, mode: AppPreferences.ContrastMode) -> some View {
        Button(title) { preferences.contrast = mode }
            .frame(maxWidth: .infinity, minHeight: 52)
            .background(preferences.contrast == mode ? Color.blue : Color(.secondarySystemBackground))
            .foregroundColor(preferences.contrast == mode ? .white : .primary)
            .cornerRadius(12)
            .accessibilityAddTraits(preferences.contrast == mode ? .isSelected : [])
    }

    private var previewPalette: (background: Color, foreground: Color, border: Color) {
        switch preferences.contrast {
        case .high: return (.black, .yellow, .yellow)
        case .dark: return (Color(red: 0.08, green: 0.08, blue: 0.12), .white, .gray)
        case .normal: return (Color(.systemBackground), .primary, .blue)
        }
    }
}

struct MotorView: View {
    @State private var option1 = false
    @State private var option2 = false
    @State private var status = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                Text("Controles grandes y espaciados para reducir errores de precisión.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)

                VStack(spacing: 0) {
                    Toggle("Opción 1", isOn: $option1).frame(minHeight: 64).padding(.horizontal)
                    Divider()
                    Toggle("Opción 2", isOn: $option2).frame(minHeight: 64).padding(.horizontal)
                }
                .background(Color(.secondarySystemBackground)).cornerRadius(16)

                VStack {
                    Text("Área de Prueba").font(.headline)
                    Button {
                        status = "Completado: Prueba Realizada"
                        UIAccessibility.post(notification: .announcement, argument: status)
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                    } label: {
                        Label("Play", systemImage: "play.fill").frame(width: 110, height: 64)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity).padding(.vertical, 24)
                .background(Color(.secondarySystemBackground)).cornerRadius(18)

                Text(status).foregroundColor(.green).frame(minHeight: 24)
                    .accessibilityAddTraits(.updatesFrequently)

                HStack {
                    Button("CONFIRMAR") { status = "Configuración confirmada" }
                        .frame(maxWidth: .infinity, minHeight: 52).buttonStyle(.borderedProminent)
                    Button("CANCELAR") {
                        option1 = false
                        option2 = false
                        status = ""
                    }
                    .frame(maxWidth: .infinity, minHeight: 52).buttonStyle(.bordered)
                }
            }
            .padding()
        }
        .navigationTitle("Accesibilidad Motora")
    }
}

struct HearingView: View {
    @EnvironmentObject var preferences: AppPreferences

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                Text("Alternativas visuales, hápticas y con subtítulos.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)

                VStack(spacing: 0) {
                    hearingToggle("Alertas Visuales", $preferences.visualAlerts)
                    Divider()
                    hearingToggle("Vibración", $preferences.vibration)
                    Divider()
                    hearingToggle("Subtítulos", $preferences.subtitles)
                }
                .background(Color(.secondarySystemBackground)).cornerRadius(16)

                VStack(alignment: .leading, spacing: 10) {
                    if preferences.visualAlerts { Text("<< Ejecutando Alerta Visual >>") }
                    if preferences.subtitles { Text("[Sonido de campana: Notificación recibida]") }
                    if preferences.vibration { Text("<< Vibración en Acción >>") }
                    if !preferences.visualAlerts && !preferences.subtitles && !preferences.vibration {
                        Text("Active una opción para ver su demostración.")
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 150, alignment: .topLeading)
                .padding()
                .background(Color(.secondarySystemBackground)).cornerRadius(16)

                HStack {
                    Button("CONFIRMAR") {
                        if preferences.vibration {
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                        }
                        if preferences.visualAlerts {
                            UIAccessibility.post(notification: .announcement,
                                                 argument: "Alerta visual recibida")
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 52).buttonStyle(.borderedProminent)
                    Button("CANCELAR") {
                        preferences.visualAlerts = false
                        preferences.vibration = false
                        preferences.subtitles = false
                    }
                    .frame(maxWidth: .infinity, minHeight: 52).buttonStyle(.bordered)
                }
            }
            .padding()
        }
        .navigationTitle("Accesibilidad Auditiva")
    }

    private func hearingToggle(_ title: String, _ isOn: Binding<Bool>) -> some View {
        Toggle(title, isOn: isOn)
            .frame(minHeight: 60)
            .padding(.horizontal)
            .onChange(of: isOn.wrappedValue) { enabled in
                if enabled && title == "Vibración" {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }
            }
    }
}

struct SettingsView: View {
    var body: some View {
        List {
            Section {
                settingsLink("textformat.size", .gray, "Tamaño de Texto", DynamicTypeView())
                settingsLink("circle.lefthalf.filled", .yellow, "Contraste de color", ContrastView())
                settingsLink("speaker.wave.2", .green, "VoiceOver", VoiceOverView())
                settingsLink("eye", .cyan, "Avisos visuales", HearingView())
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Configuración")
    }

    private func settingsLink<V: View>(_ icon: String, _ color: Color,
                                       _ title: String, _ destination: V) -> some View {
        NavigationLink(destination: destination) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.white)
                    .frame(width: 28, height: 28)
                    .background(color).cornerRadius(7)
                Text(title)
            }
            .padding(.vertical, 4)
        }
    }
}

struct DemoCard: View {
    let title: String
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline)
            Text(text).foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}
