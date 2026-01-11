---
description: 취약한 코드에 대응하는 안전한 버전을 생성합니다
argument-hint: <vulnerability-type> <language>
allowed-tools: Read, Write, WebSearch
---

# 안전한 코드 생성

요청: $ARGUMENTS

## 생성 프로세스

### 1단계: 요청 파싱

인자에서 다음 정보 추출:
- 취약점 유형 (sql-injection, xss, buffer-overflow 등)
- 대상 언어 (python, javascript, java, go, c 등)

### 2단계: 취약한 예제 확인

해당 취약점의 기존 예제가 있는지 확인:
- samples/vulnerabilities/[취약점유형]/

### 3단계: 안전한 코드 생성

다음 원칙에 따라 안전한 코드 작성:
1. **입력 검증**: 모든 외부 입력 검증
2. **파라미터화**: 쿼리/명령 파라미터화
3. **인코딩**: 출력 컨텍스트에 맞는 인코딩
4. **최소 권한**: 필요한 최소 권한만 사용
5. **에러 처리**: 안전한 에러 처리

### 4단계: 파일 생성

파일 위치: samples/secure-patterns/[취약점유형]/safe-[패턴]-[언어].[확장자]

파일 헤더 포함:
- 안전한 코딩 패턴 이름
- 방어 대상 CWE 번호
- 방어 메커니즘 설명
- 참고 자료 링크

### 5단계: 결과 요약

생성된 코드와 함께 다음 정보 제공:
- 적용된 보안 원칙
- 취약한 버전과의 차이점
- 추가 고려사항
