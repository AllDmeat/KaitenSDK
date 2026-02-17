import Foundation
import HTTPTypes
import OpenAPIRuntime

/// A middleware that injects a Bearer token into every outgoing request.
struct AuthenticationMiddleware: ClientMiddleware {
  private let token: String

  init(token: String) {
    self.token = token
  }

  func intercept(
    _ request: HTTPRequest,
    body: HTTPBody?,
    baseURL: URL,
    operationID: String,
    next: @Sendable (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
  ) async throws -> (HTTPResponse, HTTPBody?) {
    var request = request
    request.headerFields[.authorization] = "Bearer \(token)"
    return try await next(request, body, baseURL)
  }
}
