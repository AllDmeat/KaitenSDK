import Foundation
import HTTPTypes
import Testing

@testable import KaitenSDK

@Suite("ListTimeLogs")
struct ListTimeLogsTests {

  @Test("200 returns array of time logs")
  func success() async throws {
    let json = """
      [{"id": 1, "card_id": 42, "user_id": 10, "role_id": -1, "author_id": 10, "updater_id": 10, "time_spent": 60, "for_date": "2025-01-15", "comment": null, "created": "2025-01-15T10:00:00Z", "updated": "2025-01-15T10:00:00Z"}]
      """
    let transport = MockClientTransport.returning(statusCode: 200, body: json)
    let client = try KaitenClient(
      baseURL: "https://test.kaiten.ru/api/latest", token: "test-token", transport: transport)

    let timeLogs = try await client.listTimeLogs(cardId: 42)
    #expect(timeLogs.count == 1)
    #expect(timeLogs[0].time_spent == 60)
  }

  @Test("404 throws notFound")
  func notFound() async throws {
    let transport = MockClientTransport.returning(statusCode: 404)
    let client = try KaitenClient(
      baseURL: "https://test.kaiten.ru/api/latest", token: "test-token", transport: transport)

    await #expect(throws: KaitenError.self) {
      _ = try await client.listTimeLogs(cardId: 999)
    }
  }

  @Test("401 throws unauthorized")
  func unauthorized() async throws {
    let transport = MockClientTransport.returning(statusCode: 401)
    let client = try KaitenClient(
      baseURL: "https://test.kaiten.ru/api/latest", token: "test-token", transport: transport)

    await #expect(throws: KaitenError.self) {
      _ = try await client.listTimeLogs(cardId: 42)
    }
  }
}
