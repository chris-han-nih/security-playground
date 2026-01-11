# Security Playground - Claude Code 지침

## 프로젝트 개요
보안 코드 샘플 관리 프로젝트 (교육/연구 목적)
- 취약점 예제 코드
- 안전한 코딩 패턴
- 보안 테스트 코드

## 취약점 분류 (CWE 기반)
- CWE-89: SQL Injection
- CWE-79: XSS (Cross-site Scripting)
- CWE-120: Buffer Overflow
- CWE-798: Hardcoded Credentials
- CWE-22: Path Traversal
- CWE-502: Deserialization
- CWE-611: XXE
- CWE-918: SSRF

## 파일 명명 규칙
- 취약점: `vuln-[cwe-id]-[언어].[확장자]`
- 안전한 패턴: `safe-[패턴]-[언어].[확장자]`
- 테스트: `test-[대상]-[언어].[확장자]`

## 코드 작성 규칙

### 취약한 코드
- 파일 상단에 WARNING 주석 필수
- 실행 불가하도록 불완전하게 작성
- 교육 목적 명시

### 안전한 코드
- 방어 메커니즘 주석으로 설명
- OWASP/CWE 참조 링크 포함

## 코드 리뷰 체크리스트
1. 입력 검증
2. 출력 인코딩
3. 인증/인가
4. 에러 처리
5. 암호화
6. 의존성 보안
7. 로깅
8. 세션 관리
9. CSRF 방어
10. 안전한 설정

## 참고 자료
- OWASP Top 10: https://owasp.org/Top10/
- CWE Database: https://cwe.mitre.org/
