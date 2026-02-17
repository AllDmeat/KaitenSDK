import Foundation
import ArgumentParser

/// ISO 8601 date format used across the CLI.
///
/// Accepts both full datetime (`2025-01-15T10:30:00Z`) and date-only (`2025-01-15`).
enum DateParsing {
    /// Parses an ISO 8601 string into a `Date`.
    ///
    /// - Parameter string: Date string in `yyyy-MM-dd` or `yyyy-MM-ddTHH:mm:ssZ` format.
    /// - Throws: `ValidationError` if the string cannot be parsed.
    /// - Returns: The parsed `Date`.
    static func parse(_ string: String) throws -> Date {
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime]
        if let date = iso.date(from: string) {
            return date
        }

        let dateOnly = DateFormatter()
        dateOnly.dateFormat = "yyyy-MM-dd"
        dateOnly.locale = Locale(identifier: "en_US_POSIX")
        dateOnly.timeZone = TimeZone(identifier: "UTC")
        if let date = dateOnly.date(from: string) {
            return date
        }

        throw ValidationError(
            "Invalid date: '\(string)'. Expected ISO 8601 format (e.g. 2025-01-15 or 2025-01-15T10:30:00Z)"
        )
    }

    /// Parses an optional date string.
    static func parse(_ string: String?) throws -> Date? {
        guard let string else { return nil }
        return try parse(string)
    }
}
