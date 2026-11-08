import XCTest
import UIKit

final class FontTests: XCTestCase {
    @MainActor
    func testBundledFontsAreRegisteredWithoutFallback() throws {
        let expected = ["EBGaramond-Regular", "EBGaramond-Bold"]
        let registered = try XCTUnwrap(
            Bundle.main.object(forInfoDictionaryKey: "UIAppFonts") as? [String])
        for name in expected {
            XCTAssertTrue(registered.contains("\(name).ttf"))
            XCTAssertNotNil(Bundle.main.url(forResource: name,
                                             withExtension: "ttf"))
            let font = try XCTUnwrap(UIFont(name: name, size: 22))
            XCTAssertEqual(font.fontName, name)
            XCTAssertEqual(font.familyName, "EB Garamond")
        }
    }

    func testFontLicenseShipsWithApp() throws {
        let url = try XCTUnwrap(Bundle.main.url(forResource: "OFL",
                                                withExtension: "txt"))
        let license = try String(contentsOf: url, encoding: .utf8)
        XCTAssertTrue(license.contains("SIL OPEN FONT LICENSE"))
        XCTAssertTrue(license.contains("EB Garamond Project Authors"))
    }
}
