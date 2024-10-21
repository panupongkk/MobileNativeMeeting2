import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(MobileNativeMeetingMacrosMacros)
import MobileNativeMeetingMacrosMacros

let testMacros: [String: Macro.Type] = [
    "stringify": StringifyMacro.self,
    "MappableAutogenMacro": MappableAutogenMacro.self,
]
#endif

final class MobileNativeMeetingMacrosTests: XCTestCase {
    func testMacro() throws {
        #if canImport(MobileNativeMeetingMacrosMacros)
        assertMacroExpansion(
            """
            #stringify(a + b)
            """,
            expandedSource: """
            (a + b, "a + b")
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testMacroWithStringLiteral() throws {
        #if canImport(MobileNativeMeetingMacrosMacros)
        assertMacroExpansion(
            #"""
            #stringify("Hello, \(name)")
            """#,
            expandedSource: #"""
            ("Hello, \(name)", #""Hello, \(name)""#)
            """#,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testMappableAutogenMacroInit() {
        assertMacroExpansion(
            #"""
            @MappableAutogenMacro
            struct Test {
                var var1: String?
            }
            """#,
            expandedSource: #"""
            struct Test {
                var var1: String?
            
                init?(map: ObjectMapper.Map) {
                }
            }
            """#,
            macros: testMacros
        )
    }
    
    func testMappableAutogenMacro() {
        assertMacroExpansion(
            #"""
            @MappableAutogenMacro
            struct Test {
                var var1: String?
            }
            """#,
            expandedSource: #"""
            struct Test {
                var var1: String?
            
                init?(map: ObjectMapper.Map) {
                }
            
                mutating func mapping(map: ObjectMapper.Map) {
                    var1 <- map["var1"]
                }
            }	
            """#,
            macros: testMacros
        )
    }
}
