import Foundation

// Minimal UI test support flag (no app-type references to prevent build issues)
enum UITestSupport {
    static let argument = "UITestUseMockService"
    static var isEnabled: Bool { ProcessInfo.processInfo.arguments.contains(argument) }
}