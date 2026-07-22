import Testing

@testable import SharedDesignSystem

@Suite
struct SharedDesignSystemTests {
    @Test
    func radiusTokensAreDefined() {
        #expect(DesignSystem.Radius.r12 == 12)
        #expect(DesignSystem.Radius.full == 999)
    }
}
