//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

@testable import LocalizeKitCore
import IndexStoreDB
import XCTest

/// Unit tests for the parts of `SemanticTypeResolver` that don't need a live
/// IndexStoreDB connection: demangled-signature parsing + type-string mapping.
final class SemanticTypeResolverTests: XCTestCase {

    /// Build a SemanticTypeResolver against a throwaway in-memory store so we
    /// can exercise the `extractType(from:kind:)` and `mapTypeString(_:)`
    /// helpers without depending on a real Xcode build.
    private func makeResolver() throws -> SemanticTypeResolver? {
        guard let libPath = IndexStoreDiscovery.indexStoreLibraryPath() else {
            // CI without Xcode toolchain — skip these tests cleanly.
            return nil
        }
        let tmpStore = NSTemporaryDirectory() + "lkit-test-store-\(UUID().uuidString)"
        let tmpDb = NSTemporaryDirectory() + "lkit-test-db-\(UUID().uuidString)"
        try FileManager.default.createDirectory(atPath: tmpStore, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(atPath: tmpDb, withIntermediateDirectories: true)
        return try SemanticTypeResolver(storePath: tmpStore, databasePath: tmpDb, libraryPath: libPath)
    }

    // MARK: - extractType from function signatures

    func testExtractType_simpleIntReturn_mapsToInteger() throws {
        guard let resolver = try makeResolver() else { return }
        let result = resolver.extractType(
            from: "Core.ItemInfo.getItemQty() -> Swift.Int",
            kind: .instanceMethod
        )
        XCTAssertEqual(result, .integer)
    }

    func testExtractType_simpleDoubleReturn_mapsToFloatingPoint() throws {
        guard let resolver = try makeResolver() else { return }
        let result = resolver.extractType(
            from: "Core.ItemInfo.getTotalPrice() -> Swift.Double",
            kind: .instanceMethod
        )
        XCTAssertEqual(result, .floatingPoint)
    }

    func testExtractType_stringReturn_mapsToString() throws {
        guard let resolver = try makeResolver() else { return }
        let result = resolver.extractType(
            from: "App.Model.getName() -> Swift.String",
            kind: .instanceMethod
        )
        XCTAssertEqual(result, .string)
    }

    func testExtractType_boolReturn_mapsToBoolean() throws {
        guard let resolver = try makeResolver() else { return }
        let result = resolver.extractType(
            from: "App.Model.isReady() -> Swift.Bool",
            kind: .instanceMethod
        )
        XCTAssertEqual(result, .boolean)
    }

    func testExtractType_optionalIntReturn_unwrapsToInteger() throws {
        guard let resolver = try makeResolver() else { return }
        let result = resolver.extractType(
            from: "App.Model.getCount() -> Swift.Int?",
            kind: .instanceMethod
        )
        XCTAssertEqual(result, .integer)
    }

    func testExtractType_optionalGenericReturn_unwrapsToInteger() throws {
        guard let resolver = try makeResolver() else { return }
        let result = resolver.extractType(
            from: "App.Model.getCount() -> Swift.Optional<Swift.Int>",
            kind: .instanceMethod
        )
        XCTAssertEqual(result, .integer)
    }

    func testExtractType_closureArgumentDoesNotConfuseReturnDetection() throws {
        guard let resolver = try makeResolver() else { return }
        // The inner arrow inside `(Int) -> Void` is a closure parameter type;
        // the actual return type is the trailing String.
        let result = resolver.extractType(
            from: "App.Model.transform(_: (Swift.Int) -> Swift.Void) -> Swift.String",
            kind: .instanceMethod
        )
        XCTAssertEqual(result, .string)
    }

    func testExtractType_property_parsesAfterColon() throws {
        guard let resolver = try makeResolver() else { return }
        let result = resolver.extractType(
            from: "App.Model.qty : Swift.Int",
            kind: .instanceProperty
        )
        XCTAssertEqual(result, .integer)
    }

    func testExtractType_arrayReturn_mapsToObject() throws {
        guard let resolver = try makeResolver() else { return }
        let result = resolver.extractType(
            from: "App.Model.getItems() -> Swift.Array<App.Item>",
            kind: .instanceMethod
        )
        XCTAssertEqual(result, .object)
    }

    func testExtractType_cgFloat_mapsToFloatingPoint() throws {
        guard let resolver = try makeResolver() else { return }
        let result = resolver.extractType(
            from: "Core.View.width : CoreGraphics.CGFloat",
            kind: .instanceProperty
        )
        XCTAssertEqual(result, .floatingPoint)
    }

    func testExtractType_customStructReturn_mapsToUnknown() throws {
        guard let resolver = try makeResolver() else { return }
        // Custom (non-NSObject) Swift types could be anything; we stay pessimistic
        // so `%@` doesn't false-positive on them.
        let result = resolver.extractType(
            from: "App.Service.getItem() -> App.Item",
            kind: .instanceMethod
        )
        XCTAssertEqual(result, .unknown)
    }

    func testExtractType_nsStringProperty_mapsToString() throws {
        guard let resolver = try makeResolver() else { return }
        let result = resolver.extractType(
            from: "App.Bridge.title : Foundation.NSString",
            kind: .instanceProperty
        )
        XCTAssertEqual(result, .string)
    }

    func testExtractType_unsupportedKind_mapsToUnknown() throws {
        guard let resolver = try makeResolver() else { return }
        let result = resolver.extractType(
            from: "App.Service",
            kind: .struct
        )
        XCTAssertEqual(result, .unknown)
    }

    // MARK: - Accessor / private-property signatures (regression)

    func testExtractType_privatePropertyWithDiscriminator_mapsToString() throws {
        guard let resolver = try makeResolver() else { return }
        // A `private let title: String` reference demangles with a private
        // discriminator wrapped in parentheses, e.g.
        //   Survey.SurveyQuestionItemView.(title in _1F09…) : Swift.String
        let result = resolver.extractType(
            from: "Survey.SurveyQuestionItemView.(title in _1F09D807163A219ADBCEB45ED9DC0D87) : Swift.String",
            kind: .instanceProperty
        )
        XCTAssertEqual(result, .string)
    }

    func testExtractType_propertyGetterAccessor_mapsToValueType() throws {
        guard let resolver = try makeResolver() else { return }
        // IndexStoreDB records a synthesized `getter:` occurrence (kind
        // .instanceMethod) at the very same source position as the property read.
        // Its demangled signature is an *accessor* of the form
        //   …(title in _1F09…).getter : Swift.String
        // There is NO `->` return arrow — accessors use the property `:` form — so
        // the function-return parser must fall back to property parsing. Before the
        // fix this returned `.unknown`, silencing the linter on every property /
        // computed-property `with:` argument (the `%d. %d` + String `title` bug).
        let result = resolver.extractType(
            from: "Survey.SurveyQuestionItemView.(title in _1F09D807163A219ADBCEB45ED9DC0D87).getter : Swift.String",
            kind: .instanceMethod
        )
        XCTAssertEqual(result, .string,
                       "A property getter accessor must resolve to its value type, not .unknown")
    }

    func testExtractType_computedIntPropertyGetter_mapsToInteger() throws {
        guard let resolver = try makeResolver() else { return }
        let result = resolver.extractType(
            from: "App.Model.count.getter : Swift.Int",
            kind: .instanceMethod
        )
        XCTAssertEqual(result, .integer)
    }

    // MARK: - Function / closure parameters

    func testExtractType_functionParameter_stripsContextClause_mapsToString() throws {
        guard let resolver = try makeResolver() else { return }
        // A `with:` argument that is a function parameter demangles with a trailing
        //   ` in <enclosing function signature>`
        // clause: `userName #1 : Swift.String in Module.Type.fn(...) -> ()`.
        // That clause must be stripped before mapping, otherwise the whole tail
        // (`Swift.String in Module…`) fails to map and yields `.unknown` — which
        // silenced type checking for every parameter argument.
        let result = resolver.extractType(
            from: "userName #1 : Swift.String in Shirts.ShirtsDelegatesViewModel.askForDelete(userName: Swift.String, userType: Swift.String, delegatedUserId: Swift.Int) -> ()",
            kind: .parameter
        )
        XCTAssertEqual(result, .string)
    }

    func testExtractType_intFunctionParameter_stripsContextClause_mapsToInteger() throws {
        guard let resolver = try makeResolver() else { return }
        let result = resolver.extractType(
            from: "delegatedUserId #3 : Swift.Int in Shirts.ShirtsDelegatesViewModel.askForDelete(userName: Swift.String, userType: Swift.String, delegatedUserId: Swift.Int) -> ()",
            kind: .parameter
        )
        XCTAssertEqual(result, .integer)
    }

    func testExtractType_plainPropertyWithoutContextClause_stillMaps() throws {
        guard let resolver = try makeResolver() else { return }
        // The context-clause strip must not disturb ordinary property signatures.
        let result = resolver.extractType(
            from: "App.Model.name : Swift.String",
            kind: .instanceProperty
        )
        XCTAssertEqual(result, .string)
    }

    // MARK: - mapTypeString edge cases

    func testMapTypeString_stripsForceUnwrap() throws {
        guard let resolver = try makeResolver() else { return }
        XCTAssertEqual(resolver.mapTypeString("Swift.Int!"), .integer)
    }

    func testMapTypeString_stripsOptionalSuffix() throws {
        guard let resolver = try makeResolver() else { return }
        XCTAssertEqual(resolver.mapTypeString("Swift.String?"), .string)
    }

    func testMapTypeString_tupleStaysUnknown() throws {
        guard let resolver = try makeResolver() else { return }
        // Tuples cannot bridge to NSObject — keep them unknown.
        XCTAssertEqual(resolver.mapTypeString("(Swift.Int, Swift.String)"), .unknown)
    }
}
