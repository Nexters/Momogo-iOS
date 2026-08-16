# Momogo-iOS

## 로컬 세팅

Xcode 프로젝트/워크스페이스는 gitignore 대상이므로 `tuist install && tuist generate`로 생성한다.

### 스킴 / Configuration

앱 스킴은 바라보는 서버에 따라 두 개로 나뉜다. 둘의 차이는 App 타겟에 붙는 xcconfig(= `API_BASE_URL`)뿐이다.

| 스킴 | Configuration | xcconfig | 비고 |
| --- | --- | --- | --- |
| `Momogo-DEV` | `DEV` (debug 기반) | `Config/DEV.xcconfig` → `Secrets/DEV.xcconfig` | 평소 개발용 |
| `Momogo-PROD` | `PROD` (release 기반) | `Config/PROD.xcconfig` → `Secrets/PROD.xcconfig` | 릴리스/배포용. Crashlytics dSYM 업로드는 이 쪽에서만 동작 |

`DEV`/`PROD`는 모든 모듈 프로젝트가 공유하는 configuration 이름이다 (`Plugins/DependencyPlugin/.../Project+Templates.swift`).
`xcodebuild`에서 configuration을 생략하면 `DEV`가 쓰인다 (`Tuist.swift`의 `defaultConfiguration`).

### Base URL (필수)

`API_BASE_URL`은 gitignore 대상인 `Projects/App/Config/Secrets/{DEV,PROD}.xcconfig`에서 읽는다. 최초 클론 후 아래를 실행해 로컬 값을 채워야 빌드가 된다 (실값 없이는 빌드가 실패한다):

```sh
cp Projects/App/Config/Secrets/DEV.xcconfig.template Projects/App/Config/Secrets/DEV.xcconfig
cp Projects/App/Config/Secrets/PROD.xcconfig.template Projects/App/Config/Secrets/PROD.xcconfig
# 두 파일의 API_BASE_URL 값을 실제 서버 도메인으로 채운다
```