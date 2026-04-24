import Foundation

// Supported currencies and their approximate rates to TWD.
// Rates are stored in UserDefaults so users can override them.
struct CurrencyConverter {
    static let supportedCurrencies = ["TWD", "USD", "JPY", "EUR"]

    static let defaultRatesToTWD: [String: Decimal] = [
        "TWD": 1,
        "USD": 32,
        "JPY": Decimal(string: "0.21") ?? 0,
        "EUR": 35,
    ]

    static func rateToTWD(from currency: String) -> Decimal {
        let key = "exchangeRate_\(currency)_TWD"
        if let saved = UserDefaults.standard.string(forKey: key),
           let rate = Decimal(string: saved), rate > 0 {
            return rate
        }
        return defaultRatesToTWD[currency] ?? 1
    }

    static func setRate(_ rate: Decimal, from currency: String) {
        let key = "exchangeRate_\(currency)_TWD"
        UserDefaults.standard.set("\(rate)", forKey: key)
    }

    static func convert(_ amount: Decimal, from: String, to: String) -> Decimal {
        guard from != to else { return amount }
        let inTWD = amount * rateToTWD(from: from)
        guard to != "TWD" else { return inTWD }
        let toRate = rateToTWD(from: to)
        guard toRate > 0 else { return inTWD }
        return inTWD / toRate
    }

    static func symbol(for currency: String) -> String {
        switch currency {
        case "TWD": return "NT$"
        case "USD": return "$"
        case "JPY": return "¥"
        case "EUR": return "€"
        default: return currency
        }
    }
}
