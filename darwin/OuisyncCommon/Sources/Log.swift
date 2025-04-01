import OSLog

/* A version of `OSLog.Logger` that is available on all supported platforms */
public struct Log {
    @usableFromInline let handle: OSLog
    public init(subsystem: String = Bundle.main.bundleIdentifier ?? Constants.baseBundle,
                _ category: String) {
        handle = OSLog(subsystem: subsystem, category: category)
    }
}

public extension Log {
    /** The system only captures debug-level messages in memory when you enable debug logging
     * through a configuration change, and purges them in accordance with the configuration’s
     * persistence setting. */
    @inlinable func debug(_ message: String) { os_log(.debug, log: handle, "%s", message) }

    /** The system stores info-level messages in memory buffers and, without a configuration change,
     * purges the oldest messages as those buffers fill up. However, the system writes the messages
     * to the data store when faults and, optionally, errors occur. Info-level messages remain in
     * the data store until the store’s size exceeds its storage quota, at which point, the system
     * purges the oldest messages in the data store to free up space. */
    @inlinable func info(_ message: String) { os_log(.info, log: handle, "%s", message) }

    /** The system stores default-level messages in memory buffers and, without a configuration
     * change, compresses the messages and writes them to the data store as those buffers fill up.
     * They remain in the data store until the store’s size exceeds its storage quota, at which
     * point, the system purges the oldest messages in the store to free up space. */
    @inlinable func callAsFunction(_ message: String) { os_log(.default, log: handle, "%s", message) }

    /** The system always writes error-level messages to the data store. They remain in the store
     * until its size exceeds its storage quota, at which point, the system purges the oldest
     * messages in the store to free up space. If an activity object exists, logging at this level
     * captures information for the entire process chain. */
    @inlinable func error(_ message: String) { os_log(.error, log: handle, "%s", message) }

    /** The system always writes fault-level messages to the data store. They remain in the store
     * until its size exceeds its storage quota, at which point, the system purges the oldest
     * messages in the store to free up space. If an activity object exists, logging at this level
     * captures information for the entire process chain. */
    @inlinable func fault(_ message: String) { os_log(.debug, log: handle, "%s", message) }
}
