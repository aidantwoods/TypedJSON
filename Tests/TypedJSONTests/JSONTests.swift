import XCTest
import TypedJSON

class JSONTests: XCTestCase {
    func testDecoder() throws {
        let jsonData = """
        {"foo":"bar","baz":[true]}
        """.data(using: .utf8)!

        let decoded = try JSON.decode(jsonData)

        XCTAssertEqual(["foo":"bar","baz":[true]], decoded)
        XCTAssertNotEqual(["foo":"bar","baz":[false]], decoded)
        XCTAssertNotEqual(["foo":"bar","baz":[1]], decoded)
        XCTAssertNotEqual(["foo":"bar","baz":[1.0]], decoded)
    }

    func testDecoder1() throws {
        let jsonData = """
        {"foo":"bar","baz":[2]}
        """.data(using: .utf8)!

        let decoded = try JSON.decode(jsonData)

        XCTAssertNotEqual(["foo":"bar","baz":[true]], decoded)
    }

    func testDecoder2() throws {
        let jsonData = """
        {"foo":"bar","baz":[1]}
        """.data(using: .utf8)!

        let decoded = try JSON.decode(jsonData)

        XCTAssertNotEqual(["foo":"bar","baz":[true]], decoded)

    }

    func testDecoder3() throws {
        let jsonData = """
        {"foo":"bar","baz":[0]}
        """.data(using: .utf8)!

        let decoded = try JSON.decode(jsonData)

        XCTAssertNotEqual(["foo":"bar","baz":[true]], decoded)
        XCTAssertNotEqual(["foo":"bar","baz":[false]], decoded)
        XCTAssertEqual(["foo":"bar","baz":[0]], decoded)
        XCTAssertEqual(["foo":"bar","baz":[0.0]], decoded)
    }

    func testDynamic() throws {
        let jsonData = """
        {"foo":"bar","baz":[2]}
        """.data(using: .utf8)!

        let decoded = try JSON.decode(jsonData)

        XCTAssertEqual("bar", decoded.foo)
        XCTAssertEqual([2], decoded.baz)
    }

    func testEncoder() throws {
        let expected = """
        {"baz":[true],"foo":"bar"}
        """

        let json: JSON.Container = ["foo":"bar","baz":[true]]

        XCTAssertEqual(
            String(decoding: json.encoded(options: [.sortedKeys]), as: UTF8.self),
            expected
        )
    }
}
