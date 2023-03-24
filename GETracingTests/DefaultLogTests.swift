import GETracing
import XCTest

class DefaultLogTests: XCTestCase {

    func testDefaultLog() {
        let oldLogRecord = logRecord
        let oldTraceEnabledEnforced = traceEnabledEnforced
        var capturedRecord: LogRecord!
        logRecord = {
            capturedRecord = $0
        }
        traceEnabledEnforced = true
        defer {
            logRecord = oldLogRecord
            traceEnabledEnforced = oldTraceEnabledEnforced
        }
        x$(true)
        defaultLog(record: capturedRecord)
    }
}
