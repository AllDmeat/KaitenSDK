import Foundation
import HTTPTypes
import Testing

@testable import KaitenSDK

@Suite("ListCardTypes")
struct ListCardTypesTests {

  @Test("200 returns array of card types")
  func success() async throws {
    let json = """
      [{"id": 1, "name": "Epic", "letter": "E", "color": 11, "company_id": 1, "archived": false, "suggest_fields": true, "created": "2025-01-01T00:00:00Z", "updated": "2025-01-01T00:00:00Z"}]
      """
    let transport = MockClientTransport.returning(statusCode: 200, body: json)
    let client = try KaitenClient(
      baseURL: "https://test.kaiten.ru/api/latest", token: "test-token", transport: transport)

    let types = try await client.listCardTypes()
    #expect(types.count == 1)
    #expect(types[0].name == "Epic")
  }

  @Test("401 throws unauthorized")
  func unauthorized() async throws {
    let transport = MockClientTransport.returning(statusCode: 401)
    let client = try KaitenClient(
      baseURL: "https://test.kaiten.ru/api/latest", token: "test-token", transport: transport)

    await #expect(throws: KaitenError.self) {
      _ = try await client.listCardTypes()
    }
  }
}
