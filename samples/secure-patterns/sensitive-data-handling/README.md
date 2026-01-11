# 민감 정보 안전하게 전송하기

## 개요

민감한 정보(비밀번호, 토큰, 개인정보 등)를 HTTP 요청으로 전송할 때 안전한 방법을 설명합니다.

**핵심 원칙**: 민감한 정보는 절대로 URL(쿼리 스트링)에 포함하지 않습니다.

## 권장 방법

### 1. HTTP POST Body 사용

가장 일반적인 방법으로, 민감한 데이터를 요청 본문(Request Body)에 담아 전송합니다.

```http
POST /api/login HTTP/1.1
Host: example.com
Content-Type: application/json

{
    "username": "admin",
    "password": "secret123"
}
```

**장점:**
- URL에 민감 정보가 노출되지 않음
- 서버 액세스 로그에 본문 내용이 기록되지 않음 (기본 설정)
- 브라우저 히스토리에 저장되지 않음
- Referer 헤더로 유출되지 않음

### 2. Authorization 헤더 사용

인증 토큰은 `Authorization` 헤더를 통해 전송합니다.

```http
GET /api/data HTTP/1.1
Host: example.com
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**장점:**
- 표준화된 인증 방식
- 서버 로그에 기본적으로 기록되지 않음
- CORS preflight 요청 시 자동 포함

### 3. 쿠키 사용 (HttpOnly, Secure)

세션 기반 인증에서는 보안 속성이 설정된 쿠키를 사용합니다.

```http
Set-Cookie: session_id=abc123; HttpOnly; Secure; SameSite=Strict
```

## HTTP 메서드 비교

| 구분 | GET (쿼리 스트링) | POST (Body) | Header |
|------|-------------------|-------------|--------|
| 서버 로그 노출 | O (위험) | X | X |
| 브라우저 히스토리 | O (위험) | X | X |
| Referer 헤더 노출 | O (위험) | X | X |
| 북마크 저장 | O (위험) | X | X |
| 캐시 저장 | O (위험) | X | X |

## 추가 보안 조치

### HTTPS 강제 적용

```go
// Go 예시: HTTPS 리다이렉트 미들웨어
if r.TLS == nil {
    http.Redirect(w, r, "https://"+r.Host+r.RequestURI, http.StatusMovedPermanently)
}
```

### 민감 정보 로그 마스킹

```javascript
// 로그에서 민감 정보 마스킹
const maskedBody = { ...req.body, password: '***' };
console.log('Request:', maskedBody);
```

### Referrer-Policy 헤더

```http
Referrer-Policy: strict-origin-when-cross-origin
```

## 샘플 코드 설명

### safe-post-body-go.go
Go 언어의 net/http 패키지를 사용한 안전한 로그인 핸들러입니다. POST 메서드로 JSON Body를 받아 처리합니다.

### safe-post-body-javascript.js
Express.js 기반의 안전한 인증 API입니다. POST Body와 Authorization 헤더를 사용하며, HTTPS 강제 미들웨어가 포함되어 있습니다.

### safe-post-body-html.html
안전한 프론트엔드 로그인 폼입니다. POST 메서드와 fetch API를 사용하여 JSON Body로 데이터를 전송합니다.

## 참조 링크

- [OWASP Authentication Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html)
- [OWASP Session Management Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Session_Management_Cheat_Sheet.html)
- [CWE-598: Use of GET Request Method With Sensitive Query Strings](https://cwe.mitre.org/data/definitions/598.html)
- [MDN: Referrer-Policy](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Referrer-Policy)
