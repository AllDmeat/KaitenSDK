import Foundation
import HTTPTypes
import Testing

@testable import KaitenSDK

@Suite("Card Baselines")
struct CardBaselinesTests {

  @Test("getCardBaselines 200 returns array")
  func success() async throws {
    let json = """
      [{"id": 1, "card_id": 123}]
      """
    let transport = MockClientTransport.returning(statusCode: 200, body: json)
    let client = try KaitenClient(
      baseURL: "https://test.kaiten.ru/api/latest", token: "t", transport: transport)

    let baselines = try await client.getCardBaselines(cardId: 123)
    #expect(baselines.count == 1)
  }

  @Test("getCardBaselines 200 empty body returns empty array")
  func emptyBody() async throws {
    let transport = MockClientTransport.returning(statusCode: 200, body: nil)
    let client = try KaitenClient(
      baseURL: "https://test.kaiten.ru/api/latest", token: "t", transport: transport)

    let baselines = try await client.getCardBaselines(cardId: 123)
    #expect(baselines.isEmpty)
  }

  @Test("getCardBaselines 401 throws unauthorized")
  func unauthorized() async throws {
    let transport = MockClientTransport.returning(statusCode: 401)
    let client = try KaitenClient(
      baseURL: "https://test.kaiten.ru/api/latest", token: "t", transport: transport)

    await #expect(throws: KaitenError.self) {
      _ = try await client.getCardBaselines(cardId: 123)
    }
  }
}
