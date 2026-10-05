import XCTest
@testable import AgentUI

final class AgentUITests: XCTestCase {
    func testAgentUIVersion() {
        XCTAssertEqual(AgentUI.version, "1.0.0")
    }
}
