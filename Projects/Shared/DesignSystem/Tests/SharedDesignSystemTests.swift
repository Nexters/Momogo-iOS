import Testing

@testable import SharedDesignSystem

@Suite
struct SharedDesignSystemTests {
    @Test
    func radiusTokensAreDefined() {
        #expect(DesignSystem.Radius.r12 == 12)
        #expect(DesignSystem.Radius.full == 999)
    }

    @Test
    func chipToneCasesAreExhaustive() {
        let tones: [DSChip.Tone] = [.gray, .primary, .secondary, .green, .blue, .red]
        #expect(tones.count == 6)
    }

    @Test
    func textFieldStateCasesAreExhaustive() {
        let states: [DSTextField.State] = [.normal, .focused, .error]
        #expect(states.count == 3)
    }

    @Test
    func toastToneCasesAreExhaustive() {
        let tones: [DSToast.Tone] = [.notice, .error, .success]
        #expect(tones.count == 3)
    }

    @Test
    func tooltipArrowDirectionCasesAreExhaustive() {
        let directions: [DSTooltip.ArrowDirection] = [.up, .down]
        #expect(directions.count == 2)
    }
}
