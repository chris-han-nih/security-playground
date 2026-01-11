---
description: Git 브랜치를 생성하거나 관리합니다
argument-hint: <branch-name> [base-branch]
allowed-tools: Bash
---

# Git 브랜치 관리

## 인자 파싱
- 브랜치명: $ARGUMENTS의 첫 번째 인자
- 베이스 브랜치: $ARGUMENTS의 두 번째 인자 (선택, 기본값: 현재 브랜치)

## 작업 프로세스

### 1단계: 현재 상태 확인

```bash
git status
git branch -a
```

현재 브랜치와 로컬/원격 브랜치 목록을 확인합니다.

### 2단계: 브랜치 작업 수행

**브랜치명이 제공된 경우**:
1. 해당 이름으로 새 브랜치 생성
2. 베이스 브랜치가 지정되면 해당 브랜치에서 분기
3. 새 브랜치로 체크아웃

```bash
git checkout -b <branch-name> [base-branch]
```

**브랜치명이 없는 경우**:
- 현재 브랜치 정보와 전체 브랜치 목록 표시

### 3단계: 결과 확인

브랜치 생성 후 상태 표시:
- 현재 브랜치명
- 베이스 브랜치와의 관계
- 원격 추적 상태

## 브랜치 명명 규칙 권장

보안 프로젝트에 맞는 브랜치명 형식:
- `feature/cwe-xxx-description`: 새 취약점 샘플 추가
- `fix/cwe-xxx-issue`: 샘플 수정
- `docs/update-xxx`: 문서 업데이트
- `safe/pattern-xxx`: 안전한 패턴 추가

## 주의사항

- 작업 중인 변경사항이 있으면 먼저 커밋하거나 stash할 것을 권고
- 원격 브랜치가 있는 경우 먼저 fetch하여 최신 상태 확인
