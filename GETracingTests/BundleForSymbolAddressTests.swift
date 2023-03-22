@testable import GETracing
import Foundation

import XCTest

#if !os(Linux)

class BundleForSymbolAddressTests : XCTestCase {
	
	func testDSOHandle() {
		XCTAssertEqual(Bundle(for: BundleForSymbolAddressTests.self), Bundle(for: #dsohandle))
	}
	
	func testWithNonSymbol() {
		var t = 0
		withUnsafePointer(to: &t) { p in
			XCTAssertNil(Bundle(for: p))
		}
	}
	
	func testBundleURLForSharedObject() {
		
		XCTAssertEqual(
			bundleURLFromSharedObjectName("/tmp/Foo.framework/Foo"),
			URL(fileURLWithPath: "/tmp/Foo.framework", isDirectory: true)
		)
		
		XCTAssertEqual(
			bundleURLFromSharedObjectName("/tmp/Foo.framework/Versions/A/Foo"),
			URL(fileURLWithPath: "/tmp/Foo.framework", isDirectory: true)
		)
		
		XCTAssertEqual(
			bundleURLFromSharedObjectName("/tmp/Foo.app/Contents/MacOS/Foo"),
			URL(fileURLWithPath: "/tmp/Foo.app", isDirectory: true)
		)
	}
	
	func testBundleURLForSharedObjectNegatives() {
		
		XCTAssertEqual(
			bundleURLFromSharedObjectName("/tmp/Foo.frameworkX/Foo"),
			nil
		)
		
		XCTAssertEqual(
			bundleURLFromSharedObjectName("/tmp/Foo.framework/Versions/Foo"),
			nil
		)
		
		XCTAssertEqual(
			bundleURLFromSharedObjectName("/tmp/Foo.app/Contents/X/Foo"),
			nil
		)
		XCTAssertEqual(
			bundleURLFromSharedObjectName("/tmp/Foo.app/X/MacOS/Foo"),
			nil
		)
	}
	
	func testCurrent() {
		XCTAssertEqual(Bundle.current, Bundle(for: type(of: self)))
	}
}

#endif
