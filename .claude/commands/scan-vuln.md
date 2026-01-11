---
description: 코드 파일 또는 디렉토리에서 보안 취약점을 스캔합니다
argument-hint: <file-or-directory-path>
allowed-tools: Bash(semgrep:*), Bash(bandit:*), Bash(npm audit:*), Grep, Glob, Read
---

# 보안 취약점 스캔

대상 경로: $ARGUMENTS

## 스캔 프로세스

### 1단계: 대상 파일 분석
- 대상 경로의 파일 확장자를 확인하여 언어 식별
- 지원 언어: Python, JavaScript, Java, Go, C/C++

### 2단계: 언어별 정적 분석 도구 실행

**Python 파일 (.py)**: bandit 실행
**JavaScript/TypeScript 파일 (.js, .ts)**: npm audit 실행
**모든 언어**: semgrep 실행 (설치된 경우)

### 3단계: 위험 패턴 검색

Grep으로 다음 패턴 검색:
- SQL 쿼리 문자열 연결
- 하드코딩된 비밀 (password, api_key, secret)
- 위험한 함수 호출
- 취약한 암호화 알고리즘

### 4단계: 결과 리포트

## 스캔 결과 요약

### 발견된 취약점

| 심각도 | 유형 | 파일:라인 | 설명 |
|--------|------|-----------|------|

### 권장 조치
각 취약점에 대한 수정 방법 제안

### 참고 자료
관련 OWASP, CWE 링크
