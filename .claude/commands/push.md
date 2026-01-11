---
description: 현재 브랜치를 원격 저장소에 푸시합니다
argument-hint: [remote] [branch]
allowed-tools: Bash
---

# Git Push

## 인자 파싱
- 원격: $ARGUMENTS의 첫 번째 인자 (선택, 기본값: origin)
- 브랜치: $ARGUMENTS의 두 번째 인자 (선택, 기본값: 현재 브랜치)

## 작업 프로세스

### 1단계: 현재 상태 확인

```bash
git status
git branch -vv
git log origin/$(git branch --show-current)..HEAD --oneline 2>/dev/null || echo "새 브랜치"
```

- 현재 브랜치명
- 원격 추적 브랜치 설정 여부
- 푸시할 커밋 목록

### 2단계: 원격 저장소 확인

```bash
git remote -v
git fetch --dry-run
```

원격 저장소 연결 상태와 최신 상태 확인

### 3단계: 푸시 실행

**새 브랜치인 경우** (원격 추적이 없는 경우):

```bash
git push -u origin <current-branch>
```

**기존 브랜치인 경우**:

```bash
git push
```

### 4단계: 결과 확인

```bash
git status
git log origin/$(git branch --show-current)..HEAD --oneline 2>/dev/null
```

## PR 생성 안내

푸시 완료 후 PR이 필요한 경우:

```bash
gh pr create --title "제목" --body "설명"
```

또는 GitHub 웹에서 PR 생성 링크 제공

## 주의사항

- `--force` 옵션은 사용자가 명시적으로 요청한 경우에만 사용
- main/master 브랜치에 직접 푸시하기 전 확인
- 원격 브랜치가 로컬보다 앞서 있으면 먼저 pull/rebase 권고
