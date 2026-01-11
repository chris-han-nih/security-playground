---
description: 변경사항을 스테이징하고 커밋합니다
argument-hint: [commit-message]
allowed-tools: Bash
---

# Git 커밋 생성

## 인자 파싱
- 커밋 메시지: $ARGUMENTS (선택, 없으면 자동 생성)

## 작업 프로세스

### 1단계: 현재 상태 확인

```bash
git status
git diff --stat
git diff --staged --stat
```

변경된 파일과 스테이징 상태를 확인합니다.

### 2단계: 변경사항 분석

변경된 파일들을 분석하여:
- 어떤 유형의 변경인지 파악 (취약점 추가, 안전한 패턴, 문서 등)
- 관련 CWE 번호 확인
- 변경 범위 파악

### 3단계: 스테이징

사용자에게 스테이징할 파일을 확인받거나, 모든 변경사항 스테이징:

```bash
git add -A
```

또는 특정 파일만:

```bash
git add <specific-files>
```

### 4단계: 커밋 메시지 작성

**메시지가 제공된 경우**: 해당 메시지 사용

**메시지가 없는 경우**: 변경 내용 기반 자동 생성

커밋 메시지 형식 (Conventional Commits):
- `feat(cwe-xxx): 새 취약점 샘플 추가`
- `fix(cwe-xxx): 샘플 코드 수정`
- `docs: 문서 업데이트`
- `safe(pattern): 안전한 패턴 추가`
- `test: 테스트 코드 추가`
- `chore: 기타 작업`

### 5단계: 커밋 실행

```bash
git commit -m "$(cat <<'EOF'
<commit-message>

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
EOF
)"
```

### 6단계: 결과 확인

```bash
git log -1 --stat
git status
```

## 커밋 전 체크리스트

보안 코드 샘플 프로젝트 특성상:
- [ ] 실제 자격 증명이나 API 키가 포함되지 않았는지 확인
- [ ] 취약한 코드에 적절한 WARNING 주석이 있는지 확인
- [ ] 파일 명명 규칙을 따르는지 확인

## 주의사항

- .env 파일이나 credentials 파일은 커밋하지 않음
- 민감한 정보가 포함된 파일은 경고 표시
