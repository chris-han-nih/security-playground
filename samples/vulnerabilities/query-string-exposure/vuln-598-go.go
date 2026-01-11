// ⚠️ WARNING: 이 코드는 교육 목적의 취약한 예제입니다.
// 절대로 프로덕션 환경에서 사용하지 마세요!
//
// CWE-598: Use of GET Request Method With Sensitive Query Strings
// 이 코드는 GET 요청의 쿼리 스트링으로 민감한 정보(비밀번호)를 받는
// 취약한 패턴을 보여줍니다.

package main

import (
	"fmt"
	"log"
	"net/http"
)

// [취약점] GET 메서드로 로그인 처리 - 비밀번호가 URL에 노출됨
// 요청 예시: GET /login?username=admin&password=secret123
//
// 문제점:
// 1. 서버 액세스 로그에 비밀번호가 평문으로 기록됨
// 2. 브라우저 히스토리에 비밀번호가 저장됨
// 3. Referer 헤더를 통해 다른 사이트로 유출될 수 있음
func vulnerableLoginHandler(w http.ResponseWriter, r *http.Request) {
	// [취약점] 쿼리 파라미터에서 민감 정보를 읽음
	username := r.URL.Query().Get("username")
	password := r.URL.Query().Get("password") // ⚠️ 비밀번호가 URL에 노출!

	// 로그 기록 - 실제 환경에서는 이 로그에 비밀번호가 포함됨
	log.Printf("Login attempt: %s", r.URL.String()) // ⚠️ 전체 URL이 로그에 기록됨

	// 간단한 인증 로직 (예시)
	if username == "admin" && password == "secret123" {
		fmt.Fprintf(w, "Login successful for user: %s", username)
	} else {
		http.Error(w, "Invalid credentials", http.StatusUnauthorized)
	}
}

// [취약점] 쿼리 스트링으로 API 토큰을 전달받는 핸들러
// 요청 예시: GET /api/data?token=eyJhbGciOiJIUzI1NiIs...
func vulnerableAPIHandler(w http.ResponseWriter, r *http.Request) {
	// [취약점] 인증 토큰을 쿼리 파라미터로 받음
	token := r.URL.Query().Get("token") // ⚠️ 토큰이 URL에 노출!

	if token == "" {
		http.Error(w, "Token required", http.StatusUnauthorized)
		return
	}

	// 토큰 검증 로직 (생략)
	fmt.Fprintf(w, "API response with token: %s...", token[:10])
}

// [취약점] 개인정보를 쿼리 스트링으로 전달받는 핸들러
// 요청 예시: GET /user/update?ssn=123-45-6789&phone=010-1234-5678
func vulnerableUserUpdateHandler(w http.ResponseWriter, r *http.Request) {
	// [취약점] 개인정보를 쿼리 파라미터로 받음
	ssn := r.URL.Query().Get("ssn")     // ⚠️ 주민등록번호가 URL에 노출!
	phone := r.URL.Query().Get("phone") // ⚠️ 전화번호가 URL에 노출!

	fmt.Fprintf(w, "Updated user info: SSN=%s, Phone=%s", ssn, phone)
}

func main() {
	// 이 서버는 교육 목적으로만 사용하세요
	http.HandleFunc("/login", vulnerableLoginHandler)
	http.HandleFunc("/api/data", vulnerableAPIHandler)
	http.HandleFunc("/user/update", vulnerableUserUpdateHandler)

	fmt.Println("⚠️ WARNING: This is a vulnerable example server!")
	fmt.Println("Starting server on :8080...")

	// 테스트 목적으로 실행 가능 - run-test.sh 스크립트 사용
	log.Fatal(http.ListenAndServe(":8080", nil))
}
