import Foundation
import HTTPTypes
import Testing

@testable import KaitenSDK

@Suite("DeleteComment")
struct DeleteCommentTests {

  @Test("200 returns deleted comment ID")
  func success() async throws {
    let json = """
      {"id": 456}
      """
    let transport = MockClientTransport.returning(statusCode: 200, body: json)
    let client = try KaitenClient(
      baseURL: "https://test.kaiten.ru/api/latest", token: "test-token", transport: transport)

    let deletedId = try await client.deleteComment(cardId: 42, commentId: 456)
    #expect(deletedId == 456)
  }

  @Test("404 throws notFound")
  func notFound() async throws {
    let transport = MockClientTransport.returning(statusCode: 404)
    let client = try KaitenClient(
      baseURL: "https://test.kaiten.ru/api/latest", token: "test-token", transport: transport)

    await #expect(throws: KaitenError.self) {
      _ = try await client.deleteComment(cardId: 42, commentId: 999)
    }
  }

  @Test("401 throws unauthorized")
  func unauthorized() async throws {
    let transport = MockClientTransport.returning(statusCode: 401)
    let client = try KaitenClient(
      baseURL: "https://test.kaiten.ru/api/latest", token: "test-token", transport: transport)

    await #expect(throws: KaitenError.self) {
      _ = try await client.deleteComment(cardId: 42, commentId: 456)
    }
  }
}
