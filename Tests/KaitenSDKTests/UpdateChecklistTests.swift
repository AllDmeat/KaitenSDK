import Foundation
import HTTPTypes
import Testing

@testable import KaitenSDK

@Suite("UpdateChecklist")
struct UpdateChecklistTests {

  @Test("200 returns updated Checklist")
  func success() async throws {
    let json = """
      {"id": 100, "name": "Renamed checklist"}
      """
    let transport = MockClientTransport.returning(statusCode: 200, body: json)
    let client = try KaitenClient(
      baseURL: "https://test.kaiten.ru/api/latest", token: "test-token", transport: transport)

    let checklist = try await client.updateChecklist(
      cardId: 1, checklistId: 100, name: "Renamed checklist")
    #expect(checklist.id == 100)
    #expect(checklist.name == "Renamed checklist")
  }

  @Test("404 throws notFound")
  func notFound() async throws {
    let transport = MockClientTransport.returning(statusCode: 404)
    let client = try KaitenClient(
      baseURL: "https://test.kaiten.ru/api/latest", token: "test-token", transport: transport)

    await #expect(throws: KaitenError.self) {
      _ = try await client.updateChecklist(cardId: 1, checklistId: 999, name: "x")
    }
  }

  @Test("401 throws unauthorized")
  func unauthorized() async throws {
    let transport = MockClientTransport.returning(statusCode: 401)
    let client = try KaitenClient(
      baseURL: "https://test.kaiten.ru/api/latest", token: "test-token", transport: transport)

    await #expect(throws: KaitenError.self) {
      _ = try await client.updateChecklist(cardId: 1, checklistId: 1, name: "x")
    }
  }
}
