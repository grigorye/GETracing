import Foundation

func some<T>(_ v: T?, file: StaticString = #file, line: UInt = #line) -> T? {
	guard let v = v else {
		dump(Thread.callStackSymbols, name: "callStackSymbols")
		dump(Thread.callStackReturnAddresses.map {$0.uintValue}, name: "callStackReturnAddresses")
		assertionFailure("Unexpected nil", file: file, line: line)
		return nil
	}
	return v
}
