@testable import GETracing
import XCTest

let playgroundFile = #file

class PlaygroundSupportTests : TraceAndLabelTestsBase {
	
	func testSimple() {
		
		traceEnabledEnforced = true
		sourceLabelsEnabledEnforced = true
		
		_ = x$(0)
	}
}
