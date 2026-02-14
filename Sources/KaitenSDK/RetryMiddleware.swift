import Foundation
import HTTPTypes
import OpenAPIRuntime

/// A middleware that retries requests receiving HTTP 429 (Too Many Requests),
/// respecting the `Retry-After` header.
struct RetryMiddleware: ClientMiddleware {
    private let maxAttempts: Int

    init(maxAttempts: Int = 3) {
        self.maxAttempts = maxAttempts
    }

    func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: @Sendable (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        var lastRetryAfter: TimeInterval?

        for _ in 0..<maxAttempts {
            let (response, responseBody) = try await next(request, body, baseURL)

            guard response.status == .tooManyRequests else {
                return (response, responseBody)
            }

            let retryAfter = response.headerFields[HTTPField.Name("Retry-After")!]
                .flatMap(TimeInterval.init)
                ?? 1.0
            lastRetryAfter = retryAfter

            try await Task.sleep(for: .seconds(retryAfter))
        }

        throw KaitenError.rateLimited(retryAfter: lastRetryAfter)
    }
}
