import SwiftUI

enum AppIcon {
    case home
    case homeFill
    case helpCenter
    case helpCenterFill
    case ticket
    case ticketFill
    case profile
    case profileFill
    case notification
    case notificationFill
    case search
    case close
    case back
    case more
    case share
    case edit
    case delete
    case checkmark
    case warning
    case info
    case settings
    case language
    case privacy
    case agreement
    case logout
    case send
    case attachment
    case filter
    case sort
    case refresh
    case eye
    case eyeSlash
    case lock
    case unlock
    case person
    case phone
    case email
    case chevronRight
    case chevronDown
    case chevronUp
    case plus
    case minus
    case copy
    case link
    case externalLink
    case star
    case starFill
    case heart
    case heartFill

    var systemName: String {
        switch self {
        case .home: return "house"
        case .homeFill: return "house.fill"
        case .helpCenter: return "questionmark.circle"
        case .helpCenterFill: return "questionmark.circle.fill"
        case .ticket: return "ticket"
        case .ticketFill: return "ticket.fill"
        case .profile: return "person.crop.circle"
        case .profileFill: return "person.crop.circle.fill"
        case .notification: return "bell"
        case .notificationFill: return "bell.fill"
        case .search: return "magnifyingglass"
        case .close: return "xmark"
        case .back: return "chevron.left"
        case .more: return "ellipsis"
        case .share: return "square.and.arrow.up"
        case .edit: return "pencil"
        case .delete: return "trash"
        case .checkmark: return "checkmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .info: return "info.circle.fill"
        case .settings: return "gearshape"
        case .language: return "globe"
        case .privacy: return "hand.raised"
        case .agreement: return "doc.text"
        case .logout: return "rectangle.portrait.and.arrow.right"
        case .send: return "paperplane.fill"
        case .attachment: return "paperclip"
        case .filter: return "line.3.horizontal.decrease.circle"
        case .sort: return "arrow.up.arrow.down"
        case .refresh: return "arrow.clockwise"
        case .eye: return "eye"
        case .eyeSlash: return "eye.slash"
        case .lock: return "lock.fill"
        case .unlock: return "lock.open.fill"
        case .person: return "person.fill"
        case .phone: return "phone.fill"
        case .email: return "envelope.fill"
        case .chevronRight: return "chevron.right"
        case .chevronDown: return "chevron.down"
        case .chevronUp: return "chevron.up"
        case .plus: return "plus"
        case .minus: return "minus"
        case .copy: return "doc.on.doc"
        case .link: return "link"
        case .externalLink: return "arrow.up.right.square"
        case .star: return "star"
        case .starFill: return "star.fill"
        case .heart: return "heart"
        case .heartFill: return "heart.fill"
        }
    }

    func image(size: CGFloat = 20, weight: Font.Weight = .regular) -> Image {
        Image(systemName: systemName)
    }
}

extension Image {
    init(appIcon: AppIcon) {
        self.init(systemName: appIcon.systemName)
    }
}

struct AppIconView: View {
    let icon: AppIcon
    let size: CGFloat
    let weight: Font.Weight
    let color: Color

    init(
        _ icon: AppIcon,
        size: CGFloat = 20,
        weight: Font.Weight = .regular,
        color: Color = AppPalette.textPrimary
    ) {
        self.icon = icon
        self.size = size
        self.weight = weight
        self.color = color
    }

    var body: some View {
        Image(appIcon: icon)
            .font(.system(size: size, weight: weight))
            .foregroundStyle(color)
    }
}
