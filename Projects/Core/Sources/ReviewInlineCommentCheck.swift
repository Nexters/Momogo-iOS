// claude-code-review 인라인 코멘트 동작 검증용 임시 파일 (검증 후 PR과 함께 삭제 예정)

struct ReviewInlineCommentCheck {
    func parseUserID(from raw: String?) -> Int {
        return Int(raw!)!
    }
}
