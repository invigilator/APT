import XCTest
import Foundation
@testable import VaporToolbox

class VaporConfigFlagsTests: XCTestCase {
    static let allTests = [
        ("testBuildFlagsMac", testBuildFlagsMac),
        ("testRunFlagsMac", testRunFlagsMac),
        ("testTestFlagsMac", testTestFlagsMac),
        ("testBuildFlagsLinux", testBuildFlagsLinux),
        ("testRunFlagsLinux", testRunFlagsLinux),
        ("testTestFlagsLinux", testTestFlagsLinux),
    ]

    #if Xcode
    /// If you don't nest this in a closure, the file path doesn't load properly /shrug
    let directory: String = {
        #file.components(separatedBy: "/").dropLast().joined(separator: "/") + "/VaporConfigResources"
    }()
    #else
    let directory = "./Tests/VaporToolboxTests/VaporConfigResources"
    #endif

    func testBuildFlagsMac() throws {
        let flags = try Config.buildFlags(rootDirectory: directory, os: "mac")
        let expectation = [
            "-Xswiftc",
            "-I/usr/local/include/mysql",
            "-Xlinker",
            "-L/usr/local/lib"
        ]
        XCTAssertEqual(flags, expectation)
    }

    func testRunFlagsMac() throws {
        let flags = try Config.runFlags(rootDirectory: directory, os: "mac")
        let expectation = [
            "mac-flag",
            "mac-flag-2",
        ]
        XCTAssertEqual(flags, expectation)
    }

    func testTestFlagsMac() throws {
        let flags = try Config.testFlags(rootDirectory: directory, os: "mac")
        let expectation = [
            "macos-test-flag",
            "-Xswiftc",
            "-I/usr/local/include/mysql",
            "-Xlinker",
            "-L/usr/local/lib"
        ]
        XCTAssertEqual(flags, expectation)
    }

    func testBuildFlagsLinux() throws {
        let flags = try Config.buildFlags(rootDirectory: directory, os: "linux")
        let expectation = [
            "-Xswiftc",
            "-DNOJSON",
        ]
        XCTAssertEqual(flags, expectation)
    }

    func testRunFlagsLinux() throws {
        let flags = try Config.runFlags(rootDirectory: directory, os: "linux")
        let expectation = [
            "--config:keys.one=1",
            "--config:keys.two=2"
        ]
        XCTAssertEqual(flags, expectation)
    }

    func testTestFlagsLinux() throws {
        let flags = try Config.testFlags(rootDirectory: directory, os: "linux")
        let expectation = [
            "-Xswiftc",
            "-DNOJSON",
        ]
        XCTAssertEqual(flags, expectation)
    }
}
