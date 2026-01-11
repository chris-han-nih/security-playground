/**
 * 안전한 민감 정보 전송 예제 - JavaScript (Node.js/Express)
 *
 * 이 코드는 민감한 정보를 안전하게 처리하는 패턴을 보여줍니다.
 * POST Body와 Authorization 헤더를 사용하여 쿼리 스트링 노출을 방지합니다.
 *
 * 참조:
 * - OWASP Authentication Cheat Sheet: https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html
 * - CWE-598: https://cwe.mitre.org/data/definitions/598.html
 */

const express = require("express");
const helmet = require("helmet"); // 보안 헤더 설정
const app = express();

// [보안] JSON 파싱 미들웨어
app.use(express.json());

// [보안] Helmet으로 보안 헤더 설정
// Referrer-Policy, X-Content-Type-Options 등 자동 설정
app.use(helmet());

/**
 * [보안] HTTPS 강제 미들웨어
 * HTTP 요청을 HTTPS로 리다이렉트합니다.
 */
function httpsRedirectMiddleware(req, res, next) {
  // 프록시 뒤에서 실행될 경우 X-Forwarded-Proto 헤더 확인
  if (
    req.secure ||
    req.headers["x-forwarded-proto"] === "https" ||
    process.env.NODE_ENV === "development"
  ) {
    next();
  } else {
    res.redirect(301, `https://${req.headers.host}${req.url}`);
  }
}
app.use(httpsRedirectMiddleware);

/**
 * [보안] 로그 마스킹 헬퍼 함수
 * 민감 정보가 로그에 기록되지 않도록 마스킹합니다.
 */
function maskSensitiveData(data) {
  const masked = { ...data };
  const sensitiveFields = ["password", "token", "secret", "apiKey", "ssn"];

  sensitiveFields.forEach((field) => {
    if (masked[field]) {
      masked[field] = "***MASKED***";
    }
  });

  return masked;
}

/**
 * [보안] 안전한 로그인 API
 * POST 메서드만 허용하고, 요청 본문에서 인증 정보를 읽습니다.
 *
 * 요청 예시:
 * POST /api/login
 * Content-Type: application/json
 * { "username": "admin", "password": "secret123" }
 */
app.post("/api/login", (req, res) => {
  const { username, password } = req.body;

  // [보안] 필수 필드 검증
  if (!username || !password) {
    return res.status(400).json({
      success: false,
      message: "Username and password are required",
    });
  }

  // [보안] 로그에는 사용자명만 기록 (비밀번호는 절대 기록하지 않음)
  console.log("Login attempt for user:", username);
  console.log("Request body (masked):", maskSensitiveData(req.body));

  // 인증 로직 (예시)
  if (username === "admin" && password === "secret123") {
    res.json({
      success: true,
      message: "Login successful",
      token: "generated-jwt-token", // 실제로는 JWT 생성
    });
  } else {
    res.status(401).json({
      success: false,
      message: "Invalid credentials",
    });
  }
});

/**
 * [보안] Authorization 헤더를 사용하는 API
 * 토큰은 쿼리 스트링이 아닌 Authorization 헤더로 받습니다.
 *
 * 요청 예시:
 * GET /api/data
 * Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
 */
app.get("/api/data", (req, res) => {
  // [보안] Authorization 헤더에서 토큰 추출
  const authHeader = req.headers.authorization;

  if (!authHeader) {
    return res.status(401).json({
      error: "Authorization header required",
    });
  }

  // [보안] Bearer 토큰 형식 검증
  if (!authHeader.startsWith("Bearer ")) {
    return res.status(401).json({
      error: "Invalid authorization format. Use 'Bearer <token>'",
    });
  }

  const token = authHeader.substring(7);

  // [보안] 토큰은 로그에 전체를 기록하지 않음
  console.log("API request with token:", token.substring(0, 10) + "...");

  // 토큰 검증 로직 (생략)
  res.json({
    data: "Sensitive API response",
    status: "ok",
  });
});

/**
 * [보안] API 키 인증 미들웨어
 * API 키는 쿼리 스트링이 아닌 헤더로 받습니다.
 */
function apiKeyAuth(req, res, next) {
  // [보안] X-API-Key 헤더 사용 (쿼리 스트링 대신)
  const apiKey = req.headers["x-api-key"];

  if (!apiKey) {
    return res.status(401).json({
      error: "API key required. Use X-API-Key header.",
    });
  }

  // API 키 검증 로직 (예시)
  if (apiKey === "valid-api-key") {
    next();
  } else {
    res.status(401).json({ error: "Invalid API key" });
  }
}

/**
 * [보안] API 키로 보호된 엔드포인트
 */
app.get("/api/protected", apiKeyAuth, (req, res) => {
  res.json({
    message: "Protected resource accessed successfully",
  });
});

/**
 * [보안] 개인정보 업데이트 API (PUT/POST 사용)
 *
 * 요청 예시:
 * PUT /api/user/profile
 * Content-Type: application/json
 * { "phone": "010-1234-5678", "email": "user@example.com" }
 */
app.put("/api/user/profile", (req, res) => {
  // [보안] 요청 본문에서 데이터 읽기
  const updateData = req.body;

  // [보안] 민감 정보는 마스킹하여 로그
  console.log("User update request:", maskSensitiveData(updateData));

  res.json({
    success: true,
    message: "Profile updated successfully",
  });
});

/**
 * [보안] Referrer-Policy 헤더 설정
 * 외부 사이트로 이동 시 Referer 헤더에 민감 정보가 포함되지 않도록 합니다.
 */
app.use((req, res, next) => {
  res.setHeader("Referrer-Policy", "strict-origin-when-cross-origin");
  next();
});

// 서버 시작
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Safe server running on port ${PORT}`);
  console.log("Note: In production, use HTTPS!");
});

module.exports = app;
