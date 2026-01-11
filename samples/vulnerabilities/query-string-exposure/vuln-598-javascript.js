/**
 * ⚠️ WARNING: 이 코드는 교육 목적의 취약한 예제입니다.
 * 절대로 프로덕션 환경에서 사용하지 마세요!
 *
 * CWE-598: Use of GET Request Method With Sensitive Query Strings
 * 이 코드는 GET 요청의 쿼리 스트링으로 민감한 정보를 받는
 * 취약한 패턴을 보여줍니다.
 */

const express = require("express");
const app = express();

/**
 * [취약점] GET 메서드로 로그인 처리
 * 요청 예시: GET /login?username=admin&password=secret123
 *
 * 문제점:
 * 1. 서버 액세스 로그에 비밀번호가 평문으로 기록됨
 * 2. 브라우저 히스토리에 비밀번호가 저장됨
 * 3. Referer 헤더를 통해 다른 사이트로 유출될 수 있음
 */
app.get("/login", (req, res) => {
  // [취약점] 쿼리 파라미터에서 민감 정보를 읽음
  const { username, password } = req.query; // ⚠️ 비밀번호가 URL에 노출!

  // 로그 기록 - 실제 환경에서는 이 로그에 비밀번호가 포함됨
  console.log(`Login attempt: ${req.originalUrl}`); // ⚠️ 전체 URL이 로그에 기록됨

  // 간단한 인증 로직 (예시)
  if (username === "admin" && password === "secret123") {
    res.json({ success: true, message: `Welcome, ${username}!` });
  } else {
    res.status(401).json({ success: false, message: "Invalid credentials" });
  }
});

/**
 * [취약점] 쿼리 스트링으로 인증 토큰을 전달받는 API
 * 요청 예시: GET /api/data?token=eyJhbGciOiJIUzI1NiIs...
 */
app.get("/api/data", (req, res) => {
  // [취약점] 인증 토큰을 쿼리 파라미터로 받음
  const { token } = req.query; // ⚠️ 토큰이 URL에 노출!

  if (!token) {
    return res.status(401).json({ error: "Token required" });
  }

  // 토큰 검증 로직 (생략)
  res.json({
    data: "Sensitive information",
    tokenPreview: token.substring(0, 10) + "...",
  });
});

/**
 * [취약점] 쿼리 스트링으로 API 키를 전달받는 핸들러
 * 요청 예시: GET /api/external?api_key=sk-1234567890abcdef
 */
app.get("/api/external", (req, res) => {
  // [취약점] API 키를 쿼리 파라미터로 받음
  const { api_key } = req.query; // ⚠️ API 키가 URL에 노출!

  if (!api_key) {
    return res.status(401).json({ error: "API key required" });
  }

  // 외부 API 호출 로직 (생략)
  res.json({ message: "External API called successfully" });
});

/**
 * [취약점] 쿼리 스트링으로 결제 정보를 전달받는 핸들러
 * 요청 예시: GET /payment?card_number=1234-5678-9012-3456&cvv=123
 */
app.get("/payment", (req, res) => {
  // [취약점] 결제 정보를 쿼리 파라미터로 받음
  const { card_number, cvv } = req.query; // ⚠️ 카드 정보가 URL에 노출!

  console.log(`Payment request: ${req.originalUrl}`); // ⚠️ 카드 정보가 로그에 기록됨

  res.json({ message: "Payment processed" });
});

// 서버 시작 (교육 목적 - 실제로 실행하지 마세요)
const PORT = 3000;
console.log("⚠️ WARNING: This is a vulnerable example server!");
console.log(`Server would start on port ${PORT}...`);

// 테스트 목적으로 실행 가능 - run-test.sh 스크립트 사용
app.listen(PORT);

module.exports = app;
