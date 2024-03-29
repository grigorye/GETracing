import Foundation

func bundleURLFromSharedObjectName(_ objectName: String) -> URL? {
	
    let objectURL = URL(fileURLWithPath: objectName)
    let objectParentURL = objectURL.deletingLastPathComponent()
	
    guard !["app", "xctest", "framework"].contains(objectParentURL.pathExtension) else {
		
        // .{app|xctest|framework}/SharedObject
        return objectParentURL
    }
	
    let objectGrandparentURL = objectParentURL.deletingLastPathComponent()
    let objectGrandgrandparentURL = objectGrandparentURL.deletingLastPathComponent()
	
    guard objectParentURL.lastPathComponent != "MacOS" else {
        guard objectGrandparentURL.lastPathComponent == "Contents" else {
			
            return nil
        }
		
        // .{app|xctest}/Contents/MacOS/SharedObject
        assert(["app", "xctest"].contains(objectGrandgrandparentURL.pathExtension))
        return objectGrandgrandparentURL
    }
	
    guard objectGrandparentURL.lastPathComponent != "Versions" else {
		
        // .framework/Versions/X/SharedObject
        assert(objectGrandgrandparentURL.pathExtension == "framework")
        return objectGrandgrandparentURL
    }
	
    return nil
}

#if !os(Linux)

extension Bundle {
	
    class var current: Bundle! {
        guard let uintValue = some(Thread.callStackReturnAddresses[1].uintValue) else {
            return nil
        }
        guard let pointer = some(UnsafeRawPointer(bitPattern: uintValue)) else {
            return nil
        }
        guard let bundle = some(Bundle(for: pointer)) else {
            return nil
        }
        return bundle
    }
}

extension Bundle {
	
    public convenience init?(for symbolAddr: UnsafeRawPointer) {
		
        var info = Dl_info()
        guard dladdr(symbolAddr, &info) != 0 else {
            return nil
        }
		
        let sharedObjectName = String(validatingUTF8: info.dli_fname)!
        guard let bundleURL = bundleURLFromSharedObjectName(sharedObjectName) else {
			
            assertionFailure("Couldn't get bundle for \(sharedObjectName).")
            return nil
        }
		
        self.init(url: bundleURL)
    }
}

#endif
