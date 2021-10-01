import Foundation

extension JSON.Value {
    public init (_ jsonBlob: Any) throws {
        switch jsonBlob {
        case let arr as Array<Any>:
            self = .Container(.Array(try arr.map{try JSON.Value($0)}))
        case let dict as Dictionary<String, Any>:
            self = .Container(.Dictionary(try dict.mapValues{try JSON.Value($0)}))

        case let str as String: self = .String(str)
        case let num as NSNumber: self = .Number(num)
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
        case .Number(let num): return num
        case .Null: return NSNull()
        }
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

    /**
     * Swift's JSONSerialization does not decode booleans as Bool, these are
     * mapped to NSNumber. These can theoretically be distigished, however
     * it relies on an undocumented implementation detail, which does not seem
     * like a great idea to depend upon.
     * Here we commit the same foolishness as JSONSerialization and map a
     * Bool to NSNumber.
     */
    public init (booleanLiteral value: BooleanLiteralType) {
        self = .Number(NSNumber(booleanLiteral: value))
    }

    public init (nilLiteral: ()) {
        self = .Null
    }
}

