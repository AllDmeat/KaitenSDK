import Foundation
import HTTPTypes
import Testing

@testable import KaitenSDK

@Suite("DeleteCard")
struct DeleteCardTests {

  @Test("200 returns deleted Card")
  func success() async throws {
    let json = """
      {"id": 42, "title": "Deleted card", "condition": 3}
      """
    let transport = MockClientTransport.returning(statusCode: 200, body: json)
    let client = try KaitenClient(
      baseURL: "https://test.kaiten.ru/api/latest", token: "test-token", transport: transport)

    let card = try await client.deleteCard(id: 42)
    #expect(card.id == 42)
  }

  @Test("404 throws notFound")
  func notFound() async throws {
    let transport = MockClientTransport.returning(statusCode: 404)
    let client = try KaitenClient(
      baseURL: "https://test.kaiten.ru/api/latest", token: "test-token", transport: transport)

    await #expect(throws: KaitenError.self) {
      _ = try await client.deleteCard(id: 999)
    }
  }

  @Test("401 throws unauthorized")
  func unauthorized() async throws {
    let transport = MockClientTransport.returning(statusCode: 401)
    let client = try KaitenClient(
      baseURL: "https://test.kaiten.ru/api/latest", token: "test-token", transport: transport)

    await #expect(throws: KaitenError.self) {
      _ = try await client.deleteCard(id: 1)
    }
  }
}
