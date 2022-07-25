#!/bin/env bash

{
  declare -p ews || declare -Ax ews=([base]="${0%/*}" [exec]="${0}" \
      [name]='Pnic-test' [sign]='u0r0 by Brendon, 05/26/2022.' \
      [desc]='Pnic Tester. https://ed7n.github.io/pnic')
} &> /dev/null
. "${ews[base]}"/pnic.sh

addInt() {
  local -A pncOut
  PNC.addInt pncOut "${1}" "${2}"
  eco
}

addFlt() {
  local -A pncOut
  PNC.addFlt pncOut "${1}" "${2}" "${3}" "${4}"
  eco
}

subInt() {
  local -A pncOut
  PNC.subInt pncOut "${1}" "${2}"
  eco
}

subFlt() {
  local -A pncOut
  PNC.subFlt pncOut "${1}" "${2}" "${3}" "${4}"
  eco
}

mulInt() {
  local -A pncOut
  PNC.mulInt pncOut "${1}" "${2}"
  eco
}

mulFlt() {
  local -A pncOut
  PNC.mulFlt pncOut "${1}" "${2}" "${3}" "${4}"
  eco
}

divInt() {
  local -A pncOut
  PNC.divInt pncOut "${1}" "${2}"
  eco
}

divFlt() {
  local -A pncOut
  PNC.divFlt pncOut "${1}" "${2}" "${3}" "${4}"
  eco
}

cmpInt() {
  local -A pncOut
  PNC.cmpInt pncOut "${1}" "${2}"
  eco
}

cmpFlt() {
  local -A pncOut
  PNC.cmpFlt pncOut "${1}" "${2}" "${3}" "${4}"
  eco
}

eco() {
  [ "${pncOut[pos]}" ] && {
    echo -n '+' || :
  } || echo -n ' '
  [ "${pncOut[neg]}" ] && {
    echo -n '-' || :
  } || echo -n ' '
  echo -n "${pncOut[int]}"
  [ "${pncOut[flt]}" ] && echo -n '.'"${pncOut[flt]}"
  [ "${pncOut[err]}" ] && echo -en '\t'"${pncOut[err]}"
  echo
  [ "${ews[dbug]}" ] && declare -p pncOut
}

shopt -q 'extglob' || shopt -qs 'extglob' || {
  echo '`extglob` shell option can not be set.'
  exit 1
}

[ "${1}" == 'dbug' ] && {
  shift
  ews[dbug]='dbug'
}

echo -e "${ews[name]}"' '"${ews[sign]}"'\n——'"${ews[desc]}"'\n'
echo -n 'addInt: '
addInt "${1:-0}" "${2:-0}"
echo -n 'addFlt: '
addFlt "${1:-0}" "${2:-0}" "${3:-0}" "${4:-0}"
echo -n 'subInt: '
subInt "${1:-0}" "${2:-0}"
echo -n 'sufFlt: '
subFlt "${1:-0}" "${2:-0}" "${3:-0}" "${4:-0}"
echo -n 'mulInt: '
mulInt "${1:-0}" "${2:-0}"
echo -n 'mulFlt: '
mulFlt "${1:-0}" "${2:-0}" "${3:-0}" "${4:-0}"
echo -n 'divInt: '
divInt "${1:-0}" "${2:-0}"
echo -n 'divFlt: '
divFlt "${1:-0}" "${2:-0}" "${3:-0}" "${4:-0}"
echo -n 'cmpInt: '
cmpInt "${1:-0}" "${2:-0}"
echo -n 'cmpFlt: '
cmpFlt "${1:-0}" "${2:-0}" "${3:-0}" "${4:-0}"
