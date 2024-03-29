@testable import GETracing
import XCTest

extension LogRecord.Message {
    var inlineValue: Any? {
        switch self {
        case let .inline(value):
            return value
        default:
            return nil
        }
    }

    var inlineValueReflected: String? {
        return inlineValue.flatMap { String(reflecting: $0) }
    }
}

func debugPrinted(_ s: String) -> String {
    return String(reflecting: s)
}

class TraceAndLabelTestsBase: XCTestCase {
    let foo = "bar"
    let bar = "baz"
    var blocksForTearDown = [() -> Void]()

    // MARK: -

    override func setUp() {
        super.setUp()
        let sourceLabelsEnabledEnforcedOldValue = sourceLabelsEnabledEnforced
        blocksForTearDown += [{
            sourceLabelsEnabledEnforced = sourceLabelsEnabledEnforcedOldValue
        }]
        let traceEnabledEnforcedOldValue = traceEnabledEnforced
        blocksForTearDown += [{
            traceEnabledEnforced = traceEnabledEnforcedOldValue
        }]
    }

    override func tearDown() {
        blocksForTearDown.forEach { $0() }
        blocksForTearDown = []
        super.tearDown()
    }
}

class TraceTests: TraceAndLabelTestsBase {
    var tracedRecords = [LogRecord]()
    override func setUp() {
        super.setUp()
        let oldLogRecord = logRecord
        logRecord = {
            self.tracedRecords += [$0]
        }
        blocksForTearDown += [{
            logRecord = oldLogRecord
        }]
    }

    // MARK: -

    func testTraceWithAllThingsDisabled() {
        var evaluated = false
        x$({ evaluated = true }())
        XCTAssertTrue(tracedRecords.isEmpty)
        XCTAssertTrue(evaluated)
    }

    func testNotraceWithAllThingsDisabled() {
        var evaluated = false
        •({ evaluated = true }())
        XCTAssertTrue(tracedRecords.isEmpty)
        XCTAssertFalse(evaluated)
    }

    func testWithTraceEnabled() {
        traceEnabledEnforced = true
        let column_ = #column
        let value = x$(foo); let line = #line
        let fileURL = URL(fileURLWithPath: #file)
        XCTAssertEqual(value, foo)
        XCTAssertEqual(tracedRecords.map { $0.location.line }, [line])
        XCTAssertEqual(tracedRecords.map { $0.location.fileURL }, [fileURL])
        XCTAssertEqual(tracedRecords.map { $0.message.inlineValueReflected! }, ["bar"].map(debugPrinted))
        XCTAssertEqual(tracedRecords.map { $0.label! }, [".\(column_)"])
    }

    func testNestedWithTraceEnabled() {
        traceEnabledEnforced = true
        let innColumn_ = #column
        let column_ = #column
        let value = x$(x$(foo)); let line = #line
        let fileURL = URL(fileURLWithPath: #file)
        XCTAssertEqual(value, foo)
        XCTAssertEqual(tracedRecords.map { $0.location.line }, [line, line])
        XCTAssertEqual(tracedRecords.map { $0.location.fileURL }, [fileURL, fileURL])
        XCTAssertEqual(tracedRecords.map { $0.message.inlineValueReflected! }, ["bar", "bar"].map(debugPrinted))
        XCTAssertEqual(tracedRecords.map { $0.label! }, [".\(innColumn_)", ".\(column_)"])
    }

    func testComplexNestedWithTraceEnabled() {
        traceEnabledEnforced = true
        let innerColumn_______ = #column
        let column_ = #column
        let value = x$("xxx" + x$(foo) + "baz"); let line = #line
        let fileURL = URL(fileURLWithPath: #file)
        XCTAssertEqual(value, "xxx" + foo + "baz")
        XCTAssertEqual(tracedRecords.map { $0.location.line }, [line, line])
        XCTAssertEqual(tracedRecords.map { $0.location.fileURL }, [fileURL, fileURL])
        XCTAssertEqual(tracedRecords.map { $0.message.inlineValueReflected! }, [foo, "xxx" + foo + "baz"].map(debugPrinted))
        XCTAssertEqual(tracedRecords.map { $0.label! }, [".\(innerColumn_______)", ".\(column_)"])
    }

    func testComplexWithTraceEnabled() {
        traceEnabledEnforced = true
        let column_ = #column
        let value = x$("xxx" + foo + "baz"); let line = #line
        let fileURL = URL(fileURLWithPath: #file)
        XCTAssertEqual(value, "xxx" + foo + "baz")
        XCTAssertEqual(tracedRecords.map { $0.location.line }, [line])
        XCTAssertEqual(tracedRecords.map { $0.location.fileURL }, [fileURL])
        XCTAssertEqual(tracedRecords.map { $0.message.inlineValueReflected! }, ["xxx" + foo + "baz"].map(debugPrinted))
        XCTAssertEqual(tracedRecords.map { $0.label! }, [".\(column_)"])
    }

    func testWithTraceAndLabelsEnabled() {
        traceEnabledEnforced = true
        sourceLabelsEnabledEnforced = true
        x$(foo); let line = #line
        let fileURL = URL(fileURLWithPath: #file)
        XCTAssertEqual(tracedRecords.map { $0.location.line }, [line])
        XCTAssertEqual(tracedRecords.map { $0.location.fileURL }, [fileURL])
        XCTAssertEqual(tracedRecords.map { $0.message.inlineValueReflected! }, ["bar"].map(debugPrinted))
        XCTAssertEqual(tracedRecords.map { $0.label! }, ["foo"])
    }

    func testNestedWithTraceAndLabelsEnabled() {
        traceEnabledEnforced = true
        sourceLabelsEnabledEnforced = true
        let value = x$(x$(foo) + "baz"); let line = #line
        let fileURL = URL(fileURLWithPath: #file)
        XCTAssertEqual(value, foo + "baz")
        XCTAssertEqual(tracedRecords.map { $0.location.line }, [line, line])
        XCTAssertEqual(tracedRecords.map { $0.location.fileURL }, [fileURL, fileURL])
        XCTAssertEqual(tracedRecords.map { $0.message.inlineValueReflected! }, ["bar", "barbaz"].map(debugPrinted))
        XCTAssertEqual(tracedRecords.map { $0.label! }, ["foo", "x$(foo) + \"baz\""])
    }

    func testMultiline() {
        traceEnabledEnforced = true
        sourceLabelsEnabledEnforced = true
        let value = x$(min(
            1,
            2
        ))
        XCTAssertEqual(value, 1)
    }
	
    func testMultilineDataSingleLine() {
        traceEnabledEnforced = true
        sourceLabelsEnabledEnforced = true
        let data = "data".data(using: .utf8)!
        let value = x$(.multiline(data))
        XCTAssertEqual(value, data)
    }
	
    func testMultilineDataMultipleLines() {
        traceEnabledEnforced = true
        sourceLabelsEnabledEnforced = true
        let string = """
        	line 1
        	line 2
        	line 3
        """
        let data = string.data(using: .utf8)!
        let value = x$(.multiline(data))
        XCTAssertEqual(value, data)
    }

    func testComplexWithTraceAndLabelsEnabled() {
        traceEnabledEnforced = true
        sourceLabelsEnabledEnforced = true
        let value = x$("xxx" + (foo + bar) + "baz"); let line = #line
        let fileURL = URL(fileURLWithPath: #file)
        XCTAssertEqual(value, "xxx" + foo + bar + "baz")
        XCTAssertEqual(tracedRecords.map { $0.location.line }, [line])
        XCTAssertEqual(tracedRecords.map { $0.location.fileURL }, [fileURL])
        XCTAssertEqual(tracedRecords.map { $0.message.inlineValueReflected! }, ["xxx" + (foo + bar) + "baz"].map(debugPrinted))
        XCTAssertEqual(tracedRecords.map { $0.label! }, ["\"xxx\" + (foo + bar) + \"baz\""])
    }

    func testComplexWithAutoclosuresTraceAndLabelsEnabled() {
        traceEnabledEnforced = true
        sourceLabelsEnabledEnforced = true
        let value = z$("xxx" + (foo + bar) + "baz"); let line = #line
        let fileURL = URL(fileURLWithPath: #file)
        XCTAssertEqual(value, "xxx" + (foo + bar) + "baz")
        XCTAssertEqual(tracedRecords.map { $0.location.line }, [line])
        XCTAssertEqual(tracedRecords.map { $0.location.fileURL }, [fileURL])
        XCTAssertEqual(tracedRecords.map { $0.message.inlineValueReflected! }, ["xxx" + (foo + bar) + "baz"].map(debugPrinted))
        XCTAssertEqual(tracedRecords.map { $0.label! }, ["\"xxx\" + (foo + bar) + \"baz\""])
    }

    func testZeroWithTraceAndLabelsEnabled() {
        traceEnabledEnforced = true
        sourceLabelsEnabledEnforced = true
        let value = x$(0); let line = #line
        let fileURL = URL(fileURLWithPath: #file)
        XCTAssertEqual(value, 0)
        XCTAssertEqual(tracedRecords.map { $0.location.line }, [line])
        XCTAssertEqual(tracedRecords.map { $0.location.fileURL }, [fileURL])
        XCTAssertEqual(tracedRecords.map { $0.message.inlineValueReflected! }, ["0"])
        XCTAssertEqual(tracedRecords.map { $0.label! }, ["0"])
    }

    func testZeroWithAutoclosureTraceAndLabelsEnabled() {
        traceEnabledEnforced = true
        sourceLabelsEnabledEnforced = true
        let value = z$(0); let line = #line
        let fileURL = URL(fileURLWithPath: #file)
        XCTAssertEqual(value, 0)
        XCTAssertEqual(tracedRecords.map { $0.location.line }, [line])
        XCTAssertEqual(tracedRecords.map { $0.location.fileURL }, [fileURL])
        XCTAssertEqual(tracedRecords.map { $0.message.inlineValueReflected! }, ["0"])
        XCTAssertEqual(tracedRecords.map { $0.label! }, ["0"])
    }

    func testWithTraceAndLabelsEnabledAndDumpInTraceEnabled() {
        traceEnabledEnforced = true
        sourceLabelsEnabledEnforced = true
        dumpInTraceEnabledEnforced = true; defer { dumpInTraceEnabledEnforced = nil }
        x$(foo); let line = #line
        let fileURL = URL(fileURLWithPath: #file)
        XCTAssertEqual(tracedRecords.map { $0.location.line }, [line])
        XCTAssertEqual(tracedRecords.map { $0.location.fileURL }, [fileURL])
        XCTAssertEqual(tracedRecords.map { tracedValueDescriptionGenerator($0.message.inlineValue!) }, ["- \"bar\"\n"])
        XCTAssertEqual(tracedRecords.compactMap { $0.label }, ["foo"])
    }

    func testWithTraceLockAndTracingEnabled() {
        traceEnabledEnforced = true
        sourceLabelsEnabledEnforced = true
        let dt = disableTrace(); defer { _ = dt }
        x$(foo)
        XCTAssertTrue(tracedRecords.isEmpty)
    }

    func testWithTraceLockAndTracingDisabled() {
        let dt = disableTrace(); defer { _ = dt }
        x$(foo)
        XCTAssertTrue(tracedRecords.isEmpty)
    }

    func testWithTraceUnlockAndTracingEnabled() {
        traceEnabledEnforced = true
        sourceLabelsEnabledEnforced = true
        let dt = disableTrace(); defer { _ = dt }
        x$(bar)
        let et = enableTrace(); defer { _ = et }
        x$(foo); let line = #line
        let fileURL = URL(fileURLWithPath: #file)
        XCTAssertEqual(tracedRecords.map { $0.location.line }, [line])
        XCTAssertEqual(tracedRecords.map { $0.location.fileURL }, [fileURL])
        XCTAssertEqual(tracedRecords.map { $0.message.inlineValueReflected! }, ["bar"].map(debugPrinted))
        XCTAssertEqual(tracedRecords.map { $0.label! }, ["foo"])
    }

    func testWithTraceUnlockWithoutLockAndTracingEnabled() {
        traceEnabledEnforced = true
        sourceLabelsEnabledEnforced = true
        let et = enableTrace(); defer { _ = et }
        x$(foo); let line = #line
        let fileURL = URL(fileURLWithPath: #file)
        XCTAssertEqual(tracedRecords.map { $0.location.line }, [line])
        XCTAssertEqual(tracedRecords.map { $0.location.fileURL }, [fileURL])
        XCTAssertEqual(tracedRecords.map { $0.message.inlineValueReflected! }, ["bar"].map(debugPrinted))
        XCTAssertEqual(tracedRecords.map { $0.label! }, ["foo"])
    }

    func testWithTraceUnlockAndTracingDisabled() {
        let dt = disableTrace(); defer { _ = dt }
        x$(bar)
        let et = enableTrace(); defer { _ = et }
        x$(foo)
        XCTAssertTrue(tracedRecords.isEmpty)
    }

    func testWithDisabledFile() {
        traceEnabledEnforced = true
        sourceLabelsEnabledEnforced = true
        let oldFilesWithTracingDisabled = filesWithTracingDisabled
        defer { filesWithTracingDisabled = oldFilesWithTracingDisabled }
        filesWithTracingDisabled += [
            URL(fileURLWithPath: #file).lastPathComponent,
        ]
        x$(foo)
        XCTAssertTrue(tracedRecords.isEmpty)
    }
}

class LabelTests: TraceAndLabelTestsBase {
    override func setUp() {
        super.setUp()
        let oldSourceLabelsEnabledEnforced = sourceLabelsEnabledEnforced
        sourceLabelsEnabledEnforced = true
        blocksForTearDown += [{
            sourceLabelsEnabledEnforced = oldSourceLabelsEnabledEnforced
        }]
    }

    // MARK: -

    func testLabeledString() {
        let foo = "bar"
        XCTAssertEqual(L(foo), "foo: \(debugPrinted(foo))")
        sourceLabelsEnabledEnforced = false
        let cln = #column
        let l_ = L(foo)
        XCTAssertEqual(l_, ".\(cln): \(debugPrinted(foo))")
    }

    func testNestedLabeledString() {
        let foo = "bar"
        XCTAssertEqual(L(L(foo)), "L(foo): \"foo: \\\"bar\\\"\"")
        sourceLabelsEnabledEnforced = false
        let cln = #column
        let cln_2 = #column
        let l_ = L(L(foo))
        XCTAssertEqual(l_, ".\(cln): \".\(cln_2): \\\"bar\\\"\"")
    }

    func testLabelWithMissingSource() {
        let s = "foo"
        let sourceFile: StaticString = "/tmp/Missing.swift"
        let cln = #column
        let l_ = L(file: sourceFile, s)
        XCTAssertEqual(l_, ".\(cln):?: \(debugPrinted(s))")
    }

    func testLabelWithNoSource() {
        let s = "foo"
        var v = "foo"
        withUnsafePointer(to: &v) { p in
            let cln = #column
            let l_ = L(dso: p, s)
#if SWIFT_PACKAGE
            XCTAssertEqual(l_, "dso: p, s: \"foo\"")
#else
            XCTAssertEqual(l_, ".\(cln):?: \(debugPrinted(s))")
#endif
        }
    }

    func testLabeledCompoundExpressions() {
        let foo = "bar"
        let optionalFoo = Optional("bar")
        XCTAssertEqual(L("baz" + String(foo.reversed())), "\"baz\" + String(foo.reversed()): \(debugPrinted("baz" + String(foo.reversed())))")
        XCTAssertEqual(L(String(foo.reversed())), "String(foo.reversed()): \(debugPrinted(String(foo.reversed())))")
        XCTAssertEqual(L(optionalFoo!), "optionalFoo!: \(debugPrinted(optionalFoo!))")
        let fileManager = FileManager.default
        let storePath = "/tmp/xxx"
        XCTAssertEqual(L(fileManager.fileExists(atPath: storePath)), "fileManager.fileExists(atPath: storePath): false")
    }
}
