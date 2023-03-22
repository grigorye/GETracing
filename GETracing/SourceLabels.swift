import Foundation

func descriptionForInLineLocation(column: UInt) -> String {
	return ".\(column)"
}

public var sourceLabelsEnabledEnforced: Bool?

var sourceLabelsEnabled: Bool {
	return sourceLabelsEnabledEnforced ?? UserDefaults.standard.bool(forKey: "sourceLabelsEnabled")
}
public func labelForArguments(file: StaticString, line: Int, column: UInt, function: StaticString, dso: UnsafeRawPointer) -> String {
	guard sourceLabelsEnabled else {
		return descriptionForInLineLocation(column: column)
	}
	do {
		let sourceFileURL = try sourceFileURLFor(file: file, dso: dso)
		
		return try literalForArguments(sourceFileURL: sourceFileURL, line: line, column: column, function: function)
	} catch {
		trackSourceLabelError(error)
		return descriptionForInLineLocation(column: column) + ":?"
	}
}

public func labelForArguments(location: SourceLocation) -> String {
	let line = location.line
	let column = location.column
	let function = location.function
	guard sourceLabelsEnabled else {
		return descriptionForInLineLocation(column: column)
	}
	do {
		let sourceFileURL = try location.sourceFileURL()
		
		return try literalForArguments(sourceFileURL: sourceFileURL, line: line, column: column, function: function)
	} catch {
		trackSourceLabelError(error)
		return descriptionForInLineLocation(column: column)
	}
}

public func trackSourceLabelError(_ error: Error) {
}
