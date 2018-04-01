import Foundation
import XCTest
import YoudaoCLI_SwiftCore

class YoudaoCLITests: XCTestCase {
    
    func testArgParsing() {
        let core = YoudaoCLISwift()
        let args = ["YoudaoCLISwift", "hello", "world", "-v", "-m", "yet", "-v"]
        let result: YoudaoCLISwift.ArgumentType = (words: ["hello", "world", "yet"], isVoice: true, isMore: true)
        XCTAssertTrue(result.words == core.parseArguments(args).words)
        XCTAssertTrue(result.isVoice == core.parseArguments(args).isVoice)
        XCTAssertTrue(result.isMore == core.parseArguments(args).isMore)
    }
    
    
}
