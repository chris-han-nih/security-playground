// 안전한 민감 정보 전송 예제 - Go
//
// 이 코드는 민감한 정보를 안전하게 처리하는 패턴을 보여줍니다.
// POST Body와 Authorization 헤더를 사용하여 쿼리 스트링 노출을 방지합니다.
//
// 참조:
// - OWASP Authentication Cheat Sheet: https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html
// - CWE-598: https://cwe.mitre.org/data/definitions/598.html

package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"strings"
)

// LoginRequest는 로그인 요청 본문 구조체입니다.
// [보안] 민감 정보는 URL이 아닌 요청 본문으로 받습니다.
type LoginRequest struct {
	Username string `json:"username"`
	Password string `json:"password"`
}

// LoginResponse는 로그인 응답 구조체입니다.
type LoginResponse struct {
	Success bool   `json:"success"`
	Message string `json:"message"`
	Token   string `json:"token,omitempty"`
}

// [보안] HTTPS 강제 미들웨어
// HTTP 요청을 HTTPS로 리다이렉트합니다.
func httpsRedirectMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// [보안] TLS가 아닌 요청은 HTTPS로 리다이렉트
		if r.TLS == nil && r.Header.Get("X-Forwarded-Proto") != "https" {
			httpsURL := "https://" + r.Host + r.RequestURI
			http.Redirect(w, r, httpsURL, http.StatusMovedPermanently)
			return
		}
		next.ServeHTTP(w, r)
	})
}

// [보안] 로그 마스킹 헬퍼 함수
// 민감 정보가 로그에 기록되지 않도록 마스킹합니다.
func maskSensitiveLog(format string, username string) {
	// [보안] 비밀번호는 절대 로그에 기록하지 않음
	log.Printf(format, username)
}

// [보안] 안전한 로그인 핸들러
// POST 메서드만 허용하고, 요청 본문에서 인증 정보를 읽습니다.
func safeLoginHandler(w http.ResponseWriter, r *http.Request) {
	// [보안] POST 메서드만 허용
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed. Use POST.", http.StatusMethodNotAllowed)
		return
	}

	// [보안] Content-Type 검증
	contentType := r.Header.Get("Content-Type")
	if !strings.HasPrefix(contentType, "application/json") {
		http.Error(w, "Content-Type must be application/json", http.StatusUnsupportedMediaType)
		return
	}

	// [보안] 요청 본문에서 로그인 정보 파싱
	var loginReq LoginRequest
	decoder := json.NewDecoder(r.Body)
	if err := decoder.Decode(&loginReq); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}
	defer r.Body.Close()

	// [보안] 로그에는 사용자명만 기록 (비밀번호는 절대 기록하지 않음)
	maskSensitiveLog("Login attempt for user: %s", loginReq.Username)

	// 인증 로직 (예시)
	response := LoginResponse{}
	if loginReq.Username == "admin" && loginReq.Password == "secret123" {
		response.Success = true
		response.Message = "Login successful"
		response.Token = "generated-jwt-token" // 실제로는 JWT 생성
	} else {
		response.Success = false
		response.Message = "Invalid credentials"
	}

	// [보안] JSON 응답
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

// [보안] Authorization 헤더를 사용하는 API 핸들러
// 토큰은 쿼리 스트링이 아닌 Authorization 헤더로 받습니다.
func safeAPIHandler(w http.ResponseWriter, r *http.Request) {
	// [보안] Authorization 헤더에서 토큰 추출
	authHeader := r.Header.Get("Authorization")
	if authHeader == "" {
		http.Error(w, "Authorization header required", http.StatusUnauthorized)
		return
	}

	// [보안] Bearer 토큰 형식 검증
	if !strings.HasPrefix(authHeader, "Bearer ") {
		http.Error(w, "Invalid authorization format. Use 'Bearer <token>'", http.StatusUnauthorized)
		return
	}

	token := strings.TrimPrefix(authHeader, "Bearer ")

	// 토큰 검증 로직 (예시)
	if token == "" {
		http.Error(w, "Token is empty", http.StatusUnauthorized)
		return
	}

	// [보안] 토큰은 로그에 전체를 기록하지 않음
	log.Printf("API request with token: %s...", token[:min(10, len(token))])

	// API 응답
	w.Header().Set("Content-Type", "application/json")
	fmt.Fprintf(w, `{"data": "Sensitive API response", "status": "ok"}`)
}

// [보안] 개인정보 업데이트 핸들러 (PUT/POST 사용)
func safeUserUpdateHandler(w http.ResponseWriter, r *http.Request) {
	// [보안] PUT 또는 POST 메서드만 허용
	if r.Method != http.MethodPut && r.Method != http.MethodPost {
		http.Error(w, "Method not allowed. Use PUT or POST.", http.StatusMethodNotAllowed)
		return
	}

	// [보안] 요청 본문에서 데이터 읽기
	var updateData map[string]string
	if err := json.NewDecoder(r.Body).Decode(&updateData); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}
	defer r.Body.Close()

	// [보안] 민감 정보는 마스킹하여 로그
	log.Printf("User update request received (fields: %d)", len(updateData))

	w.Header().Set("Content-Type", "application/json")
	fmt.Fprintf(w, `{"success": true, "message": "User info updated"}`)
}

func min(a, b int) int {
	if a < b {
		return a
	}
	return b
}

func main() {
	mux := http.NewServeMux()

	// 안전한 핸들러 등록
	mux.HandleFunc("/api/login", safeLoginHandler)
	mux.HandleFunc("/api/data", safeAPIHandler)
	mux.HandleFunc("/api/user/update", safeUserUpdateHandler)

	// HTTPS 강제 미들웨어 적용
	handler := httpsRedirectMiddleware(mux)

	fmt.Println("Safe server starting on :8080...")
	fmt.Println("Note: In production, use TLS certificates!")

	// 실제 프로덕션에서는 TLS 사용
	// log.Fatal(http.ListenAndServeTLS(":443", "cert.pem", "key.pem", handler))
	log.Fatal(http.ListenAndServe(":8080", handler))
}
