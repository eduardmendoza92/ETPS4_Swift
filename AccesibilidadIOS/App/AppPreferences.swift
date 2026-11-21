import Foundation
import UIKit

final class AppPreferences: ObservableObject {
    enum ContrastMode: String, CaseIterable {
        case normal, high, dark
    }

    @Published var textSize: Double {
        didSet { UserDefaults.standard.set(textSize, forKey: "textSize") }
    }
    @Published var contrast: ContrastMode {
        didSet { UserDefaults.standard.set(contrast.rawValue, forKey: "contrast") }
    }
    @Published var visualAlerts: Bool {
        didSet { UserDefaults.standard.set(visualAlerts, forKey: "visualAlerts") }
    }
    @Published var vibration: Bool {
        didSet { UserDefaults.standard.set(vibration, forKey: "vibration") }
    }
    @Published var subtitles: Bool {
        didSet { UserDefaults.standard.set(subtitles, forKey: "subtitles") }
    }

    init() {
        textSize = UserDefaults.standard.object(forKey: "textSize") as? Double ?? 18
        contrast = ContrastMode(rawValue: UserDefaults.standard.string(forKey: "contrast") ?? "") ?? .normal
        visualAlerts = UserDefaults.standard.bool(forKey: "visualAlerts")
        vibration = UserDefaults.standard.bool(forKey: "vibration")
        subtitles = UserDefaults.standard.bool(forKey: "subtitles")
    }
}
