import Foundation

public extension JSON.Container {
    init (_ jsonBlob: Any) throws {
        switch jsonBlob {
        case let arr as Array<Any>:
            self = .Array(try arr.map{try JSON.Value($0)})
        case let dict as Dictionary<String, Any>:
            self = .Dictionary(try dict.mapValues{try JSON.Value($0)})
        default:
            throw JSON.Exception.invalidObject(
                "The given jsonBlob could not be interpreted: \(jsonBlob)"
            )
        }
    }

    func blob() -> Any {
        switch self {
        case .Array(let arr): return arr.map { $0.blob() }
        case .Dictionary(let dict): return dict.mapValues { $0.blob() }
        }
    }
}

public extension JSON.Container {
    subscript(index: Int) -> Value? {
        if case .Array(let arr) = self {
            return index < arr.count ? arr[index] : nil
        }

        return nil
    }

    subscript(key: String) -> Value? {
        if case .Dictionary(let dict) = self {
            return dict[key]
        }

        return nil
    }
}

public extension JSON.Container {
    init (encoded jsonData: Data) throws {
        try self.init(JSONSerialization.jsonObject(with: jsonData))
    }

    func encoded(options: JSONSerialization.WritingOptions = []) -> Data {
        // It should not be possible to construct a JSON.Container that is not encodable
        return try! JSONSerialization.data(withJSONObject: self.blob(), options: options)
    }
}

extension JSON.Container:
    ExpressibleByArrayLiteral,
    ExpressibleByDictionaryLiteral {

    public init (arrayLiteral elements: JSON.Value...) {
        self = .Array(elements)
    }

    public init (dictionaryLiteral elements: (String, JSON.Value)...) {
        self = .Dictionary(elements.reduce(into: [:]) {
            carry, item in carry[item.0] = item.1
        })
    }
}
