#!/bin/bash
# shellcheck disable=SC1090 disable=SC2086 disable=SC2155 disable=SC2128 disable=SC2028 disable=SC2162
[ -z $ROOT_URI ] && source <(curl -sSL https://gitlab.com/iprt/shell-basic/-/raw/main/build-project/basic.sh)
echo -e "\033[0;32mROOT_URI=$ROOT_URI\033[0m"
# ROOT_URI=https://dev.kubectl.net

source <(curl -sSL $ROOT_URI/func/log.sh)

if [ -z "$DNSAPI_ROOT_URI" ]; then
  log_error "dns" "DNSAPI_ROOT_URI is not set"
  exit
fi

if [ -z "$DNSAPI_ACCESS_TOKEN_KEY" ]; then
  log_error "dns" "DNSAPI_ACCESS_TOKEN_KEY is not set"
  exit
fi

if [ -z "$DNSAPI_ACCESS_TOKEN_VALUE" ]; then
  log_error "dns" "DNSAPI_ACCESS_TOKEN_VALUE is not set"
  exit
fi

log_info "dns" "dns 操作"

log_info "input" "请选择云解析DNS的相关操作: (输入数字)"
log_info "input" "  (0) 获取支持的域名列表"
log_info "input" "  (1) 新增一条解析记录"
log_info "input" "  (2) 查询子域名的所有解析记录"
log_info "input" "  (3) 删除子域名的所有解析记录"
log_info "input" "  (4) 删除子域名的所有解析记录，然后新增解析记录"
log_info "input" "  (5) 分页查询域名的解析记录"
log_info "input" "  (*) 退出 exit"

read -p "> 请输入你的选择: " dns_operate

function dnsapi() {
  local domainName=$1
  local rr=$2
  local type=$3
  local value=$4
  local request_url=$5
  local pageNumber=$6
  local pageSize=$7
  local rrKeyWord=$8
  local valueKeyWord=$9

  local api_root_uri="$DNSAPI_ROOT_URI"
  local access_token_key="$DNSAPI_ACCESS_TOKEN_KEY"
  local access_token_value="$DNSAPI_ACCESS_TOKEN_VALUE"
  local json_data='{"domainName":"'$domainName'","rr":"'$rr'","type":"'$type'","value":"'$value'", "pageNumber":"'$pageNumber'", "pageSize":"'$pageSize'", "rrKeyWord":"'$rrKeyWord'", "valueKeyWord":"'$valueKeyWord'"}'

  result=$(curl -sSL --connect-timeout 3 -X POST $api_root_uri$request_url \
    --header "$access_token_key: $access_token_value" \
    --header 'Content-Type: application/json' \
    --data "$json_data")
}

function readDomainName() {
  if [ -n "$domainName" ]; then
    return
  fi

  read -p "请输入域名: " domainName
  log_info "dns" "输入的域名为 $domainName"

  if [ -z "$domainName" ]; then
    log_error "dns" "域名不能为空"
    readDomainName
  fi
}

function readRr() {
  if [ -n "$rr" ]; then
    return
  fi
  read -p "请输入主机记录(Resource Record): " rr
  log_info "dns" "输入的主机记录为 $rr"

  if [ -z $rr ]; then
    log_error "dns" "主机记录不能为空"
    readRr
  fi
}

function readType() {
  read -p "请输入记录类型(默认为A): " type
  log_info "dns" "输入的记录类型为 $type"

  if [ -z $type ]; then
    type="A"
    log_info "dns" "记录类型默认为 $type"
  fi
}

function readValue() {
  read -p "请输入记录值: " value
  log_info "dns" "输入的记录值为 $value"

  if [ -z $value ]; then
    log_error "dns" "记录值不能为空"
    readValue
  fi
}

function readPageNumber() {
  read -p "请输入 pageNumber(默认为1): " pageNumber
  log_info "dns" "输入的pageNumber为 $pageNumber"

  if [ -z $pageNumber ]; then
    pageNumber=1
    log_info "dns" "pageNumber默认为 $pageNumber"
  fi
}

function readPageSize() {
  read -p "请输入 pageSize(默认为20): " pageSize
  log_info "dns" "输入的pageSize为 $pageSize"

  if [ -z $pageSize ]; then
    pageSize=20
    log_info "dns" "pageSize默认为 $pageSize"
  else
    log_info "dns" "pageSize为 $pageSize"
  fi
}

function readRrKeyWord() {
  read -p "请输入主机记录(RR)关键字: " rrKeyWord
  log_info "dns" "输入的主机记录(RR)关键字为 $rrKeyWord"
}

function readValueKeyWord() {
  read -p "请输入记录值(value)关键字: " valueKeyWord
  log_info "dns" "输入的记录值(value)关键字为 $valueKeyWord"
}

function quit() {
  read -p "是否退出(q) :" q
  if [ "$q" == "q" ] || [ -z $q ]; then
    log_warn "dns" "退出分页查询域名的解析记录"
    exit 0
  else
    quit
  fi
}

function acl() {
  log_info "dns" "获取支持的域名列表"
  dnsapi "" "" "" "" "/acl"
  echo $result | jq
}

function addRecord() {
  log_info "dns" "新增解析记录"
  readDomainName
  readRr
  readType
  readValue
  log_info "dns" "新增解析记录 domainName=$domainName rr=$rr type=$type value=$value"
  dnsapi $domainName $rr $type $value "/addRecord"
  echo $result | jq
}

function getRecords() {
  log_info "dns" "查询子域名的所有解析记录"
  readDomainName
  readRr
  log_info "dns" "查询子域名的所有解析记录 domainName=$domainName rr=$rr"
  dnsapi $domainName $rr "" "" "/getRecords"
  echo $result | jq
}

function deleteRecords() {
  log_warn "dns" "删除子域名的所有解析记录"
  readDomainName
  readRr
  log_warn "dns" "删除子域名的所有解析记录 domainName=$domainName rr=$rr"
  dnsapi $domainName $rr "" "" "/deleteRecords"
  echo $result | jq
}

function deleteThenAddRecord() {
  log_info "dns" "删除子域名的所有解析记录，然后新增解析记录"
  deleteRecords
  addRecord
}

function getDomainRecords() {
  log_info "dns" "分页查询域名的解析记录 domainName=$domainName pageNumber=$pageNumber pageSize=$pageSize"
  dnsapi $domainName "" "" "" "/getDomainRecords" $1 $2 $3 $4

  local code=$(echo $result | jq -r ".code")

  function clearAndList() {
    clear
    sleep 1
    local data=$(echo $result | jq -r ".data")
    local totalCount=$(echo $result | jq -r ".totalCount")
    log_info "dns" "分页查询域名的解析记录 domainName=$domainName pageNumber=$1 pageSize=$2 totalCount=$totalCount \n"
    echo $data | jq -c '.[]'
  }

  if [ $code -eq 200 ]; then
    clearAndList $1 $2
    local rtPageNumber=$(echo $result | jq -r ".pageNumber")
    local totalPage=$(echo $result | jq -r ".totalPage")

    if [ $totalPage -le 1 ]; then
      quit
    fi

    while true; do
      read -p "查询上一页(p) 查询下一页(n|Enter) 退出(q) :" pn
      if [ "$pn" == "q" ]; then
        log_warn "dns" "退出分页查询域名的解析记录"
        exit 0
      elif [ "$pn" == "n" ] || [ -z "$pn" ]; then
        if [ $rtPageNumber -ge $totalPage ]; then
          getDomainRecords 1 $pageSize $3 $4
          continue
        else
          getDomainRecords $((rtPageNumber + 1)) $pageSize $3 $4
        fi
      elif [ "$pn" == "p" ]; then
        if [ $rtPageNumber -eq 1 ]; then
          getDomainRecords $totalPage $pageSize $3 $4
          continue
        fi
        getDomainRecords $((rtPageNumber - 1)) $pageSize $3 $4
      fi
    done

  else
    log_error "dns" "分页查询域名的解析记录失败"
  fi

}

case $dns_operate in
0)
  acl
  ;;
1)
  addRecord
  ;;
2)
  getRecords
  ;;
3)
  deleteRecords
  ;;
4)
  deleteThenAddRecord
  ;;
5)
  log_info "dns" "分页查询域名的解析记录"
  readDomainName
  readPageNumber
  readPageSize
  readRrKeyWord
  readValueKeyWord
  getDomainRecords $pageNumber $pageSize $rrKeyWord $valueKeyWord
  ;;
*)
  log_info "dns" "没有选择任何操作，退出"
  ;;
esac
