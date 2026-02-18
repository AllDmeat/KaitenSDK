import Foundation
import HTTPTypes
import Testing

@testable import KaitenSDK

@Suite("Sprint Summary")
struct SprintSummaryTests {

  @Test("getSprintSummary 200 returns summary")
  func success() async throws {
    let json = """
      {"id": 5, "title": "Sprint 5"}
      """
    let transport = MockClientTransport.returning(statusCode: 200, body: json)
    let client = try KaitenClient(
      baseURL: "https://test.kaiten.ru/api/latest", token: "t", transport: transport)

    let summary = try await client.getSprintSummary(id: 5)
    #expect(summary.id == 5)
  }

  @Test("getSprintSummary 404 throws notFound")
  func notFound() async throws {
    let transport = MockClientTransport.returning(statusCode: 404)
    let client = try KaitenClient(
      baseURL: "https://test.kaiten.ru/api/latest", token: "t", transport: transport)

    await #expect(throws: KaitenError.self) {
      _ = try await client.getSprintSummary(id: 999)
    }
  }

  @Test("getSprintSummary 401 throws unauthorized")
  func unauthorized() async throws {
    let transport = MockClientTransport.returning(statusCode: 401)
    let client = try KaitenClient(
      baseURL: "https://test.kaiten.ru/api/latest", token: "t", transport: transport)

    await #expect(throws: KaitenError.self) {
      _ = try await client.getSprintSummary(id: 5)
    }
  }
}
