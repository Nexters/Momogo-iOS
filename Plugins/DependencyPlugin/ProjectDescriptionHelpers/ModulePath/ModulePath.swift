import ProjectDescription

public enum ModulePath {
    case feature(Feature)
    case core(Core)
    case data(Data)
    case designSystem(DesignSystem)
    case domain(Domain)
    case networking(Networking)
}
