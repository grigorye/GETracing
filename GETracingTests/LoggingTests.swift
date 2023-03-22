@testable import GETracing
import XCTest

class LoggingTests : TraceAndLabelTestsBase {
	
	func testTraceWithNoLoggers() {
		
		traceEnabledEnforced = true
		
		x$(0)
	}
	
	func testLogWithNoSourceOrLabel() {
		
		logWithNoSourceOrLabel(.inline("foo"))
	}
}
