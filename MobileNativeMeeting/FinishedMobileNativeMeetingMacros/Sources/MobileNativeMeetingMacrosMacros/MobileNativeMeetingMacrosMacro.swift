import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// Implementation of the `stringify` macro, which takes an expression
/// of any type and produces a tuple containing the value of that expression
/// and the source code that produced the value. For example
///
///     #stringify(x + y)
///
///  will expand to
///
///     (x + y, "x + y")
public struct StringifyMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        guard let argument = node.argumentList.first?.expression else {
            fatalError("compiler bug: the macro does not have any arguments")
        }

        return "(\(argument), \(literal: argument.description))"
    }
}

public struct MappableAutogenMacro: MemberMacro {
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        providingMembersOf declaration: some SwiftSyntax.DeclGroupSyntax,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        guard
            let structDecl = declaration.as(StructDeclSyntax.self)
        else {
            return []
        }
        
        print(structDecl.debugDescription)
        
        let members = structDecl.memberBlock.members
        
        let varDecls = members.compactMap { $0.decl.as(VariableDeclSyntax.self) }
        
        let initDecl = InitializerDeclSyntax(
            initKeyword: .init(stringLiteral: "init?"),
            signature: .init(parameterClause: .init(parametersBuilder: {
                FunctionParameterSyntax(
                    firstName: TokenSyntax(stringLiteral: "map"),
                    type: IdentifierTypeSyntax(
                        name: .integerLiteral("ObjectMapper.Map")
                    )
                )
            })),
            bodyBuilder: {}
        )
        
        let mappingDecl = FunctionDeclSyntax(
            modifiers: .init(itemsBuilder: {
                DeclModifierSyntax(name: .keyword(.mutating))
            }),
            name: .init(stringLiteral: "mapping"),
            signature: .init(parameterClause: .init(parametersBuilder: {
                FunctionParameterSyntax(
                    firstName: .init(stringLiteral: "map"),
                    type: IdentifierTypeSyntax(name: .init(stringLiteral: "ObjectMapper.Map"))
                )
            })),
            bodyBuilder: {
                for varDecl in varDecls {
                    if
                        let patternBinding = varDecl.bindings.first,
                        let varName = patternBinding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text {
                        SequenceExprSyntax {
                            DeclReferenceExprSyntax(baseName: .init(stringLiteral: varName))
                            BinaryOperatorExprSyntax(operator: .init(stringLiteral: "<-"))
                            SubscriptCallExprSyntax(
                                calledExpression: DeclReferenceExprSyntax(baseName: .init(stringLiteral: "map")),
                                arguments: .init(itemsBuilder: {
                                    LabeledExprSyntax(expression: StringLiteralExprSyntax(content: varName))
                                })
                            )
                        }
                    }
                    
                }
            }
        )
        
        return [
            DeclSyntax(initDecl),
            DeclSyntax(mappingDecl),
        ]
    }
}

@main
struct MobileNativeMeetingMacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        StringifyMacro.self,
        MappableAutogenMacro.self
    ]
}
