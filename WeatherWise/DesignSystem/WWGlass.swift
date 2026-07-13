//
//  WWGlass.swift
//  WeatherWise
//
//  WeatherWise Design System — Liquid Glass library.
//
//  Every component renders Apple's Liquid Glass (iOS 26+) when both the SDK
//  and the OS support it, and degrades to translucent materials otherwise.
//  Build-time gates use `#if compiler(>=6.2)` (Swift 6.2 ships with Xcode 26)
//  so the project still compiles with pre-iOS-26 SDKs such as Xcode 16 on CI.
//
//  Usage:
//      someView.wwGlassCard()                       // rounded-rect glass card
//      someView.wwGlassCapsule(interactive: true)   // capsule chip
//      WWGlassContainer(spacing: 24) { ... }        // shared sampling + morphing
//      Button(...).wwGlassButton()                  // glass button style
//

import SwiftUI

/// Semantic tints for the app's glass surfaces.
enum WWGlassTint {
    static let hero = Color.blue
    static let good = Color.green
    static let neutral = Color.white
    static let alert = Color.yellow
    static let danger = Color.red
}

// MARK: - Core surface modifier

/// Applies a Liquid Glass surface behind the content, clipped to `shape`.
/// Falls back to `.ultraThinMaterial` with a hairline stroke pre-iOS 26.
struct WWGlassSurface<S: Shape>: ViewModifier {
    let shape: S
    var tint: Color?
    var interactive: Bool

    @ViewBuilder
    func body(content: Content) -> some View {
        #if compiler(>=6.2)
        if #available(iOS 26.0, *) {
            content.glassEffect(resolvedGlass, in: shape)
        } else {
            fallback(content)
        }
        #else
        fallback(content)
        #endif
    }

    #if compiler(>=6.2)
    @available(iOS 26.0, *)
    private var resolvedGlass: Glass {
        var glass: Glass = .regular
        if let tint {
            glass = glass.tint(tint.opacity(0.5))
        }
        if interactive {
            glass = glass.interactive()
        }
        return glass
    }
    #endif

    private func fallback(_ content: Content) -> some View {
        content
            .background(.ultraThinMaterial, in: shape)
            .overlay {
                shape
                    .strokeBorder(
                        LinearGradient(
                            colors: [.white.opacity(0.5), .white.opacity(0.08)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
            .background {
                if let tint {
                    shape.fill(tint.opacity(0.14))
                }
            }
            .shadow(color: .black.opacity(0.12), radius: 14, y: 6)
    }
}

// MARK: - Container

/// Wraps content in a `GlassEffectContainer` on iOS 26 so nearby glass
/// elements share one backdrop sample and can morph into each other.
/// Renders content unchanged on earlier systems.
struct WWGlassContainer<Content: View>: View {
    var spacing: CGFloat = 16
    @ViewBuilder var content: () -> Content

    var body: some View {
        #if compiler(>=6.2)
        if #available(iOS 26.0, *) {
            GlassEffectContainer(spacing: spacing) {
                content()
            }
        } else {
            content()
        }
        #else
        content()
        #endif
    }
}

// MARK: - View extensions

extension View {
    /// Glass card with a continuous rounded-rectangle shape.
    func wwGlassCard(
        tint: Color? = nil,
        cornerRadius: CGFloat = 24,
        interactive: Bool = false
    ) -> some View {
        modifier(
            WWGlassSurface(
                shape: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous),
                tint: tint,
                interactive: interactive
            )
        )
    }

    /// Glass capsule, suited to chips and pills. Interactive by default —
    /// use for surfaces the user touches directly.
    func wwGlassCapsule(tint: Color? = nil, interactive: Bool = true) -> some View {
        modifier(WWGlassSurface(shape: Capsule(), tint: tint, interactive: interactive))
    }

    /// Circular glass, suited to icon buttons.
    func wwGlassCircle(tint: Color? = nil, interactive: Bool = true) -> some View {
        modifier(WWGlassSurface(shape: Circle(), tint: tint, interactive: interactive))
    }

    /// System glass button style on iOS 26, bordered fallback earlier.
    @ViewBuilder
    func wwGlassButton() -> some View {
        #if compiler(>=6.2)
        if #available(iOS 26.0, *) {
            self.buttonStyle(.glass)
        } else {
            self.buttonStyle(.bordered)
        }
        #else
        self.buttonStyle(.bordered)
        #endif
    }

    /// Ties a glass element into a container's morph animations on iOS 26.
    /// No-op on earlier systems.
    @ViewBuilder
    func wwGlassID<ID: Hashable>(_ id: ID, in namespace: Namespace.ID) -> some View {
        #if compiler(>=6.2)
        if #available(iOS 26.0, *) {
            self.glassEffectID(id, in: namespace)
        } else {
            self
        }
        #else
        self
        #endif
    }
}
