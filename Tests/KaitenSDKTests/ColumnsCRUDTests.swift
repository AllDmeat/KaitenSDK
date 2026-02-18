import Foundation
import HTTPTypes
import Testing

@testable import KaitenSDK

@Suite("Columns CRUD")
struct ColumnsCRUDTests {

  // MARK: - createColumn

  @Test("createColumn 200 returns created Column")
  func createColumnSuccess() async throws {
    let json = """
      {"id": 100, "title": "To Do", "board_id": 10}
      """
    let transport = MockClientTransport.returning(statusCode: 200, body: json)
    let client = try KaitenClient(
      baseURL: "https://test.kaiten.ru/api/latest", token: "t", transport: transport)

    let column = try await client.createColumn(boardId: 10, title: "To Do")
    #expect(column.id == 100)
    #expect(column.title == "To Do")
  }

  @Test("createColumn 401 throws unauthorized")
  func createColumnUnauthorized() async throws {
    let transport = MockClientTransport.returning(statusCode: 401)
    let client = try KaitenClient(
      baseURL: "https://test.kaiten.ru/api/latest", token: "t", transport: transport)

    await #expect(throws: KaitenError.self) {
      _ = try await client.createColumn(boardId: 10, title: "Test")
    }
  }

  @Test("createColumn 404 throws notFound (board not found)")
  func createColumnBoardNotFound() async throws {
    let transport = MockClientTransport.returning(statusCode: 404)
    let client = try KaitenClient(
      baseURL: "https://test.kaiten.ru/api/latest", token: "t", transport: transport)

    await #expect(throws: KaitenError.self) {
      _ = try await client.createColumn(boardId: 999, title: "Test")
    }
  }

  // MARK: - updateColumn

  @Test("updateColumn 200 returns updated Column")
  func updateColumnSuccess() async throws {
    let json = """
      {"id": 100, "title": "In Progress", "board_id": 10}
      """
    let transport = MockClientTransport.returning(statusCode: 200, body: json)
    let client = try KaitenClient(
      baseURL: "https://test.kaiten.ru/api/latest", token: "t", transport: transport)

    let column = try await client.updateColumn(boardId: 10, id: 100, title: "In Progress")
    #expect(column.id == 100)
    #expect(column.title == "In Progress")
  }

  @Test("updateColumn 404 throws notFound")
  func updateColumnNotFound() async throws {
    let transport = MockClientTransport.returning(statusCode: 404)
    let client = try KaitenClient(
      baseURL: "https://test.kaiten.ru/api/latest", token: "t", transport: transport)

    await #expect(throws: KaitenError.self) {
      _ = try await client.updateColumn(boardId: 10, id: 999, title: "Test")
    }
  }

  // MARK: - deleteColumn

  @Test("deleteColumn 200 returns deleted id")
  func deleteColumnSuccess() async throws {
    let json = """
      {"id": 100}
      """
    let transport = MockClientTransport.returning(statusCode: 200, body: json)
    let client = try KaitenClient(
      baseURL: "https://test.kaiten.ru/api/latest", token: "t", transport: transport)

    let deletedId = try await client.deleteColumn(boardId: 10, id: 100)
    #expect(deletedId == 100)
  }

  @Test("deleteColumn 404 throws notFound")
  func deleteColumnNotFound() async throws {
    let transport = MockClientTransport.returning(statusCode: 404)
    let client = try KaitenClient(
      baseURL: "https://test.kaiten.ru/api/latest", token: "t", transport: transport)

    await #expect(throws: KaitenError.self) {
      _ = try await client.deleteColumn(boardId: 10, id: 999)
    }
  }
}
