public func L(file: StaticString = #file, line: Int = #line, column: UInt = #column, function: StaticString = #function, dso: UnsafeRawPointer = #dsohandle, _ valueClosure: @autoclosure () -> some Any) -> String {
    // swiftlint:disable:previous identifier_name
    let value = valueClosure()
    let label = labelForArguments(file: file, line: line, column: column, function: function, dso: dso)
    let loggedValue = newLoggedValue(for: value)
    let logMessage = loggedValue.logMessage()
    let formatted = logMessage.formattedForOutput(prefixedWithLabel: true)
    let labeled = "\(label):" + formatted
    return labeled
}
