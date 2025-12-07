//
// SettingsView.swift
// AvoidObstaclesGame
//

import SwiftUI

struct SettingsView: View {
    @State private var config = GameConfiguration.load()
    @State private var selectedLanguage = LocalizationManager.shared.getCurrentLanguage()
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                // Audio Section
                Section(header: Text("Audio")) {
                    Toggle("Background Music", isOn: binding(for: \.audio.backgroundMusicEnabled))
                    if config.audio.backgroundMusicEnabled {
                        HStack {
                            Text("Volume")
                            Slider(value: binding(for: \.audio.backgroundMusicVolume), in: 0...1)
                            Text("\(Int(config.audio.backgroundMusicVolume * 100))%")
                                .frame(width: 50)
                        }
                    }

                    Toggle("Sound Effects", isOn: binding(for: \.audio.soundEffectsEnabled))
                    Toggle("Haptic Feedback", isOn: binding(for: \.audio.hapticsEnabled))
                }

                // Visual Section
                Section(header: Text("Visual")) {
                    Picker("Theme", selection: binding(for: \.visual.theme)) {
                        Text("Auto").tag("auto")
                        Text("Light").tag("light")
                        Text("Dark").tag("dark")
                        Text("Neon").tag("neon")
                        Text("Retro").tag("retro")
                    }

                    Picker("Particle Quality", selection: binding(for: \.visual.particleQuality)) {
                        Text("Low").tag("low")
                        Text("Medium").tag("medium")
                        Text("High").tag("high")
                    }

                    Toggle("Show FPS", isOn: binding(for: \.visual.showFPS))
                }

                // Accessibility Section
                Section(header: Text("Accessibility")) {
                    Toggle("Reduce Motion", isOn: binding(for: \.accessibility.reduceMotion))
                    Toggle("Increase Contrast", isOn: binding(for: \.accessibility.increaseContrast))
                    Toggle("Larger Touch Targets", isOn: binding(for: \.accessibility.largerTouchTargets))

                    Picker("Colorblind Mode", selection: binding(for: \.accessibility.colorBlindMode)) {
                        Text("None").tag("none")
                        Text("Protanopia").tag("protanopia")
                        Text("Deuteranopia").tag("deuteranopia")
                        Text("Tritanopia").tag("tritanopia")
                    }
                }

                // Language Section
                Section(header: Text("Language")) {
                    Picker("Language", selection: $selectedLanguage) {
                        ForEach(LocalizationManager.shared.getSupportedLanguages(), id: \.self) { language in
                            Text(language.displayName).tag(language)
                        }
                    }
                    .onChange(of: selectedLanguage) { newLanguage in
                        LocalizationManager.shared.setLanguage(newLanguage)
                    }
                }

                // Reset Section
                Section {
                    Button(action: resetToDefaults) {
                        HStack {
                            Spacer()
                            Text("Reset to Defaults")
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarItems(trailing: Button("Done") {
                saveAndDismiss()
            })
        }
    }

    private func binding<T>(for keyPath: WritableKeyPath<GameConfiguration, T>) -> Binding<T> {
        Binding(
            get: { config[keyPath: keyPath] },
            set: { config[keyPath: keyPath] = $0 }
        )
    }

    private func saveAndDismiss() {
        config.save()
        presentationMode.wrappedValue.dismiss()
    }

    private func resetToDefaults() {
        config = .default
        config.save()
    }
}
