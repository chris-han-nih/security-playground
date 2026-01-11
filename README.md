# Security Playground

보안 취약점 교육 및 안전한 코딩 패턴 학습을 위한 코드 저장소입니다.

> **경고**: 이 프로젝트에 포함된 취약한 코드는 **교육 목적으로만** 사용해야 합니다. 절대로 프로덕션 환경에서 사용하지 마세요.

## 프로젝트 소개

Security Playground는 CWE(Common Weakness Enumeration) 기반의 보안 취약점을 학습하고, 안전한 코딩 패턴을 익힐 수 있도록 설계된 교육용 프로젝트입니다.

### 주요 기능
- 다양한 보안 취약점의 실제 코드 예제 제공
- 취약한 코드와 안전한 코드 비교 학습
- 다중 언어 지원 (JavaScript, Go, HTML)

## 프로젝트 구조

```
security-playground/
├── samples/
│   ├── vulnerabilities/           # 취약한 코드 예제
│   │   ├── query-string-exposure/ # CWE-598: 쿼리 스트링 노출
│   │   ├── sql-injection/         # CWE-89: SQL 인젝션
│   │   ├── xss/                   # CWE-79: 크로스 사이트 스크립팅
│   │   ├── buffer-overflow/       # CWE-120: 버퍼 오버플로우
│   │   ├── hardcoded-credentials/ # CWE-798: 하드코딩된 자격 증명
│   │   └── path-traversal/        # CWE-22: 경로 탐색
│   ├── secure-patterns/           # 안전한 코딩 패턴
│   │   ├── input-validation/      # 입력 검증
│   │   ├── output-encoding/       # 출력 인코딩
│   │   └── parameterized-queries/ # 매개변수화된 쿼리
│   └── tests/                     # 테스트 코드
└── .claude/                       # Claude Code 설정
```

## 설치 및 실행

### 요구사항
- Node.js (v18 이상)
- Go (v1.20 이상)

### 설치

```bash
git clone https://github.com/your-username/security-playground.git
cd security-playground
```

### 샘플 실행

JavaScript 예제 실행:
```bash
cd samples/vulnerabilities/query-string-exposure
npm install
node vuln-598-javascript.js
```

Go 예제 실행:
```bash
cd samples/vulnerabilities/query-string-exposure
go run vuln-598-go.go
```

## 취약점 목록

| CWE ID | 취약점 | 설명 | 상태 |
|--------|--------|------|------|
| CWE-598 | Query String Exposure | GET 요청에 민감 정보 노출 | 구현완료 |
| CWE-89 | SQL Injection | SQL 쿼리 삽입 공격 | 예정 |
| CWE-79 | XSS | 크로스 사이트 스크립팅 | 예정 |
| CWE-120 | Buffer Overflow | 버퍼 오버플로우 | 예정 |
| CWE-798 | Hardcoded Credentials | 하드코딩된 자격 증명 | 예정 |
| CWE-22 | Path Traversal | 경로 탐색 취약점 | 예정 |

## 참고 자료

- [CWE - Common Weakness Enumeration](https://cwe.mitre.org/)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)

## 라이선스

MIT License
