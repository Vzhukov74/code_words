import XCTest
import OSLog
import Foundation
@testable import code_word

let logger: Logger = Logger(subsystem: "code_word", category: "Tests")

@available(macOS 13, *)
final class code_wordTests: XCTestCase {
    func testcode_word() throws {
        logger.log("running testcode_word")
        XCTAssertEqual(1 + 2, 3, "basic test")
        
        // load the TestData.json file from the Resources folder and decode it into a struct
        let resourceURL: URL = try XCTUnwrap(Bundle.module.url(forResource: "TestData", withExtension: "json"))
        let testData = try JSONDecoder().decode(TestData.self, from: Data(contentsOf: resourceURL))
        XCTAssertEqual("code_word", testData.testModuleName)
    }
}

struct TestData : Codable, Hashable {
    var testModuleName: String
}