/// This is a workaround for an awkward pre-concurrency API that does not allow async `RAII`
@MainActor class Future<T> {
    public var value: T { get async throws {
        if let result { return try result.get() }
        return try await withUnsafeThrowingContinuation { pending.append($0) }
    } }

    private var result: Result<T, any Error>?
    private var pending: [UnsafeContinuation<T, any Error>] = []

    nonisolated init(resultOf cb: @escaping () async throws -> T) { Task { @MainActor in
        do { result = try await .success(cb()) }
        catch { result = .failure(error) }
        self.pending.forEach { $0.resume(with: result!) }
        self.pending.removeAll(keepingCapacity: false)
    } }
}
