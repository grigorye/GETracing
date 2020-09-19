//
//  SourceLiterals.swift
//  GETracing
//
//  Created by Grigory Entin on 28/01/2019.
//

import Foundation

public func literalForArguments(contents: String, line: Int, column: UInt, function: StaticString) -> String {
	let line = Int(line)
	let column = Int(column)
	let lineTexts = contents.components(separatedBy: "\n")
	let lineText = lineTexts[line - 1] + lineTexts[line...].joined(separator: "\n")
	let columnIndex = lineText.index(lineText.startIndex, offsetBy: column)
	let lineTextTail = String(lineText[columnIndex...])
	let (openingBracket, closingBracket) = ("(", ")")
	let indexOfClosingBracketInTail = lineTextTail.rangeOfClosingBracket(closingBracket, openingBracket: openingBracket)!.lowerBound
	let label = String(lineTextTail[..<indexOfClosingBracketInTail])
	return label
}

public func literalForArguments(sourceFileURL: URL, line: Int, column: UInt, function: StaticString) throws -> String {
	let contents = try String(contentsOf: sourceFileURL, encoding: String.Encoding.utf8)
	return literalForArguments(contents: contents, line: line, column: column, function: function)
}
