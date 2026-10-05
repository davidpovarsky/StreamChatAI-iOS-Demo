// Tests/AgentUITests/ToolDisclosureBugTests.swift
import Testing
import Foundation
@testable import AgentUI

@Suite("ToolExecutionDisclosure Bug Regression Tests")
struct ToolDisclosureBugTests {
    @Test("Verify tool execution model supports single continuous expansion state")
    func testToolExecutionExpansionState() {
        var exec = AgentToolExecution(
            id: AgentToolCallID("tool-reg-1"),
            handlerID: "github.search",
            inspection: ToolCallInspection(
                callID: "c1",
                service: "GitHub",
                toolName: "search_repositories",
                arguments: "{\"query\": \"AgentUI\"}",
                resultSummary: "Success"
            ),
            status: .completed,
            isExpanded: false
        )

        #expect(exec.isExpanded == false)
        exec.isExpanded = true
        #expect(exec.isExpanded == true)
        #expect(exec.inspection.toolName == "search_repositories")
    }

    @Test("Verify inspection data formatting is structured without disjointed content")
    func testInspectionDataIntegrity() {
        let inspection = ToolCallInspection(
            callID: "call_abc",
            service: "Database",
            toolName: "run_query",
            arguments: "{\"sql\": \"SELECT * FROM users;\"}",
            resultSummary: "10 rows returned"
        )

        #expect(inspection.callID == "call_abc")
        #expect(inspection.service == "Database")
        #expect(inspection.toolName == "run_query")
        #expect(inspection.prettyPrintedArguments.contains("SELECT * FROM users;"))
        #expect(inspection.resultSummary == "10 rows returned")
    }

    @Test("Verify tool disclosure single surface structure contract")
    func testSingleSurfaceStructureContract() {
        let inspection = ToolCallInspection(
            callID: "call_structural",
            service: "GitHub",
            toolName: "fetch_pull_request",
            arguments: "{\"pr\": 42}",
            resultSummary: "PR fetched"
        )
        let execution = AgentToolExecution(
            id: AgentToolCallID("call_structural"),
            handlerID: "github.pr",
            inspection: inspection,
            status: .completed,
            isExpanded: true
        )

        #expect(execution.inspection.toolName == "fetch_pull_request")
        #expect(execution.isExpanded == true)
        #expect(execution.inspection.service == "GitHub")
        #expect(execution.status == .completed)
    }
}
