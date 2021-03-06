import Foundation

public enum JSON {
    @dynamicMemberLookup
    public enum Container: Equatable {
        case Array([Value])
        case Dictionary([String: Value])

        public subscript(dynamicMember member: String) -> Value? {
            if case .Dictionary(let dict) = self {
                  return dict[member]
            }

            return nil
        }
    }

    /**
     * JSON.Value is based on the types that may be returned from JSONSerialization.
     *
     * Apple's documentation notably omits the boolean case, and does not distinguish numbers by type.
     * The boolean case is detectable by examining types at runtime.
     */
    @dynamicMemberLookup
    public enum Value: Equatable {
        case Container(Container)
        case String(String)
        case Number(NSNumber)
        case Bool(Bool)
        case Null

        public subscript(dynamicMember member: String) -> Value? {
            if case .Container(let container) = self {
                return container[dynamicMember: member]
            }

            return nil
        }
    }

    public enum Exception: Error {
        case invalidObject(String)
    }
}

public extension JSON {
    static func decode(_ jsonData: Data) throws -> Container {
        return try Container(encoded: jsonData)
    }
}
