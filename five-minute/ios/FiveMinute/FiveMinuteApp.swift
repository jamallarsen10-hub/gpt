import FamilyControls
import SwiftUI

@main
struct FiveMinuteApp: App {
    var body: some Scene {
        WindowGroup { ContentView() }
    }
}

struct ContentView: View {
    @StateObject private var model = LimiterModel()
    @State private var showingPicker = false
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("5 minutes a day")
                            .font(.largeTitle.bold())
                        Text("Instagram, then back to your day.")
                            .foregroundStyle(.secondary)
                        Text(model.status)
                            .font(.headline)
                            .accessibilityIdentifier("protectionStatus")
                    }
                    .padding(.vertical, 12)
                }

                if !model.authorized {
                    Section("1. Allow Screen Time") {
                        Text("Apple counts use and applies the block, even when this app is closed.")
                        Button("Allow Screen Time access") {
                            Task { await model.requestAccess() }
                        }
                        .disabled(model.busy)
                    }
                } else {
                    Section(model.selectionLocked ? "Protected app" : "2. Choose Instagram") {
                        ForEach(Array(model.selection.applicationTokens), id: \.self) { token in
                            Label(token).labelStyle(.titleAndIcon)
                        }
                        if !model.selectionLocked {
                            Button("Select Instagram") { showingPicker = true }
                            Text("Select only the Instagram app. Leave categories and websites unselected.")
                                .font(.footnote).foregroundStyle(.secondary)
                        }
                    }

                    if !model.registered {
                        Section {
                            Button(model.selectionLocked ? "Repair monitoring" : "Enable daily limit") {
                                model.enable()
                            }
                            .disabled(model.busy || (!model.selectionLocked && !model.validSelection))
                            Text("Includes usage Apple has counted since midnight. The app choice stays fixed after enabling.")
                                .font(.footnote).foregroundStyle(.secondary)
                        }
                    }
                }

                if let error = model.error {
                    Section("Needs attention") {
                        Text(error).foregroundStyle(.red).textSelection(.enabled)
                        Button("Check again") { model.refresh() }
                    }
                }

                Section("How it works") {
                    Text("Five minutes total across sessions. Once reached, Apple shields the app until the next day. There is no extra-time button here.")
                    Text("Apple does not provide this app an exact live countdown. Blocking can follow the system callback with a delay.")
                    Text("A person you trust can separately lock Screen Time settings with a passcode you do not know. This app cannot set that passcode or prevent every bypass.")
                    Text("Only the selected app is shielded. No website restrictions are configured. Apple may include associated website use in its usage event.")
                }
                .font(.footnote)

                if let diagnostic = model.diagnostic {
                    Section("Last monitor callback") {
                        Text(diagnostic.callback)
                        Text(diagnostic.recordedAt, format: .dateTime)
                            .foregroundStyle(.secondary)
                    }
                    .font(.footnote)
                }
            }
            .navigationTitle("Five Minute")
            .familyActivityPicker(isPresented: $showingPicker, selection: $model.selection)
            .task { model.refresh() }
            .onChange(of: scenePhase) { _, phase in
                if phase == .active { model.refresh() }
            }
            .onReceive(AuthorizationCenter.shared.$authorizationStatus) { _ in
                model.refresh()
            }
        }
    }
}
