//  Created by y H on 2025/6/25.
//  Copyright © 2025 wwdc14yh. All rights reserved.

import UIKit
import UIComponent

public protocol LabelStyle {
    typealias Configuration = Label.StyleConfiguration
    associatedtype C: Component

    @MainActor @preconcurrency
    func makeBody(configuration: Self.Configuration) -> Self.C
}

public struct DefaultLabelStyle: LabelStyle {
    public func makeBody(configuration: Configuration) -> some Component {
        HStack(spacing: 5, alignItems: .center) {
            configuration.icon
            configuration.title
        }
    }
}

public extension LabelStyle where Self == DefaultLabelStyle {
    static var automatic: DefaultLabelStyle {
        DefaultLabelStyle()
    }
}

public extension Label {
    struct StyleConfiguration {
        public let title: any Component
        public let icon: any Component
    }
}

public struct LabelStyleEnvironmentKey: EnvironmentKey {
    public static var defaultValue: any LabelStyle { .automatic }
}

public extension EnvironmentValues {
    var labelStyle: any LabelStyle {
        get {
            self[LabelStyleEnvironmentKey.self]
        } set {
            self[LabelStyleEnvironmentKey.self] = newValue
        }
    }
}

public extension Component {
    func labelStyle(_ style: any LabelStyle) -> EnvironmentComponent<any LabelStyle, Self> {
        environment(\.labelStyle, value: style)
    }
}

public struct Label: ComponentBuilder {
    @Environment(\.labelStyle)
    var labelStyle

    let title: any Component
    let icon: any Component

    public init(title: () -> any Component, icon: () -> any Component) {
        self.title = title()
        self.icon = icon()
    }

    public init(_ titleString: String, systemImage name: String) {
        self.init {
            Text(titleString)
        } icon: {
            Image(systemName: name)
        }
    }

    public init(_ titleString: String, image name: String) {
        self.init {
            Text(titleString)
        } icon: {
            Image(name)
        }
    }

    public func build() -> some Component {
        labelStyle.makeBody(configuration: StyleConfiguration(title: title,
                                                              icon: icon))
            .eraseToAnyComponent()
    }
}
