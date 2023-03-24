import Foundation

public var tracedValueDescriptionGenerator: (Any) -> String = { value in
    if dumpInTraceEnabled {
        var s = ""
        dump(value, to: &s)
        return s
    }
    return String(reflecting: value)
}

public var dumpInTraceEnabledEnforced: Bool?
private var dumpInTraceEnabled: Bool {
    return dumpInTraceEnabledEnforced ?? UserDefaults.standard.bool(forKey: "dumpInTraceEnabled")
}
