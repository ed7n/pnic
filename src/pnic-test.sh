#!/usr/bin/env bash

{
  declare -p ews || declare -A ews=([base]="${0%/*}" [exec]="${0}" \
      [name]='Pnic-test' [sign]='u0r1 by Brendon, 12/31/2022.' \
      [desc]='Pnic Tester. https://ed7n.github.io/pnic')
} &> /dev/null
. "${ews[base]}"/pnic.sh

echo -e "${ews[name]}"' '"${ews[sign]}"'\n——'"${ews[desc]}"'\n'
for pntFun in 'addInt' 'addFlt' 'subInt' 'subFlt' 'mulInt' 'mulFlt' 'divInt' \
    'divFlt' 'cmpInt' 'cmpFlt'; do
  declare -A pntRes
  echo "${pntFun}"': '
  PNC."${pntFun}" pntRes "${@}"
  (( ${#pntRes[pos]} )) && {
    echo -n '+' || :
  } || echo -n ' '
  (( ${#pntRes[neg]} )) && {
    echo -n '-' || :
  } || echo -n ' '
  echo -n "${pntRes[int]}"
  (( ${#pntRes[flt]} )) && echo -n '.'"${pntRes[flt]}"
  (( ${#pntRes[err]} )) && echo -en '\t'"${pntRes[err]}"
  echo
  (( ${#pntDbug} )) && declare -p pntRes
done
