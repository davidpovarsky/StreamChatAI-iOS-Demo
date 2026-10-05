// Showcase/UITests/AgentUIShowcaseUITests.swift
import XCTest

final class AgentUIShowcaseUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
    }

    private func launchScenario(_ scenarioID: String) {
        app.launchArguments = ["--agentui-scenario", scenarioID]
        app.launch()
    }

    private func takeScreenshot(name: String) {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    // 1. One-surface tool disclosure regression UI test
    func testToolDisclosureSingleSurface() throws {
        launchScenario("tool.disclosure")

        let disclosure = app.otherElements["agentui_tool_disclosure"]
        XCTAssertTrue(disclosure.waitForExistence(timeout: 5), "Tool disclosure surface must exist")

        takeScreenshot(name: "01_ToolDisclosure_Initial")

        let header = app.buttons["agentui_tool_disclosure_header"]
        if header.exists {
            header.tap()
        }

        takeScreenshot(name: "02_ToolDisclosure_Toggled")

        XCTAssertTrue(disclosure.exists, "Tool disclosure remains unified single surface")
    }

    // 2. Fullscreen image viewer navigation
    func testImageViewerNavigation() throws {
        launchScenario("media.zoom")

        takeScreenshot(name: "03_ImageInline_Initial")

        let imageButton = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'agentui_image_'")).firstMatch
        if imageButton.waitForExistence(timeout: 5) {
            imageButton.tap()
            takeScreenshot(name: "04_ImageViewer_Opened")

            let closeButton = app.buttons["agentui_image_viewer_close"]
            if closeButton.waitForExistence(timeout: 3) {
                closeButton.tap()
                takeScreenshot(name: "05_ImageViewer_Closed")
            }
        }
    }

    // 3. Embedded sheet expansion
    func testEmbeddedSheetExpansion() throws {
        launchScenario("embedded.sheet")

        takeScreenshot(name: "06_EmbeddedSheet_Inline")

        let expandButton = app.buttons["agentui_embedded_expand_button"]
        if expandButton.waitForExistence(timeout: 5) {
            expandButton.tap()
            takeScreenshot(name: "07_EmbeddedSheet_Expanded")

            let doneButton = app.buttons["Done"]
            if doneButton.waitForExistence(timeout: 3) {
                doneButton.tap()
            }
        }
    }

    // 4. Embedded fullscreen expansion
    func testEmbeddedFullScreenExpansion() throws {
        launchScenario("embedded.fullscreen")

        takeScreenshot(name: "08_EmbeddedFullScreen_Inline")

        let expandAction = app.buttons["agentui_embedded_action_fullscreen"]
        if expandAction.waitForExistence(timeout: 5) {
            expandAction.tap()
            takeScreenshot(name: "09_EmbeddedFullScreen_Expanded")

            let doneButton = app.buttons["Done"]
            if doneButton.waitForExistence(timeout: 3) {
                doneButton.tap()
            }
        }
    }

    // 5. Embedded action callback
    func testEmbeddedActionCallback() throws {
        launchScenario("embedded.actions")

        takeScreenshot(name: "10_EmbeddedActions_Inline")

        let customAction = app.buttons["agentui_embedded_action_custom_ping"]
        if customAction.waitForExistence(timeout: 5) {
            customAction.tap()
            takeScreenshot(name: "11_EmbeddedActions_Tapped")
        }
    }

    // 6. Section sources sheet
    func testSectionSourcesSheet() throws {
        launchScenario("sources.inline.short")

        takeScreenshot(name: "12_SectionSources_Inline")

        let clusterButton = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'agentui_section_sources_'")).firstMatch
        if clusterButton.waitForExistence(timeout: 5) {
            clusterButton.tap()
            takeScreenshot(name: "13_SectionSources_Sheet")

            let doneButton = app.buttons["Done"]
            if doneButton.waitForExistence(timeout: 3) {
                doneButton.tap()
            }
        }
    }

    // 7. Footer sources sheet
    func testFooterSourcesSheet() throws {
        launchScenario("sources.footer")

        takeScreenshot(name: "14_FooterSources_Initial")

        let footerPill = app.buttons["agentui_footer_sources_pill"]
        if footerPill.waitForExistence(timeout: 5) {
            footerPill.tap()
            takeScreenshot(name: "15_FooterSources_Sheet")

            let doneButton = app.buttons["Done"]
            if doneButton.waitForExistence(timeout: 3) {
                doneButton.tap()
            }
        }
    }

    // 8. Activity auto-collapse
    func testActivityAutoCollapse() throws {
        launchScenario("activity.autocollapse")

        let collapsePill = app.buttons["agentui_activity_duration_pill"]
        XCTAssertTrue(collapsePill.waitForExistence(timeout: 5), "Activity auto-collapse pill should be visible")

        takeScreenshot(name: "16_ActivityAutoCollapse_Collapsed")
    }

    // 9. Hebrew RTL scenario
    func testHebrewRTLScenario() throws {
        launchScenario("chat.hebrew")

        takeScreenshot(name: "17_HebrewRTL_Chat")
    }

    // 10. YouTube fallback scenario
    func testYouTubeFallbackScenario() throws {
        launchScenario("media.youtube.fallback")

        let fallbackView = app.links["agentui_youtube_fallback"]
        XCTAssertTrue(fallbackView.waitForExistence(timeout: 5), "YouTube fallback view should be rendered for failed video")

        takeScreenshot(name: "18_YouTubeFallback_Rendered")
    }
}
