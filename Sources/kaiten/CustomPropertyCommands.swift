import ArgumentParser
import KaitenSDK

// MARK: - Custom Properties

struct ListCustomProperties: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "list-custom-properties",
    abstract: "List custom property definitions (paginated)"
  )

  @OptionGroup var global: GlobalOptions

  @Option(name: .long, help: "Offset for pagination (default: 0)")
  var offset: Int = 0

  @Option(name: .long, help: "Limit for pagination (default/max: 100)")
  var limit: Int = 100

  @Option(name: .long, help: "Text search query")
  var query: String?

  @Option(name: .long, help: "Include property values in response")
  var includeValues: Bool?

  @Option(name: .long, help: "Include author details in response")
  var includeAuthor: Bool?

  @Option(name: .long, help: "Return compact representation")
  var compact: Bool?

  @Option(name: .long, help: "Load properties by IDs")
  var loadByIds: Bool?

  @Option(name: .long, help: "Comma-separated property IDs to load")
  var ids: String?

  @Option(name: .long, help: "Field to order by")
  var orderBy: String?

  @Option(name: .long, help: "Order direction: asc or desc")
  var orderDirection: String?

  func run() async throws {
    let client = try await global.makeClient()
    let parsedIds = ids?.split(separator: ",").compactMap {
      Int($0.trimmingCharacters(in: .whitespaces))
    }
    let page = try await client.listCustomProperties(
      offset: offset,
      limit: limit,
      query: query,
      includeValues: includeValues,
      includeAuthor: includeAuthor,
      compact: compact,
      loadByIds: loadByIds,
      ids: parsedIds,
      orderBy: orderBy,
      orderDirection: orderDirection
    )
    try printJSON(page)
  }
}

struct GetCustomProperty: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "get-custom-property",
    abstract: "Get a custom property by ID"
  )

  @OptionGroup var global: GlobalOptions

  @Option(name: .long, help: "Custom property ID")
  var id: Int

  func run() async throws {
    let client = try await global.makeClient()
    let prop = try await client.getCustomProperty(id: id)
    try printJSON(prop)
  }
}
