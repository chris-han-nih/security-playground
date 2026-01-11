---
description: 병합된 브랜치와 불필요한 브랜치를 정리합니다
argument-hint: [--dry-run]
allowed-tools: Bash
---

# Git 브랜치 정리

## 인자 파싱
- `--dry-run`: 실제 삭제 없이 삭제 대상만 표시

## 작업 프로세스

### 1단계: 원격 저장소 동기화

```bash
git fetch --prune origin
```

삭제된 원격 브랜치 참조 정리

### 2단계: 브랜치 상태 분석

```bash
git branch -vv
git branch --merged main 2>/dev/null || git branch --merged master
```

현재 브랜치들과 병합 상태 확인

### 3단계: 정리 대상 식별

**삭제 대상**:
1. 이미 main/master에 병합된 로컬 브랜치
2. 원격에서 삭제된 브랜치 (`[gone]` 표시)
3. 오래된 미사용 브랜치

**보호 대상** (삭제하지 않음):
- main, master
- develop, development
- 현재 체크아웃된 브랜치

### 4단계: 삭제 대상 목록 표시

```bash
# 병합된 브랜치
git branch --merged main | grep -v "main\|master\|\*"

# [gone] 브랜치
git branch -vv | grep ': gone]' | awk '{print $1}'
```

### 5단계: 브랜치 삭제 (dry-run이 아닌 경우)

**병합된 브랜치 삭제**:

```bash
git branch -d <branch-name>
```

**[gone] 브랜치 삭제**:

```bash
git branch -D <branch-name>
```

### 6단계: 결과 요약

정리 결과 표시:
- 삭제된 로컬 브랜치 수
- 정리된 원격 참조 수
- 남아있는 브랜치 목록

## 추가 정리 옵션

### stale 원격 브랜치 확인

```bash
git for-each-ref --sort=-committerdate refs/remotes/ --format='%(refname:short) %(committerdate:relative)'
```

### 대용량 객체 정리

```bash
git gc --prune=now
```

## 주의사항

- 삭제 전 항상 목록 확인
- 병합되지 않은 브랜치는 `-D` 옵션 필요 (강제 삭제)
- 중요한 작업이 있는 브랜치가 아닌지 확인
