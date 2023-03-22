import Dispatch

extension DispatchQueue {
	
	/// Returns label suitable for logging.
	public class var currentQueueLabel: String? {
        #if os(Linux)
        return "unknown-linux"
        #else
		let ptr = __dispatch_queue_get_label(nil)
		return String(validatingUTF8: ptr)
        #endif
	}
}
