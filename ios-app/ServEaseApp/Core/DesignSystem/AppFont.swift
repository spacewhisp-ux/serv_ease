import SwiftUI

enum AppFont {
    static let largeTitle = Font.system(size: 28, weight: .bold, design: .rounded)
    static let title1 = Font.system(size: 22, weight: .bold, design: .rounded)
    static let title2 = Font.system(size: 20, weight: .semibold, design: .rounded)
    static let title3 = Font.system(size: 18, weight: .semibold, design: .rounded)
    static let headline = Font.system(size: 17, weight: .semibold, design: .default)
    static let body = Font.system(size: 16, weight: .regular, design: .default)
    static let callout = Font.system(size: 15, weight: .regular, design: .default)
    static let subheadline = Font.system(size: 14, weight: .regular, design: .default)
    static let footnote = Font.system(size: 13, weight: .regular, design: .default)
    static let caption = Font.system(size: 12, weight: .regular, design: .default)
    static let caption2 = Font.system(size: 11, weight: .regular, design: .default)

    static func custom(size: CGFloat, weight: Font.Weight = .regular, design: Font.Design = .default) -> Font {
        Font.system(size: size, weight: weight, design: design)
    }

    static func rounded(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        Font.system(size: size, weight: weight, design: .rounded)
    }

    static func monospaced(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        Font.system(size: size, weight: weight, design: .monospaced)
    }

    static func serif(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        Font.system(size: size, weight: weight, design: .serif)
    }
}

extension Font {
    static func app(_ style: AppFont.Style) -> Font {
        style.font
    }
}

extension AppFont {
    enum Style {
        case largeTitle
        case title1
        case title2
        case title3
        case headline
        case body
        case callout
        case subheadline
        case footnote
        case caption
        case caption2

        var font: Font {
            switch self {
            case .largeTitle: return AppFont.largeTitle
            case .title1: return AppFont.title1
            case .title2: return AppFont.title2
            case .title3: return AppFont.title3
            case .headline: return AppFont.headline
            case .body: return AppFont.body
            case .callout: return AppFont.callout
            case .subheadline: return AppFont.subheadline
            case .footnote: return AppFont.footnote
            case .caption: return AppFont.caption
            case .caption2: return AppFont.caption2
            }
        }

        var size: CGFloat {
            switch self {
            case .largeTitle: return 28
            case .title1: return 22
            case .title2: return 20
            case .title3: return 18
            case .headline: return 17
            case .body: return 16
            case .callout: return 15
            case .subheadline: return 14
            case .footnote: return 13
            case .caption: return 12
            case .caption2: return 11
            }
        }

        var lineHeight: CGFloat {
            size * 1.4
        }
    }
}
