import Foundation
import OSLog
import SwiftUI

let logger: Logger = Logger(subsystem: "ru.mdhome.code.word", category: "code_word")

/// The Android SDK number we are running against, or `nil` if not running on Android
let androidSDK = ProcessInfo.processInfo.environment["android.os.Build.VERSION.SDK_INT"].flatMap({ Int($0) })

public struct RootView: View {
    public var body: some View {
        MainNavigationView(navigation: DI.shared.navigation)
        //            .task {
        //                logger.log("Welcome to Skip on \(androidSDK != nil ? "Android" : "Darwin")!")
        //                logger.warning("Skip app logs are viewable in the Xcode console for iOS; Android logs can be viewed in Studio or using adb logcat")
        //            }
    }
}


#if !SKIP
public protocol code_wordApp: App {}

/// The entry point to the code_word app.
/// The concrete implementation is in the code_wordApp module.
public extension code_wordApp {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
#endif
