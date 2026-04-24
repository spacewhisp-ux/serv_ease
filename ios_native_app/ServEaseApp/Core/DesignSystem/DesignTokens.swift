import SwiftUI

enum DesignTokens {
    // Colors from DESIGN.md / AppTheme
    static let cloudGray      = Color(hex: "F0F0F3")
    static let pureWhite      = Color(hex: "FFFFFF")
    static let expoBlack      = Color(hex: "000000")
    static let nearBlack      = Color(hex: "1C2024")
    static let slateGray      = Color(hex: "60646C")
    static let borderLavender = Color(hex: "E0E1E6")
    static let inputBorder    = Color(hex: "D9D9E0")
    static let linkCobalt     = Color(hex: "0D74CE")
    static let silver         = Color(hex: "B0B4BA")

    // Corner radii
    static let cardRadius: CGFloat   = 20
    static let buttonRadius: CGFloat = 9999
    static let chipRadius: CGFloat   = 9999
    static let inputRadius: CGFloat  = 16
    static let smallRadius: CGFloat  = 6

    // Status colors
    static let statusOpen       = Color(hex: "0D74CE")
    static let statusPending    = Color(hex: "AB6400")
    static let statusInProgress = Color(hex: "476CFF")
    static let statusResolved   = Color(hex: "2E7D32")
    static let statusClosed     = Color(hex: "60646C")

    static func statusColor(for status: String) -> Color {
        switch status {
        case "OPEN":        return statusOpen
        case "PENDING":     return statusPending
        case "IN_PROGRESS": return statusInProgress
        case "RESOLVED":    return statusResolved
        case "CLOSED":      return statusClosed
        default:            return slateGray
        }
    }

    // Priority colors
    static let priorityLow    = Color(hex: "B0B4BA")
    static let priorityNormal = Color(hex: "60646C")
    static let priorityHigh   = Color(hex: "AB6400")
    static let priorityUrgent = Color(hex: "D32F2F")

    static func priorityColor(for priority: String) -> Color {
        switch priority {
        case "LOW":     return priorityLow
        case "NORMAL":  return priorityNormal
        case "HIGH":    return priorityHigh
        case "URGENT":  return priorityUrgent
        default:        return priorityNormal
        }
    }
}
