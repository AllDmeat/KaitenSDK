import Foundation
import HTTPTypes
import Testing

@testable import KaitenSDK

@Suite("ListBoards")
struct ListBoardsTests {

    init() {
        setenv("KAITEN_URL", "https://test.kaiten.ru/api/latest", 1)
        setenv("KAITEN_TOKEN", "test-token", 1)
    }

    @Test("200 returns boards")
    func success() async throws {
        let json = """
            [{"id": 1, "title": "Sprint Board"}, {"id": 2, "title": "Kanban"}]
            """
        let transport = MockClientTransport.returning(statusCode: 200, body: json)
        let client = try KaitenClient(transport: transport)

        let boards = try await client.listBoards(spaceId: 5)
        #expect(boards.count == 2)
        #expect(boards[0].id == 1)
        #expect(boards[1].title == "Kanban")
    }

    @Test("200 empty array returns empty")
    func emptyArray() async throws {
        let transport = MockClientTransport.returning(statusCode: 200, body: "[]")
        let client = try KaitenClient(transport: transport)

        let boards = try await client.listBoards(spaceId: 5)
        #expect(boards.isEmpty)
    }
}
