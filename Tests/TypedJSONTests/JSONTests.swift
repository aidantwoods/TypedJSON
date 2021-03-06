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

    func testDynamic2() throws {
        let jsonData = """
        {"foo":{"bar":{"baz":"boo"}},"baz":[2]}
        """.data(using: .utf8)!

        let decoded = try JSON.decode(jsonData)

        XCTAssertEqual("boo", decoded.foo?.bar?.baz)
        XCTAssertEqual([2], decoded.baz)
    }

    func testDictSubscript() throws {
        let jsonData = """
        {"foo":"bar","baz":[2]}
        """.data(using: .utf8)!

        let decoded = try JSON.decode(jsonData)

        XCTAssertEqual("bar", decoded["foo"])
        XCTAssertEqual([2], decoded.baz)
    }

    func testDictSubscript2() throws {
        let jsonData = """
        {"foo":{"bar":{"baz":"boo"}},"baz":[2]}
        """.data(using: .utf8)!

        let decoded = try JSON.decode(jsonData)

        XCTAssertEqual("boo", decoded["foo"]?["bar"]?["baz"])
        XCTAssertEqual([2], decoded.baz)
    }

    func testArraySubscript() throws {
        let jsonData = """
        {"foo":"bar","baz":[2]}
        """.data(using: .utf8)!

        let decoded = try JSON.decode(jsonData)

        XCTAssertEqual(2, decoded.baz?[0])
        XCTAssertEqual([2], decoded.baz)
    }

    func testArraySubscript2() throws {
        let jsonData = """
        [[],[[],[],["foo"]]]
        """.data(using: .utf8)!

        let decoded = try JSON.decode(jsonData)

        XCTAssertEqual("foo", decoded[1]?[2]?[0])
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
