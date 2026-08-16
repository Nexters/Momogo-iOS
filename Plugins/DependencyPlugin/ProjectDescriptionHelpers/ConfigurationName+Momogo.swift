import ProjectDescription

/// 프로젝트 전역 build configuration 이름.
/// DEV/PROD의 차이는 App 타겟에 붙는 xcconfig(= API_BASE_URL)뿐이며,
/// 최적화 수준은 각각 debug/release를 따른다.
public extension ConfigurationName {
    static var dev: ConfigurationName { .configuration("DEV") }
    static var prod: ConfigurationName { .configuration("PROD") }
}
