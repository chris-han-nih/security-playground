# CWE-598: 쿼리 스트링을 통한 민감 정보 노출

## 개요

**CWE-598**: Use of GET Request Method With Sensitive Query Strings

HTTP GET 요청의 쿼리 스트링(Query String)에 민감한 정보(비밀번호, 토큰, 개인정보 등)를 포함하여 전송할 때 발생하는 보안 취약점입니다.

## HTTPS에서도 안전하지 않은 이유

HTTPS를 사용하면 **통신 구간에서는** 쿼리 스트링이 암호화됩니다. 그러나 다음과 같은 경로로 민감 정보가 노출될 수 있습니다:

### 1. 서버 액세스 로그 (Server Access Logs)

```
# Nginx access.log 예시
192.168.1.100 - - [11/Jan/2026:10:15:30 +0900] "GET /login?username=admin&password=secret123 HTTP/1.1" 200 1234
```

웹 서버(Nginx, Apache), WAS(Tomcat), 로드 밸런서(AWS ELB)의 액세스 로그에 URL 전체가 **평문**으로 기록됩니다.

### 2. 브라우저 히스토리 (Browser History)

사용자의 브라우저 방문 기록에 쿼리 스트링이 포함된 전체 URL이 저장됩니다. 공용 PC나 타인이 접근 가능한 기기에서 노출 위험이 있습니다.

### 3. Referer 헤더 (HTTP Referer Header)

```
# 다른 사이트로 이동할 때 전송되는 Referer 헤더
Referer: https://example.com/login?username=admin&password=secret123
```

사용자가 해당 페이지에서 다른 사이트로 이동할 때, 이전 페이지의 전체 URL이 Referer 헤더에 담겨 전송됩니다.

### 4. 기타 노출 경로

- 프록시 서버 로그
- 방화벽/IDS 로그
- 브라우저 확장 프로그램
- 북마크 저장 시

## 취약점 영향 (Impact)

| 구분 | HTTP | HTTPS |
|------|------|-------|
| 도메인/IP | 노출 | 노출 |
| URL Path | 노출 | 암호화 |
| Query String | 노출 | 암호화 (단, 위 경로로 노출) |
| Header/Body | 노출 | 암호화 |

## 샘플 코드 설명

### vuln-598-go.go
Go 언어의 net/http 패키지를 사용한 취약한 로그인 핸들러 예제입니다. GET 요청의 쿼리 파라미터로 사용자명과 비밀번호를 받습니다.

### vuln-598-javascript.js
Express.js 기반의 취약한 인증 API 예제입니다. 쿼리 스트링으로 인증 토큰을 전달받습니다.

### vuln-598-html.html
HTML 로그인 폼 예제입니다. GET 메서드로 폼을 전송하여 비밀번호가 URL에 노출됩니다.

## 참조 링크

- [CWE-598: Use of GET Request Method With Sensitive Query Strings](https://cwe.mitre.org/data/definitions/598.html)
- [OWASP Top 10 - A01:2021 Broken Access Control](https://owasp.org/Top10/A01_2021-Broken_Access_Control/)
- [OWASP Authentication Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html)
