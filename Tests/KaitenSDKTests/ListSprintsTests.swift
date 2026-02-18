import Foundation
import HTTPTypes
import Testing

@testable import KaitenSDK

@Suite("ListSprints")
struct ListSprintsTests {

  @Test("200 returns array of sprints")
  func success() async throws {
    let json = """
      [{"id": 1, "board_id": 10, "title": "Sprint 1", "goal": null, "active": true, "committed": 5, "velocity": 21.0, "creator_id": 1, "updater_id": 1, "start_date": "2025-01-01", "finish_date": "2025-01-14", "actual_finish_date": null, "archived": false, "created": "2025-01-01T00:00:00Z", "updated": "2025-01-01T00:00:00Z"}]
      """
    let transport = MockClientTransport.returning(statusCode: 200, body: json)
    let client = try KaitenClient(
      baseURL: "https://test.kaiten.ru/api/latest", token: "test-token", transport: transport)

    let sprints = try await client.listSprints()
    #expect(sprints.count == 1)
    #expect(sprints[0].title == "Sprint 1")
  }

  @Test("401 throws unauthorized")
  func unauthorized() async throws {
    let transport = MockClientTransport.returning(statusCode: 401)
    let client = try KaitenClient(
      baseURL: "https://test.kaiten.ru/api/latest", token: "test-token", transport: transport)

    await #expect(throws: KaitenError.self) {
      _ = try await client.listSprints()
    }
  }
}
