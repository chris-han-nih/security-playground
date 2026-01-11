#!/bin/bash

# CWE-598: Query String Exposure 취약점 테스트 스크립트
# 이 스크립트는 교육 목적으로만 사용하세요.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GO_SERVER_PID=""
NODE_SERVER_PID=""

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 정리 함수
cleanup() {
    echo -e "\n${YELLOW}서버 종료 중...${NC}"
    if [ -n "$GO_SERVER_PID" ] && kill -0 "$GO_SERVER_PID" 2>/dev/null; then
        kill "$GO_SERVER_PID" 2>/dev/null || true
        echo "Go 서버 종료됨 (PID: $GO_SERVER_PID)"
    fi
    if [ -n "$NODE_SERVER_PID" ] && kill -0 "$NODE_SERVER_PID" 2>/dev/null; then
        kill "$NODE_SERVER_PID" 2>/dev/null || true
        echo "Node.js 서버 종료됨 (PID: $NODE_SERVER_PID)"
    fi
}

trap cleanup EXIT

# 배너 출력
print_banner() {
    echo -e "${RED}"
    echo "=============================================="
    echo "  CWE-598: Query String Exposure Test"
    echo "  WARNING: 교육 목적으로만 사용하세요!"
    echo "=============================================="
    echo -e "${NC}"
}

# 취약점 설명 출력
print_vulnerability_info() {
    echo -e "${YELLOW}"
    echo "=== 취약점 설명 ==="
    echo "쿼리 스트링에 민감 정보(비밀번호, 토큰 등)를 포함하면:"
    echo "  1. 서버 액세스 로그에 평문으로 기록됨"
    echo "  2. 브라우저 히스토리에 저장됨"
    echo "  3. Referer 헤더로 외부 사이트에 유출될 수 있음"
    echo -e "${NC}"
}

# Go 서버 테스트
test_go_server() {
    echo -e "\n${BLUE}=== Go 서버 테스트 ===${NC}\n"

    # Go 설치 확인
    if ! command -v go &> /dev/null; then
        echo -e "${RED}Error: Go가 설치되어 있지 않습니다.${NC}"
        echo "설치: https://golang.org/doc/install"
        return 1
    fi

    echo "Go 버전: $(go version)"
    echo -e "\n${YELLOW}서버 시작 중... (포트 8080)${NC}\n"

    # 서버 백그라운드 실행
    cd "$SCRIPT_DIR"
    go run vuln-598-go.go &
    GO_SERVER_PID=$!

    # 서버 시작 대기
    sleep 2

    if ! kill -0 "$GO_SERVER_PID" 2>/dev/null; then
        echo -e "${RED}서버 시작 실패${NC}"
        return 1
    fi

    echo -e "${GREEN}서버 시작됨 (PID: $GO_SERVER_PID)${NC}\n"

    # 테스트 요청
    echo -e "${YELLOW}=== 테스트 1: 로그인 (비밀번호 노출) ===${NC}"
    echo -e "요청: ${RED}GET /login?username=admin&password=secret123${NC}"
    echo -e "응답:"
    curl -s "http://localhost:8080/login?username=admin&password=secret123"
    echo -e "\n"

    echo -e "${YELLOW}=== 테스트 2: API 토큰 (토큰 노출) ===${NC}"
    echo -e "요청: ${RED}GET /api/data?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9${NC}"
    echo -e "응답:"
    curl -s "http://localhost:8080/api/data?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9"
    echo -e "\n"

    echo -e "${YELLOW}=== 테스트 3: 개인정보 (개인정보 노출) ===${NC}"
    echo -e "요청: ${RED}GET /user/update?ssn=123-45-6789&phone=010-1234-5678${NC}"
    echo -e "응답:"
    curl -s "http://localhost:8080/user/update?ssn=123-45-6789&phone=010-1234-5678"
    echo -e "\n"

    echo -e "${RED}"
    echo "=== 취약점 확인 포인트 ==="
    echo "위의 서버 로그를 확인하세요!"
    echo "- 비밀번호, 토큰, 개인정보가 URL에 평문으로 기록됨"
    echo "- 이 로그는 공격자가 접근할 수 있는 위치에 저장될 수 있음"
    echo -e "${NC}"

    # 서버 종료
    kill "$GO_SERVER_PID" 2>/dev/null || true
    GO_SERVER_PID=""
    echo -e "${GREEN}Go 서버 테스트 완료${NC}"
}

# Node.js 서버 테스트
test_node_server() {
    echo -e "\n${BLUE}=== Node.js 서버 테스트 ===${NC}\n"

    # Node.js 설치 확인
    if ! command -v node &> /dev/null; then
        echo -e "${RED}Error: Node.js가 설치되어 있지 않습니다.${NC}"
        echo "설치: https://nodejs.org/"
        return 1
    fi

    echo "Node.js 버전: $(node --version)"

    cd "$SCRIPT_DIR"

    # express 설치 확인
    if [ ! -d "node_modules/express" ]; then
        echo -e "${YELLOW}express 패키지 설치 중...${NC}"
        npm init -y > /dev/null 2>&1
        npm install express > /dev/null 2>&1
    fi

    echo -e "\n${YELLOW}서버 시작 중... (포트 3000)${NC}\n"

    # 서버 백그라운드 실행
    node vuln-598-javascript.js &
    NODE_SERVER_PID=$!

    # 서버 시작 대기
    sleep 2

    if ! kill -0 "$NODE_SERVER_PID" 2>/dev/null; then
        echo -e "${RED}서버 시작 실패${NC}"
        return 1
    fi

    echo -e "${GREEN}서버 시작됨 (PID: $NODE_SERVER_PID)${NC}\n"

    # 테스트 요청
    echo -e "${YELLOW}=== 테스트 1: 로그인 (비밀번호 노출) ===${NC}"
    echo -e "요청: ${RED}GET /login?username=admin&password=secret123${NC}"
    echo -e "응답:"
    curl -s "http://localhost:3000/login?username=admin&password=secret123" | python3 -m json.tool 2>/dev/null || curl -s "http://localhost:3000/login?username=admin&password=secret123"
    echo -e "\n"

    echo -e "${YELLOW}=== 테스트 2: API 토큰 (토큰 노출) ===${NC}"
    echo -e "요청: ${RED}GET /api/data?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9${NC}"
    echo -e "응답:"
    curl -s "http://localhost:3000/api/data?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9" | python3 -m json.tool 2>/dev/null || curl -s "http://localhost:3000/api/data?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9"
    echo -e "\n"

    echo -e "${YELLOW}=== 테스트 3: 결제 정보 (카드 정보 노출) ===${NC}"
    echo -e "요청: ${RED}GET /payment?card_number=1234-5678-9012-3456&cvv=123${NC}"
    echo -e "응답:"
    curl -s "http://localhost:3000/payment?card_number=1234-5678-9012-3456&cvv=123" | python3 -m json.tool 2>/dev/null || curl -s "http://localhost:3000/payment?card_number=1234-5678-9012-3456&cvv=123"
    echo -e "\n"

    echo -e "${RED}"
    echo "=== 취약점 확인 포인트 ==="
    echo "위의 서버 로그를 확인하세요!"
    echo "- 비밀번호, 토큰, 카드 정보가 URL에 평문으로 기록됨"
    echo "- 이 로그는 공격자가 접근할 수 있는 위치에 저장될 수 있음"
    echo -e "${NC}"

    # 서버 종료
    kill "$NODE_SERVER_PID" 2>/dev/null || true
    NODE_SERVER_PID=""
    echo -e "${GREEN}Node.js 서버 테스트 완료${NC}"
}

# HTML 페이지 열기
open_html() {
    echo -e "\n${BLUE}=== HTML 페이지 열기 ===${NC}\n"

    HTML_FILE="$SCRIPT_DIR/vuln-598-html.html"

    if [ ! -f "$HTML_FILE" ]; then
        echo -e "${RED}Error: HTML 파일을 찾을 수 없습니다.${NC}"
        return 1
    fi

    echo "파일: $HTML_FILE"

    # OS에 따라 브라우저 열기
    if [[ "$OSTYPE" == "darwin"* ]]; then
        open "$HTML_FILE"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        xdg-open "$HTML_FILE" 2>/dev/null || sensible-browser "$HTML_FILE"
    else
        echo -e "${YELLOW}브라우저에서 다음 파일을 열어주세요:${NC}"
        echo "$HTML_FILE"
    fi

    echo -e "${GREEN}HTML 페이지 열기 완료${NC}"
}

# 메인 메뉴
show_menu() {
    echo -e "\n${BLUE}테스트 선택:${NC}"
    echo "  1) Go 서버 테스트 (포트 8080)"
    echo "  2) Node.js 서버 테스트 (포트 3000)"
    echo "  3) HTML 페이지 열기"
    echo "  4) 모든 테스트 실행"
    echo "  5) 종료"
    echo ""
    read -p "선택 (1-5): " choice

    case $choice in
        1) test_go_server ;;
        2) test_node_server ;;
        3) open_html ;;
        4)
            test_go_server
            echo ""
            test_node_server
            echo ""
            open_html
            ;;
        5)
            echo -e "${GREEN}종료합니다.${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}잘못된 선택입니다.${NC}"
            ;;
    esac
}

# 메인 실행
main() {
    print_banner
    print_vulnerability_info

    while true; do
        show_menu
    done
}

main
