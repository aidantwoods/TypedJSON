import Foundation

extension JSON.Value {
    public init (_ jsonBlob: Any) throws {
        switch jsonBlob {
        case let arr as [Any]:
            self = .Container(.Array(try arr.map{try JSON.Value($0)}))
        case let dict as [String: Any]:
            self = .Container(.Dictionary(try dict.mapValues{try JSON.Value($0)}))

        case let str as String: self = .String(str)
        case let num as NSNumber:
            /**
             * Swift's JSONSerialization does not decode booleans as Bool, these are
             * mapped to NSNumber. These can theoretically be distinguished. This relies
             * on an undocumented implementation detail, not a great idea to depend on.
             *
             * Here we detect if num: NSNumber is actually a boolean.
             *
             * This is a bit of a hack, and might be necessary to remove this in
             * future depending on how JSONSerialization evolves.
             *
             * This detection is based on NSNumber returning a distinguishable subclass
             * when a boolean is used to construct it. For so long as that remains
             * true this detection will continue to work.
             */
            if let bool = num as? Bool, type(of: num) == type(of: NSNumber(booleanLiteral: true)) {
                self = .Bool(bool)
                break
            }

            self = .Number(num)

        case _ as NSNull: self = .Null
        default:
            throw JSON.Exception.invalidObject(
                "The given jsonBlob could not be interpreted: \(jsonBlob)"
            )
        }
    }

    public func blob() -> Any {
        switch self {
        case .Container(let container): return container.blob()
        case .String(let str): return str
        case .Bool(let bool): return bool
        case .Number(let num): return num
        case .Null: return NSNull()
        }
    }
}

public extension JSON.Value {
    subscript(index: Int) -> Value? {
        if case .Container(let container) = self {
            return container[index]
        }

        return nil
    }

    subscript(key: String) -> Value? {
        if case .Container(let container) = self {
            return container[key]
        }

        return nil
    }
}

extension JSON.Value:
    ExpressibleByIntegerLiteral,
    ExpressibleByStringLiteral,
    ExpressibleByArrayLiteral,
    ExpressibleByDictionaryLiteral,
    ExpressibleByFloatLiteral,
    ExpressibleByBooleanLiteral,
    ExpressibleByNilLiteral {

    public init (integerLiteral value: IntegerLiteralType) {
        self = .Number(NSNumber(integerLiteral: value))
    }

    public init (stringLiteral value: StringLiteralType) {
        self = .String(value)
    }

    public init (arrayLiteral elements: JSON.Value...) {
        self = .Container(.Array(elements))
    }

    public init (dictionaryLiteral elements: (String, JSON.Value)...) {
        self = .Container(.Dictionary(elements.reduce(into: [:]) {
            carry, item in carry[item.0] = item.1
        }))
    }

    public init (floatLiteral value: FloatLiteralType) {
        self = .Number(NSNumber(floatLiteral: value))
    }

    public init (booleanLiteral value: BooleanLiteralType) {
        self = .Bool(value)
    }

    public init (nilLiteral: ()) {
        self = .Null
    }
}

