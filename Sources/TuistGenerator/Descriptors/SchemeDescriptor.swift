import Foundation
import XcodeProj

/// Scheme Descriptor
///
/// Contains the information needed to generate a scheme.
///
/// When part of a `ProjectDescriptor` or `WorkspaceDescriptor`, it
/// can be used in conjunction with `XcodeProjWriter` to generate
/// an `.xcscheme` file.
///
/// - seealso: `ProjectDescriptor`
/// - seealso: `WorkspaceDescriptor`
/// - seealso: `XcodeProjWriter`
public struct SchemeDescriptor {
    /// The XCScheme scheme representation
    public var xcScheme: XCScheme

    /// The Scheme type shared vs user scheme
    public var shared: Bool

    /// Whether the scheme is hidden or not.
    public var hidden: Bool

    public init(xcScheme: XCScheme, shared: Bool, hidden: Bool) {
        self.xcScheme = xcScheme
        self.shared = shared
        self.hidden = hidden
    }
}

#if DEBUG
    extension SchemeDescriptor {
        public static func test(name: String, shared: Bool, hidden: Bool = false) -> SchemeDescriptor {
            let scheme = XCScheme(name: name, lastUpgradeVersion: "1131", version: "1")
            return SchemeDescriptor(xcScheme: scheme, shared: shared, hidden: hidden)
        }
    }
#endif
