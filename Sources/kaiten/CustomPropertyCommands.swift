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

    func run() async throws {
        let client = try await global.makeClient()
        let page = try await client.listCustomProperties(offset: offset, limit: limit)
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
