import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

/// Main entry point for the Kaiten SDK.
///
/// Accepts explicit `baseURL` and `token` parameters.
public struct KaitenClient: Sendable {
    private let client: Client
    private let config: KaitenConfiguration

    // MARK: - Initialization

    /// Internal initializer for testing with a custom transport.
    /// Internal initializer for testing with a custom transport and explicit config.
    init(baseURL: String, token: String, transport: any ClientTransport) throws(KaitenError) {
        self.config = KaitenConfiguration(baseURL: baseURL, token: token)
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

    public init(baseURL: String, token: String) throws(KaitenError) {
        self.config = KaitenConfiguration(baseURL: baseURL, token: token)

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

    // MARK: - Cards

    /// Returns all cards for the given board.
    ///
    /// - Parameter boardId: The board to fetch cards from.
    /// - Returns: An array of ``Components/Schemas/Card``.
    /// - Throws: ``KaitenError/unauthorized`` or ``KaitenError/unexpectedResponse(statusCode:)``.
    public func listCards(boardId: Int) async throws(KaitenError) -> [Components.Schemas.Card] {
        let response: Operations.get_cards.Output
        do {
            response = try await client.get_cards(query: .init(board_id: boardId))
        } catch let error as ClientError where error.response?.status == .ok {
            // Kaiten returns HTTP 200 with empty body when a board has no cards (#84).
            // OpenAPI runtime throws ClientError for missing/empty response body.
            return []
        } catch let error as KaitenError {
            throw error
        } catch {
            throw .networkError(underlying: error)
        }
        switch response {
        case .ok(let ok):
            do {
                return try ok.body.json
            } catch {
                throw .decodingError(underlying: error)
            }
        case .unauthorized:
            throw KaitenError.unauthorized
        case .undocumented(statusCode: let code, _):
            throw KaitenError.unexpectedResponse(statusCode: code)
        }
    }

    /// Fetches a single card by its identifier.
    ///
    /// - Parameter id: The card identifier.
    /// - Returns: The ``Components.Schemas.Card`` for the given id.
    /// - Throws: ``KaitenError`` on failure.
    public func getCard(id: Int) async throws(KaitenError) -> Components.Schemas.Card {
        let response: Operations.get_card.Output
        do {
            response = try await client.get_card(path: .init(card_id: id))
        } catch let error as KaitenError {
            throw error
        } catch {
            throw .networkError(underlying: error)
        }
        switch response {
        case .ok(let ok):
            do {
                return try ok.body.json
            } catch {
                throw .decodingError(underlying: error)
            }
        case .unauthorized(_):
            throw KaitenError.unauthorized
        case .notFound(_):
            throw KaitenError.notFound(resource: "card", id: id)
        case .undocumented(statusCode: let code, _):
            throw KaitenError.unexpectedResponse(statusCode: code)
        }
    }

    // MARK: - Card Members

    /// Fetches the list of members for a given card.
    ///
    /// - Parameter cardId: The card identifier.
    /// - Returns: An array of ``Components.Schemas.MemberDetailed``.
    /// - Throws: ``KaitenError`` on failure.
    public func getCardMembers(cardId: Int) async throws(KaitenError) -> [Components.Schemas.MemberDetailed] {
        let response: Operations.retrieve_list_of_card_members.Output
        do {
            response = try await client.retrieve_list_of_card_members(path: .init(card_id: cardId))
        } catch let error as KaitenError {
            throw error
        } catch {
            throw .networkError(underlying: error)
        }
        switch response {
        case .ok(let ok):
            do {
                return try ok.body.json
            } catch {
                throw .decodingError(underlying: error)
            }
        case .unauthorized(_):
            throw KaitenError.unauthorized
        case .forbidden(_):
            throw KaitenError.unexpectedResponse(statusCode: 403)
        case .undocumented(statusCode: let code, _):
            throw KaitenError.unexpectedResponse(statusCode: code)
        }
    }
}

// MARK: - Configuration

struct KaitenConfiguration: Sendable {
    let baseURL: String
    let token: String
}

// MARK: - Custom Properties

extension KaitenClient {
    /// List all custom property definitions for the company.
    public func listCustomProperties() async throws(KaitenError) -> [Components.Schemas.CustomProperty] {
        let response: Operations.get_list_of_properties.Output
        do {
            response = try await client.get_list_of_properties()
        } catch let error as KaitenError {
            throw error
        } catch {
            throw .networkError(underlying: error)
        }
        switch response {
        case .ok(let ok):
            do {
                return try ok.body.json
            } catch {
                throw .decodingError(underlying: error)
            }
        case .unauthorized(_):
            throw KaitenError.unauthorized
        case .forbidden(_):
            throw KaitenError.unexpectedResponse(statusCode: 403)
        case .undocumented(statusCode: let code, _):
            throw KaitenError.unexpectedResponse(statusCode: code)
        }
    }

    /// Get a single custom property definition.
    public func getCustomProperty(id: Int) async throws(KaitenError) -> Components.Schemas.CustomProperty {
        let response: Operations.get_property.Output
        do {
            response = try await client.get_property(path: .init(id: id))
        } catch let error as KaitenError {
            throw error
        } catch {
            throw .networkError(underlying: error)
        }
        switch response {
        case .ok(let ok):
            do {
                return try ok.body.json
            } catch {
                throw .decodingError(underlying: error)
            }
        case .unauthorized(_):
            throw KaitenError.unauthorized
        case .forbidden(_):
            throw KaitenError.unexpectedResponse(statusCode: 403)
        case .notFound(_):
            throw KaitenError.notFound(resource: "customProperty", id: id)
        case .undocumented(statusCode: let code, _):
            throw KaitenError.unexpectedResponse(statusCode: code)
        }
    }
}

// MARK: - Boards

extension KaitenClient {
    /// Fetches a board by its identifier.
    public func getBoard(id: Int) async throws(KaitenError) -> Components.Schemas.Board {
        let response: Operations.get_board.Output
        do {
            response = try await client.get_board(path: .init(id: id))
        } catch let error as KaitenError {
            throw error
        } catch {
            throw .networkError(underlying: error)
        }
        switch response {
        case .ok(let ok):
            do {
                return try ok.body.json
            } catch {
                throw .decodingError(underlying: error)
            }
        case .unauthorized(_):
            throw KaitenError.unauthorized
        case .forbidden(_):
            throw KaitenError.unexpectedResponse(statusCode: 403)
        case .notFound(_):
            throw KaitenError.notFound(resource: "board", id: id)
        case .undocumented(statusCode: let code, _):
            throw KaitenError.unexpectedResponse(statusCode: code)
        }
    }

    /// Fetches columns for a board.
    public func getBoardColumns(boardId: Int) async throws(KaitenError) -> [Components.Schemas.Column] {
        let response: Operations.get_list_of_columns.Output
        do {
            response = try await client.get_list_of_columns(path: .init(board_id: boardId))
        } catch let error as KaitenError {
            throw error
        } catch {
            throw .networkError(underlying: error)
        }
        switch response {
        case .ok(let ok):
            do {
                return try ok.body.json
            } catch {
                throw .decodingError(underlying: error)
            }
        case .unauthorized(_):
            throw KaitenError.unauthorized
        case .forbidden(_):
            throw KaitenError.unexpectedResponse(statusCode: 403)
        case .notFound(_):
            throw KaitenError.notFound(resource: "board", id: boardId)
        case .undocumented(statusCode: let code, _):
            throw KaitenError.unexpectedResponse(statusCode: code)
        }
    }

    /// Fetches lanes for a board.
    public func getBoardLanes(boardId: Int) async throws(KaitenError) -> [Components.Schemas.Lane] {
        let response: Operations.get_list_of_lanes.Output
        do {
            response = try await client.get_list_of_lanes(path: .init(board_id: boardId))
        } catch let error as KaitenError {
            throw error
        } catch {
            throw .networkError(underlying: error)
        }
        switch response {
        case .ok(let ok):
            do {
                return try ok.body.json
            } catch {
                throw .decodingError(underlying: error)
            }
        case .unauthorized(_):
            throw KaitenError.unauthorized
        case .forbidden(_):
            throw KaitenError.unexpectedResponse(statusCode: 403)
        case .notFound(_):
            throw KaitenError.notFound(resource: "board", id: boardId)
        case .undocumented(statusCode: let code, _):
            throw KaitenError.unexpectedResponse(statusCode: code)
        }
    }
}

// MARK: - Spaces

extension KaitenClient {
    /// Lists all spaces.
    public func listSpaces() async throws(KaitenError) -> [Components.Schemas.Space] {
        let response: Operations.retrieve_list_of_spaces.Output
        do {
            response = try await client.retrieve_list_of_spaces()
        } catch let error as KaitenError {
            throw error
        } catch {
            throw .networkError(underlying: error)
        }
        switch response {
        case .ok(let ok):
            do {
                return try ok.body.json
            } catch {
                throw .decodingError(underlying: error)
            }
        case .unauthorized(_):
            throw KaitenError.unauthorized
        case .undocumented(statusCode: let code, _):
            throw KaitenError.unexpectedResponse(statusCode: code)
        }
    }

    /// Lists boards in a space.
    public func listBoards(spaceId: Int) async throws(KaitenError) -> [Components.Schemas.BoardInSpace] {
        let response: Operations.get_list_of_boards.Output
        do {
            response = try await client.get_list_of_boards(path: .init(space_id: spaceId))
        } catch let error as KaitenError {
            throw error
        } catch {
            throw .networkError(underlying: error)
        }
        switch response {
        case .ok(let ok):
            do {
                return try ok.body.json
            } catch {
                throw .decodingError(underlying: error)
            }
        case .unauthorized(_):
            throw KaitenError.unauthorized
        case .forbidden(_):
            throw KaitenError.unexpectedResponse(statusCode: 403)
        case .notFound(_):
            throw KaitenError.notFound(resource: "space", id: spaceId)
        case .undocumented(statusCode: let code, _):
            throw KaitenError.unexpectedResponse(statusCode: code)
        }
    }
}

// MARK: - Helpers

extension Optional {
    func orThrow(_ error: @autoclosure () -> KaitenError) throws(KaitenError) -> Wrapped {
        guard let self else { throw error() }
        return self
    }
}
