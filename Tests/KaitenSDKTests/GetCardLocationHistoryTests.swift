import Foundation
import HTTPTypes
import Testing

@testable import KaitenSDK

@Suite("GetCardLocationHistory")
struct GetCardLocationHistoryTests {

  @Test("200 returns array of history entries")
  func success() async throws {
    let json = """
      [{"id": 1, "card_id": 42, "board_id": 10, "column_id": 100, "subcolumn_id": null, "lane_id": 200, "sprint_id": null, "author_id": 5, "condition": 1, "changed": "2025-01-15T10:00:00Z"}]
      """
    let transport = MockClientTransport.returning(statusCode: 200, body: json)
    let client = try KaitenClient(
      baseURL: "https://test.kaiten.ru/api/latest", token: "test-token", transport: transport)

    let history = try await client.getCardLocationHistory(cardId: 42)
    #expect(history.count == 1)
    #expect(history[0].card_id == 42)
  }

  @Test("404 throws notFound")
  func notFound() async throws {
    let transport = MockClientTransport.returning(statusCode: 404)
    let client = try KaitenClient(
      baseURL: "https://test.kaiten.ru/api/latest", token: "test-token", transport: transport)

    await #expect(throws: KaitenError.self) {
      _ = try await client.getCardLocationHistory(cardId: 999)
    }
  }

  @Test("401 throws unauthorized")
  func unauthorized() async throws {
    let transport = MockClientTransport.returning(statusCode: 401)
    let client = try KaitenClient(
      baseURL: "https://test.kaiten.ru/api/latest", token: "test-token", transport: transport)

    await #expect(throws: KaitenError.self) {
      _ = try await client.getCardLocationHistory(cardId: 42)
    }
  }
}
