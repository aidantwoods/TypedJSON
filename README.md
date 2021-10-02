# TypedJSON [![Swift](https://github.com/aidantwoods/TypedJSON/actions/workflows/push.yml/badge.svg)](https://github.com/aidantwoods/TypedJSON/actions/workflows/push.yml)

If you can, JSON parsing with `Codable` is very nice.

Sometimes it is necessary to make sense of unknown JSON structures, for these cases it is necessary
to use `JSONSerialization` and attempt to downcast various types. Unfortunately, this makes use of
the `Any` type, which does not provide much guidance through the type system as the the expected
structure.

## Structure

TypedJSON aims to add some of this structure back, as well as some convenience through the use of
`@dynamicMemberLookup`.

There are two core types introduced, `JSON.Container` and `JSON.Value`. Their simplified
definitions are as follows:

```swift
enum JSON {
    enum Container: Equatable {
        case Array([Value])
        case Dictionary([String: Value])
    }

    enum Value: Equatable {
        case Container(Container)
        case String(String)
        case Number(NSNumber)
        case Bool(Bool)
        case Null
    }
}
```

This allows standard Swift pattern matching to be used to unwrap cases. Both these types also
support subscripting through dynamic member lookup, and through string and integer indices.

Dynamic member lookup and String subscripting is only *meaningful* for `JSON.Container` in the
`.Dictionary` case, and `JSON.Value` in the `.Container` case where the container is in the
`.Dictionary` case. Int indicies are only *meaningful* for `JSON.Container` in the `.Array` case,
and `JSON.Value` in the `.Container` case where the container is in the `.Array` case.

In the event that an index (dynamic member, string, or integer) does not exist the subscript
will return `nil`. The same will occur if the subscript lookup is not "meaningful" (as defined
above). This behaviour allows structures to be traversed without having to explictly pattern match
each case.

## Encoding and Decoding
The primary goal of this library when encoding is to accurately represent valid JSON data, and to
be able to interact with decoded JSON data in a way that represents the input. This goal will guide
some decision making.

### Encoding
It is only valid to encode a `JSON.Container`, as such only this type has the `encoded` method.

```swift
func encoded(options: JSONSerialization.WritingOptions = []) -> Data
```

`options` accepts the same options as can be passed to
`JSONSerialization.data(withJSONObject:options:)`

Bear in mind that, because only `JSON.Container` can be encoded, the `.fragmentsAllowed` option is
meaningless.

### Decoding
JSON can be decoded using either the `JSON.decode(_:)` method or by directly calling the initaliser
`JSON.Container(encoded:)`.

At this time it is not possible to provide additional decoding options.

## Examples

JSON can be decoded and read as follows
```swift
let jsonData = """
{"foo":{"bar":{"baz":"boo"}},"baz":[2]}
""".data(using: .utf8)!

let decoded = try JSON.decode(jsonData)

// traverse structure, only extract if string
guard case .String(let baz) = decoded.foo?.bar?.baz else {
    return
}

print(baz) // "boo"
```

JSON can be written with swift literals, the following will produce
an identical structure to the above
```swift
let json: JSON.Contianer = ["foo":["bar":["baz":"boo"]],"baz":[2]]

// traverse structure, only extract if string
guard case .String(let baz) = json.foo?.bar?.baz else {
    return
}

print(baz) // "boo"
```
