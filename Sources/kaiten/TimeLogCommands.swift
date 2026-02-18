import ArgumentParser
import KaitenSDK

struct CreateTimeLog: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "create-time-log",
    abstract: "Create a time log on a card"
  )

  @OptionGroup var global: GlobalOptions

  @Option(name: .long, help: "Card ID")
  var cardId: Int

  @Option(name: .long, help: "Role ID (-1 = Employee)")
  var roleId: Int

  @Option(name: .long, help: "Minutes to log")
  var timeSpent: Int

  @Option(name: .long, help: "Log date (YYYY-MM-DD)")
  var forDate: String

  @Option(name: .long, help: "Comment for time log")
  var comment: String?

  func run() async throws {
    let client = try await global.makeClient()
    let timeLog = try await client.createTimeLog(
      cardId: cardId, roleId: roleId, timeSpent: timeSpent, forDate: forDate, comment: comment)
    try printJSON(timeLog)
  }
}

struct ListTimeLogs: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "list-time-logs",
    abstract: "List time logs for a card"
  )

  @OptionGroup var global: GlobalOptions

  @Option(name: .long, help: "Card ID")
  var cardId: Int

  @Option(name: .long, help: "Filter by date (YYYY-MM-DD)")
  var forDate: String?

  @Flag(name: .long, help: "Filter time logs by current user")
  var personal: Bool = false

  func run() async throws {
    let client = try await global.makeClient()
    let timeLogs = try await client.listTimeLogs(
      cardId: cardId, forDate: forDate, personal: personal ? true : nil)
    try printJSON(timeLogs)
  }
}
