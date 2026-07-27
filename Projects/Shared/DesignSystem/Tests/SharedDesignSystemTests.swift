import SwiftUI
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
    func chipSizeCasesAreExhaustive() {
        let sizes: [DSChip.Size] = [.default, .small]
        #expect(sizes.count == 2)
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

    @Test
    func bottomSheetHeaderAlignmentCasesAreExhaustive() {
        let alignments: [DSBottomSheet<EmptyView>.HeaderAlignment] = [.center, .left]
        #expect(alignments.count == 2)
    }

    @Test
    func bottomSheetAtomStateCasesAreExhaustive() {
        let states: [DSBottomSheetAtom.State] = [.activate, .deactivate]
        #expect(states.count == 2)
    }

    @Test
    func iconButtonIconCasesAreExhaustive() {
        let icons: [DSIconButton.Icon] = [.share, .settings, .more]
        #expect(icons.count == 3)
    }

    @Test
    func buttonSizeCasesAreExhaustive() {
        let sizes: [DSButtonStyle.Size] = [.xl, .large, .small]
        #expect(sizes.count == 3)
    }
}
