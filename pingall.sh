#!/bin/bash

show_help() {
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  BLUE='\033[0;34m'
  PURPLE='\033[0;35m'
  NC='\033[0m' # Remove Color

  echo "Usage: pingall [OPTIONS]... [HOST]..."
  echo "Send ICMP ECHO_REQUEST to network hosts using both IPv4 and IPv6."
  echo
  echo "This script can directly ping URLs with http or https protocols,"
  echo "including URLs with paths, e.g., https://example.com/abc/def."
  echo
  echo "Options:"
  echo "  -h, --help       display this help and exit"
  echo "  -c count         number of times to ping the host"
  echo "  All other options supported by ping and ping6 can also be used."
  echo "Examples:"
  echo -e "  Ping a single host: ${PURPLE}pingall google.com${NC}"
  echo -e "  Ping a URL with http/https protocol: ${PURPLE}pingall http://example.com/path${NC}"
  echo -e "  Specifying ping count: ${PURPLE}pingall -c 4 google.com${NC}"
  echo -e "  Display help: ${PURPLE}pingall -h${NC}"
}


pingall() {
    # 显示帮助信息并退出，如果提供 -h, --help 或没有参数
  if [[ $# -eq 0 || $1 == "-h" || $1 == "--help" ]]; then
    show_help
    return 0
  fi

  local params=()
  local host
  local count_param_found=false

  # 着色代码
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  BLUE='\033[0;34m'
  PURPLE='\033[0;35m'
  NC='\033[0m' # No Color

  # 遍历所有传入的参数
  while [[ $# -gt 0 ]]; do
    case $1 in
      -c)
        # 如果找到 -c 参数，则记录并添加到参数列表
        count_param_found=true
        params+=("$1")
        shift
        if [[ $# -gt 0 ]]; then
          params+=("$1")
          shift
        fi
        ;;
      -*)
        # 如果参数以横杠开头，添加到参数列表
        params+=("$1")
        shift
        if [[ $# -gt 0 && ! $1 == -* ]]; then
          params+=("$1")
          shift
        fi
        ;;
      *)
        # 如果参数不是以横杠开头，认为是网址
        if [[ -z $host ]]; then
          host=$1
        fi
        shift
        ;;
    esac
  done

  # 如果没有提供网址，则退出
  if [[ -z $host ]]; then
    echo "No target specified. Use -h for help."
    return 1
  fi

  # 如果没有找到 -c 参数，则添加 -c 5
  if [[ $count_param_found == false ]]; then
    params+=("-c" "5")
  fi

  # 对于可能是域名或 URL 的 host
  if [[ $host == *.* && ! $host =~ ^[0-9a-fA-F:]+$ ]]; then
    if [[ $host == http* ]]; then
      # 如果有协议头，提取主机名
      host=$(echo $host | awk -F/ '{print $3}')
      host=${host:-$host}
    fi
  fi

  # 判断地址类型并执行相应的 ping 命令
  if [[ $host =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    # IPv4 地址
    echo -e "${GREEN}Pinging IPv4 address $host${NC}"
    if [[ $count_param_found == false ]]; then
      echo -e "${PURPLE}No Count specified, -c 5 added automatically.${NC}"
    fi
    ping "${params[@]}" $host
    echo -e "${RED}Skipping ping6 for IPv4 address.${NC}"
  elif [[ $host =~ ^[0-9a-fA-F:]+$ ]]; then
    # IPv6 地址
    echo -e "${GREEN}Pinging IPv6 address $host${NC}"
    if [[ $count_param_found == false ]]; then
      echo -e "${PURPLE}No Count specified, -c 5 added automatically.${NC}"
    fi
    ping6 "${params[@]}" $host
    echo -e "${RED}Skipping ping for IPv6 address.${NC}"
  else
    # 域名
    echo -e "${GREEN}Pinging IPv4 address $host${NC}"
    if [[ $count_param_found == false ]]; then
      echo -e "${PURPLE}No Count specified, -c 5 added automatically.${NC}"
    fi
    ping "${params[@]}" $host

    echo -e "${GREEN}Pinging IPv6 address $host${NC}"
    if [[ $count_param_found == false ]]; then
      echo -e "${PURPLE}No Count specified, -c 5 added automatically.${NC}"
    fi
    ping6 "${params[@]}" $host
  fi

}

pingall "$@"
