import Foundation
import HTTPTypes
import Testing

@testable import KaitenSDK

@Suite("Subcolumns CRUD")
struct SubcolumnsCRUDTests {

  // MARK: - listSubcolumns

  @Test("listSubcolumns 200 returns array")
  func listSubcolumnsSuccess() async throws {
    let json = """
      [{"id": 301, "title": "Sub A"}, {"id": 302, "title": "Sub B"}]
      """
    let transport = MockClientTransport.returning(statusCode: 200, body: json)
    let client = try KaitenClient(
      baseURL: "https://test.kaiten.ru/api/latest", token: "t", transport: transport)

    let subcolumns = try await client.listSubcolumns(columnId: 100)
    #expect(subcolumns.count == 2)
    #expect(subcolumns[0].id == 301)
  }

  @Test("listSubcolumns 200 empty body returns empty array")
  func listSubcolumnsEmpty() async throws {
    let transport = MockClientTransport.returning(statusCode: 200, body: nil)
    let client = try KaitenClient(
      baseURL: "https://test.kaiten.ru/api/latest", token: "t", transport: transport)

    let subcolumns = try await client.listSubcolumns(columnId: 100)
    #expect(subcolumns.isEmpty)
  }

  @Test("listSubcolumns 404 throws notFound")
  func listSubcolumnsNotFound() async throws {
    let transport = MockClientTransport.returning(statusCode: 404)
    let client = try KaitenClient(
      baseURL: "https://test.kaiten.ru/api/latest", token: "t", transport: transport)

    await #expect(throws: KaitenError.self) {
      _ = try await client.listSubcolumns(columnId: 999)
    }
  }

  // MARK: - createSubcolumn

  @Test("createSubcolumn 200 returns created Column")
  func createSubcolumnSuccess() async throws {
    let json = """
      {"id": 301, "title": "Review"}
      """
    let transport = MockClientTransport.returning(statusCode: 200, body: json)
    let client = try KaitenClient(
      baseURL: "https://test.kaiten.ru/api/latest", token: "t", transport: transport)

    let sub = try await client.createSubcolumn(columnId: 100, title: "Review")
    #expect(sub.id == 301)
    #expect(sub.title == "Review")
  }

  @Test("createSubcolumn 404 throws notFound")
  func createSubcolumnNotFound() async throws {
    let transport = MockClientTransport.returning(statusCode: 404)
    let client = try KaitenClient(
      baseURL: "https://test.kaiten.ru/api/latest", token: "t", transport: transport)

    await #expect(throws: KaitenError.self) {
      _ = try await client.createSubcolumn(columnId: 999, title: "Test")
    }
  }

  // MARK: - updateSubcolumn

  @Test("updateSubcolumn 200 returns updated Column")
  func updateSubcolumnSuccess() async throws {
    let json = """
      {"id": 301, "title": "Code Review"}
      """
    let transport = MockClientTransport.returning(statusCode: 200, body: json)
    let client = try KaitenClient(
      baseURL: "https://test.kaiten.ru/api/latest", token: "t", transport: transport)

    let sub = try await client.updateSubcolumn(columnId: 100, id: 301, title: "Code Review")
    #expect(sub.id == 301)
    #expect(sub.title == "Code Review")
  }

  @Test("updateSubcolumn 404 throws notFound")
  func updateSubcolumnNotFound() async throws {
    let transport = MockClientTransport.returning(statusCode: 404)
    let client = try KaitenClient(
      baseURL: "https://test.kaiten.ru/api/latest", token: "t", transport: transport)

    await #expect(throws: KaitenError.self) {
      _ = try await client.updateSubcolumn(columnId: 100, id: 999, title: "Test")
    }
  }

  // MARK: - deleteSubcolumn

  @Test("deleteSubcolumn 200 returns deleted id")
  func deleteSubcolumnSuccess() async throws {
    let json = """
      {"id": 301}
      """
    let transport = MockClientTransport.returning(statusCode: 200, body: json)
    let client = try KaitenClient(
      baseURL: "https://test.kaiten.ru/api/latest", token: "t", transport: transport)

    let deletedId = try await client.deleteSubcolumn(columnId: 100, id: 301)
    #expect(deletedId == 301)
  }

  @Test("deleteSubcolumn 404 throws notFound")
  func deleteSubcolumnNotFound() async throws {
    let transport = MockClientTransport.returning(statusCode: 404)
    let client = try KaitenClient(
      baseURL: "https://test.kaiten.ru/api/latest", token: "t", transport: transport)

    await #expect(throws: KaitenError.self) {
      _ = try await client.deleteSubcolumn(columnId: 100, id: 999)
    }
  }
}
