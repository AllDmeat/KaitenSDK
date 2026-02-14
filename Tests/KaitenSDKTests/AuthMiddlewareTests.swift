import Foundation
import HTTPTypes
import OpenAPIRuntime
import Synchronization
import Testing

@testable import KaitenSDK

@Suite("AuthenticationMiddleware")
struct AuthMiddlewareTests {

    @Test("Adds Bearer token header")
    func addsBearer() async throws {
        let middleware = AuthenticationMiddleware(token: "my-secret-token")
        let capturedRequest = Mutex<HTTPRequest?>(nil)

        let _ = try await middleware.intercept(
            HTTPRequest(method: .get, scheme: "https", authority: "test.kaiten.ru", path: "/test"),
            body: nil,
            baseURL: URL(string: "https://test.kaiten.ru")!,
            operationID: "test"
        ) { request, body, baseURL in
            capturedRequest.withLock { $0 = request }
            return (HTTPResponse(status: .ok), nil)
        }

        let header = capturedRequest.withLock { $0?.headerFields[.authorization] }
        #expect(header == "Bearer my-secret-token")
    }

    @Test("Passes through 401 without throwing")
    func passesThrough401() async throws {
        let middleware = AuthenticationMiddleware(token: "bad-token")

        let (response, _) = try await middleware.intercept(
            HTTPRequest(method: .get, scheme: "https", authority: "test.kaiten.ru", path: "/test"),
            body: nil,
            baseURL: URL(string: "https://test.kaiten.ru")!,
            operationID: "test"
        ) { _, _, _ in
            (HTTPResponse(status: .unauthorized), nil)
        }

        #expect(response.status == .unauthorized)
    }
}
