---
description: 현재 브랜치를 대상 브랜치로 리베이스합니다
argument-hint: [target-branch]
allowed-tools: Bash
---

# Git Rebase

## 인자 파싱
- 대상 브랜치: $ARGUMENTS (선택, 기본값: main 또는 master)

## 작업 프로세스

### 1단계: 현재 상태 확인

```bash
git status
git branch --show-current
git stash list
```

- 작업 중인 변경사항이 있는지 확인
- 현재 브랜치명 확인

### 2단계: 대상 브랜치 최신화

```bash
git fetch origin
```

원격 저장소에서 최신 정보 가져오기

### 3단계: 변경사항 보존 (필요시)

작업 중인 변경사항이 있으면:

```bash
git stash push -m "rebase 전 임시 저장"
```

### 4단계: 리베이스 실행

```bash
git rebase origin/<target-branch>
```

또는 로컬 브랜치 기준:

```bash
git rebase <target-branch>
```

### 5단계: 충돌 해결 (발생 시)

충돌이 발생하면:
1. 충돌 파일 목록 표시
2. 각 파일의 충돌 내용 분석
3. 사용자에게 해결 방법 제안
4. 해결 후:

```bash
git add <resolved-files>
git rebase --continue
```

충돌 해결이 어려우면:

```bash
git rebase --abort
```

### 6단계: stash 복원 (필요시)

```bash
git stash pop
```

### 7단계: 결과 확인

```bash
git log --oneline -10
git status
```

## 리베이스 vs 머지

**리베이스 사용 권장**:
- 로컬 브랜치를 최신 main에 맞출 때
- 깔끔한 커밋 히스토리 유지

**머지 사용 권장**:
- 이미 푸시된 브랜치
- 공유 브랜치

## 주의사항

- 이미 푸시된 커밋을 리베이스하면 force push 필요
- 공유 브랜치에서는 리베이스 주의
- 리베이스 중 문제 발생 시 `git rebase --abort`로 원복 가능
