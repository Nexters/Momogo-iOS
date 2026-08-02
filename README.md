# Momogo-iOS

## 로컬 세팅

Xcode 프로젝트/워크스페이스는 gitignore 대상이므로 `tuist install && tuist generate`로 생성한다.

### Base URL (필수)

`API_BASE_URL`은 gitignore 대상인 `Projects/App/Config/Secrets/{Debug,Release}.xcconfig`에서 읽는다. 최초 클론 후 아래를 실행해 로컬 값을 채워야 빌드가 된다 (실값 없이는 빌드가 실패한다):

```sh
cp Projects/App/Config/Secrets/Debug.xcconfig.template Projects/App/Config/Secrets/Debug.xcconfig
cp Projects/App/Config/Secrets/Release.xcconfig.template Projects/App/Config/Secrets/Release.xcconfig
# 두 파일의 API_BASE_URL 값을 실제 서버 도메인으로 채운다
```