import Foundation
import HTTPTypes
import Testing

@testable import KaitenSDK

@Suite("UpdateComment")
struct UpdateCommentTests {

  @Test("200 returns updated Comment")
  func success() async throws {
    let json = """
      {"id": 100, "uid": "abc-123", "text": "Updated text", "type": 1, "edited": true, "card_id": 42, "author_id": 5, "internal": false, "deleted": false, "sd_description": false, "updated": "2026-02-18T03:13:29Z", "created": "2026-02-17T13:05:28Z"}
      """
    let transport = MockClientTransport.returning(statusCode: 200, body: json)
    let client = try KaitenClient(
      baseURL: "https://test.kaiten.ru/api/latest", token: "test-token", transport: transport)

    let comment = try await client.updateComment(cardId: 42, commentId: 100, text: "Updated text")
    #expect(comment.id == 100)
    #expect(comment.text == "Updated text")
    #expect(comment.edited == true)
  }

  @Test("404 throws notFound")
  func notFound() async throws {
    let transport = MockClientTransport.returning(statusCode: 404)
    let client = try KaitenClient(
      baseURL: "https://test.kaiten.ru/api/latest", token: "test-token", transport: transport)

    await #expect(throws: KaitenError.self) {
      _ = try await client.updateComment(cardId: 42, commentId: 999, text: "x")
    }
  }

  @Test("401 throws unauthorized")
  func unauthorized() async throws {
    let transport = MockClientTransport.returning(statusCode: 401)
    let client = try KaitenClient(
      baseURL: "https://test.kaiten.ru/api/latest", token: "test-token", transport: transport)

    await #expect(throws: KaitenError.self) {
      _ = try await client.updateComment(cardId: 42, commentId: 100, text: "x")
    }
  }
}
