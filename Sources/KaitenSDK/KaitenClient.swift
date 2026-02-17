import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

/// Main entry point for the Kaiten SDK.
///
/// Accepts explicit `baseURL` and `token` parameters.
public struct KaitenClient: Sendable {
    private let client: Client

    // MARK: - Initialization

    /// Creates a client with a custom transport (for testing).
    ///
    /// - Parameters:
    ///   - baseURL: Full Kaiten API base URL (e.g. `https://mycompany.kaiten.ru/api/latest`).
    ///   - token: API bearer token.
    ///   - transport: Custom `ClientTransport` implementation.
    /// - Throws: ``KaitenError/invalidURL(_:)`` if `baseURL` cannot be parsed.
    init(baseURL: String, token: String, transport: any ClientTransport) throws(KaitenError) {
        let url = try URL(string: baseURL)
            .orThrow(KaitenError.invalidURL(baseURL))
        self.client = Client(
            serverURL: url,
            transport: transport,
            middlewares: [
                AuthenticationMiddleware(token: token),
                RetryMiddleware(),
            ]
        )
    }

    /// Creates a new Kaiten API client.
    ///
    /// - Parameters:
    ///   - baseURL: Full Kaiten API base URL (e.g. `https://mycompany.kaiten.ru/api/latest`).
    ///   - token: API bearer token.
    /// - Throws: ``KaitenError/invalidURL(_:)`` if `baseURL` cannot be parsed.
    public init(baseURL: String, token: String) throws(KaitenError) {
        let url = try URL(string: baseURL)
            .orThrow(KaitenError.invalidURL(baseURL))

        self.client = Client(
            serverURL: url,
            transport: URLSessionTransport(),
            middlewares: [
                AuthenticationMiddleware(token: token),
                RetryMiddleware(),
            ]
        )
    }

    // MARK: - Private Helpers

    /// Executes an API call, wrapping non-KaitenError into `.networkError`.
    private func call<T>(_ operation: () async throws -> T) async throws(KaitenError) -> T {
        do {
            return try await operation()
        } catch let error as KaitenError {
            throw error
        } catch {
            throw .networkError(underlying: error)
        }
    }

    /// Executes an API call for list endpoints.
    /// Returns `nil` when Kaiten returns HTTP 200 with an empty body (no JSON),
    /// allowing callers to fall back to an empty array.
    private func callList<T>(_ operation: () async throws -> T) async throws(KaitenError) -> T? {
        do {
            return try await operation()
        } catch let error as ClientError where error.response?.status == .ok {
            return nil
        } catch let error as KaitenError {
            throw error
        } catch {
            throw .networkError(underlying: error)
        }
    }

    /// Decodes a value, wrapping errors into `.decodingError`.
    private func decode<T>(_ extract: () throws -> T) throws(KaitenError) -> T {
        do {
            return try extract()
        } catch {
            throw .decodingError(underlying: error)
        }
    }

    /// Standard response case from an OpenAPI-generated Output enum.
    /// Used by `handleResponse` to eliminate switch boilerplate.
    enum ResponseCase<OKBody> {
        case ok(OKBody)
        case unauthorized
        case forbidden
        case notFound
        case undocumented(statusCode: Int)
    }

    /// Handles a standard response by extracting the ok body or throwing the appropriate error.
    /// The `ok` closure receives the body and should extract the JSON value.
    private func handleResponse<OKBody, JSONBody, T>(
        _ responseCase: ResponseCase<OKBody>,
        notFoundResource: (name: String, id: Int)? = nil,
        extract: (OKBody) -> JSONBody,
        transform: (JSONBody) throws(KaitenError) -> T
    ) throws(KaitenError) -> T {
        switch responseCase {
        case .ok(let body):
            return try transform(extract(body))
        case .unauthorized:
            throw .unauthorized
        case .forbidden:
            throw .unexpectedResponse(statusCode: 403)
        case .notFound:
            if let res = notFoundResource {
                throw .notFound(resource: res.name, id: res.id)
            }
            throw .unexpectedResponse(statusCode: 404)
        case .undocumented(let code):
            throw .unexpectedResponse(statusCode: code)
        }
    }

    /// Convenience: handle response, decode JSON body.
    private func decodeResponse<OKBody, T: Sendable>(
        _ responseCase: ResponseCase<OKBody>,
        notFoundResource: (name: String, id: Int)? = nil,
        json: (OKBody) throws -> T
    ) throws(KaitenError) -> T {
        switch responseCase {
        case .ok(let body):
            return try decode { try json(body) }
        case .unauthorized:
            throw .unauthorized
        case .forbidden:
            throw .unexpectedResponse(statusCode: 403)
        case .notFound:
            if let res = notFoundResource {
                throw .notFound(resource: res.name, id: res.id)
            }
            throw .unexpectedResponse(statusCode: 404)
        case .undocumented(let code):
            throw .unexpectedResponse(statusCode: code)
        }
    }

    // MARK: - Cards

    /// Returns a page of cards for the given board.
    ///
    /// - Parameters:
    ///   - boardId: The board identifier.
    ///   - offset: Number of cards to skip (default `0`).
    ///   - limit: Maximum number of cards to return (default `100`).
    /// - Returns: A ``Page`` of cards. Returns an empty page when the board has no cards.
    /// - Throws: ``KaitenError``
    public func listCards(boardId: Int, offset: Int = 0, limit: Int = 100) async throws(KaitenError) -> Page<Components.Schemas.Card> {
        guard let response = try await callList({ try await client.get_cards(query: .init(board_id: boardId, offset: offset, limit: limit)) }) else {
            return Page(items: [], offset: offset, limit: limit)
        }
        let items: [Components.Schemas.Card] = try decodeResponse(response.toCase()) { try $0.json }
        return Page(items: items, offset: offset, limit: limit)
    }

    /// Fetches a single card by its identifier.
    ///
    /// - Parameter id: The card identifier.
    /// - Returns: The full card object with all fields including custom properties.
    /// - Throws: ``KaitenError/notFound(resource:id:)`` if the card does not exist.
    public func getCard(id: Int) async throws(KaitenError) -> Components.Schemas.Card {
        let response = try await call { try await client.get_card(path: .init(card_id: id)) }
        return try decodeResponse(response.toCase(), notFoundResource: ("card", id)) { try $0.json }
    }

    // MARK: - Card Members

    /// Fetches the list of members assigned to a card.
    ///
    /// - Parameter cardId: The card identifier.
    /// - Returns: An array of detailed member objects. Returns an empty array if no members are assigned.
    /// - Throws: ``KaitenError``
    public func getCardMembers(cardId: Int) async throws(KaitenError) -> [Components.Schemas.MemberDetailed] {
        guard let response = try await callList({ try await client.retrieve_list_of_card_members(path: .init(card_id: cardId)) }) else {
            return []
        }
        return try decodeResponse(response.toCase()) { try $0.json }
    }

    /// Fetches all comments on a card.
    ///
    /// - Parameter cardId: The card identifier.
    /// - Returns: An array of comments. Returns an empty array if the card has no comments.
    /// - Throws: ``KaitenError/notFound(resource:id:)`` if the card does not exist.
    public func getCardComments(cardId: Int) async throws(KaitenError) -> [Components.Schemas.Comment] {
        guard let response = try await callList({ try await client.retrieve_card_comments(path: .init(card_id: cardId)) }) else {
            return []
        }
        return try decodeResponse(response.toCase(), notFoundResource: ("card", cardId)) { try $0.json }
    }
}

// MARK: - Custom Properties

extension KaitenClient {
    /// Lists all custom property definitions for the company.
    ///
    /// Custom properties are company-wide field definitions (e.g. "Team", "Platform")
    /// that can be attached to cards.
    ///
    /// - Parameters:
    ///   - offset: Number of properties to skip (default `0`).
    ///   - limit: Maximum number of properties to return (default `100`).
    /// - Returns: A ``Page`` of custom property definitions.
    /// - Throws: ``KaitenError``
    public func listCustomProperties(offset: Int = 0, limit: Int = 100) async throws(KaitenError) -> Page<Components.Schemas.CustomProperty> {
        guard let response = try await callList({ try await client.get_list_of_properties(query: .init(offset: offset, limit: limit)) }) else {
            return Page(items: [], offset: offset, limit: limit)
        }
        let items: [Components.Schemas.CustomProperty] = try decodeResponse(response.toCase()) { try $0.json }
        return Page(items: items, offset: offset, limit: limit)
    }

    /// Fetches a single custom property definition by its identifier.
    ///
    /// - Parameter id: The custom property identifier.
    /// - Returns: The custom property definition.
    /// - Throws: ``KaitenError/notFound(resource:id:)`` if the property does not exist.
    public func getCustomProperty(id: Int) async throws(KaitenError) -> Components.Schemas.CustomProperty {
        let response = try await call { try await client.get_property(path: .init(id: id)) }
        return try decodeResponse(response.toCase(), notFoundResource: ("customProperty", id)) { try $0.json }
    }
}

// MARK: - Boards

extension KaitenClient {
    /// Fetches a board by its identifier.
    ///
    /// Returns the full board object including columns, lanes, and cards.
    ///
    /// - Parameter id: The board identifier.
    /// - Returns: The full board object.
    /// - Throws: ``KaitenError/notFound(resource:id:)`` if the board does not exist.
    public func getBoard(id: Int) async throws(KaitenError) -> Components.Schemas.Board {
        let response = try await call { try await client.get_board(path: .init(id: id)) }
        return try decodeResponse(response.toCase(), notFoundResource: ("board", id)) { try $0.json }
    }

    /// Fetches all columns for a board.
    ///
    /// - Parameter boardId: The board identifier.
    /// - Returns: An array of columns. Returns an empty array if the board has no columns.
    /// - Throws: ``KaitenError/notFound(resource:id:)`` if the board does not exist.
    public func getBoardColumns(boardId: Int) async throws(KaitenError) -> [Components.Schemas.Column] {
        guard let response = try await callList({ try await client.get_list_of_columns(path: .init(board_id: boardId)) }) else {
            return []
        }
        return try decodeResponse(response.toCase(), notFoundResource: ("board", boardId)) { try $0.json }
    }

    /// Fetches all lanes (horizontal swimlanes) for a board.
    ///
    /// - Parameter boardId: The board identifier.
    /// - Returns: An array of lanes. Returns an empty array if the board has no lanes.
    /// - Throws: ``KaitenError/notFound(resource:id:)`` if the board does not exist.
    public func getBoardLanes(boardId: Int) async throws(KaitenError) -> [Components.Schemas.Lane] {
        guard let response = try await callList({ try await client.get_list_of_lanes(path: .init(board_id: boardId)) }) else {
            return []
        }
        return try decodeResponse(response.toCase(), notFoundResource: ("board", boardId)) { try $0.json }
    }
}

// MARK: - Spaces

extension KaitenClient {
    /// Lists all spaces visible to the authenticated user.
    ///
    /// - Returns: An array of spaces. Returns an empty array if no spaces are available.
    /// - Throws: ``KaitenError``
    public func listSpaces() async throws(KaitenError) -> [Components.Schemas.Space] {
        guard let response = try await callList({ try await client.retrieve_list_of_spaces() }) else {
            return []
        }
        return try decodeResponse(response.toCase()) { try $0.json }
    }

    /// Lists all boards within a space.
    ///
    /// - Parameter spaceId: The space identifier.
    /// - Returns: An array of boards. Returns an empty array if the space has no boards.
    /// - Throws: ``KaitenError/notFound(resource:id:)`` if the space does not exist.
    public func listBoards(spaceId: Int) async throws(KaitenError) -> [Components.Schemas.BoardInSpace] {
        guard let response = try await callList({ try await client.get_list_of_boards(path: .init(space_id: spaceId)) }) else {
            return []
        }
        return try decodeResponse(response.toCase(), notFoundResource: ("space", spaceId)) { try $0.json }
    }
}

// MARK: - Helpers

extension Optional {
    func orThrow(_ error: @autoclosure () -> KaitenError) throws(KaitenError) -> Wrapped {
        guard let self else { throw error() }
        return self
    }
}
