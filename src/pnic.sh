#!/usr/bin/env bash

# Pnic u0rA by Brendon, 07/30/2023.
# ——String-based math library. https://ed7n.github.io/pnic

# Division setup:
#   Alg=pcs   Algorithm: `pcs` | `pdv`.
#   Pcs=20    Precision or significant figures.
pncDivAlg=pcs
pncDivPcs=20

readonly -a PNC_TBL_ADD00=(00 01 02 03 04 05 06 07 08 09)
readonly -a PNC_TBL_ADD01=(01 02 03 04 05 06 07 08 09 10)
readonly -a PNC_TBL_ADD02=(02 03 04 05 06 07 08 09 10 11)
readonly -a PNC_TBL_ADD03=(03 04 05 06 07 08 09 10 11 12)
readonly -a PNC_TBL_ADD04=(04 05 06 07 08 09 10 11 12 13)
readonly -a PNC_TBL_ADD05=(05 06 07 08 09 10 11 12 13 14)
readonly -a PNC_TBL_ADD06=(06 07 08 09 10 11 12 13 14 15)
readonly -a PNC_TBL_ADD07=(07 08 09 10 11 12 13 14 15 16)
readonly -a PNC_TBL_ADD08=(08 09 10 11 12 13 14 15 16 17)
readonly -a PNC_TBL_ADD09=(09 10 11 12 13 14 15 16 17 18)
readonly -a PNC_TBL_ADD10=(01 02 03 04 05 06 07 08 09 10)
readonly -a PNC_TBL_ADD11=(02 03 04 05 06 07 08 09 10 11)
readonly -a PNC_TBL_ADD12=(03 04 05 06 07 08 09 10 11 12)
readonly -a PNC_TBL_ADD13=(04 05 06 07 08 09 10 11 12 13)
readonly -a PNC_TBL_ADD14=(05 06 07 08 09 10 11 12 13 14)
readonly -a PNC_TBL_ADD15=(06 07 08 09 10 11 12 13 14 15)
readonly -a PNC_TBL_ADD16=(07 08 09 10 11 12 13 14 15 16)
readonly -a PNC_TBL_ADD17=(08 09 10 11 12 13 14 15 16 17)
readonly -a PNC_TBL_ADD18=(09 10 11 12 13 14 15 16 17 18)
readonly -a PNC_TBL_ADD19=(10 11 12 13 14 15 16 17 18 19)
readonly -a PNC_TBL_SUB00=(00 19 18 17 16 15 14 13 12 11)
readonly -a PNC_TBL_SUB01=(01 00 19 18 17 16 15 14 13 12)
readonly -a PNC_TBL_SUB02=(02 01 00 19 18 17 16 15 14 13)
readonly -a PNC_TBL_SUB03=(03 02 01 00 19 18 17 16 15 14)
readonly -a PNC_TBL_SUB04=(04 03 02 01 00 19 18 17 16 15)
readonly -a PNC_TBL_SUB05=(05 04 03 02 01 00 19 18 17 16)
readonly -a PNC_TBL_SUB06=(06 05 04 03 02 01 00 19 18 17)
readonly -a PNC_TBL_SUB07=(07 06 05 04 03 02 01 00 19 18)
readonly -a PNC_TBL_SUB08=(08 07 06 05 04 03 02 01 00 19)
readonly -a PNC_TBL_SUB09=(09 08 07 06 05 04 03 02 01 00)
readonly -a PNC_TBL_SUB10=(19 18 17 16 15 14 13 12 11 10)
readonly -a PNC_TBL_SUB11=(00 19 18 17 16 15 14 13 12 11)
readonly -a PNC_TBL_SUB12=(01 00 19 18 17 16 15 14 13 12)
readonly -a PNC_TBL_SUB13=(02 01 00 19 18 17 16 15 14 13)
readonly -a PNC_TBL_SUB14=(03 02 01 00 19 18 17 16 15 14)
readonly -a PNC_TBL_SUB15=(04 03 02 01 00 19 18 17 16 15)
readonly -a PNC_TBL_SUB16=(05 04 03 02 01 00 19 18 17 16)
readonly -a PNC_TBL_SUB17=(06 05 04 03 02 01 00 19 18 17)
readonly -a PNC_TBL_SUB18=(07 06 05 04 03 02 01 00 19 18)
readonly -a PNC_TBL_SUB19=(08 07 06 05 04 03 02 01 00 19)
readonly -a PNC_TBL_MUL00=(00 00 00 00 00 00 00 00 00 00)
readonly -a PNC_TBL_MUL01=(00 01 02 03 04 05 06 07 08 09)
readonly -a PNC_TBL_MUL02=(00 02 04 06 08 10 12 14 16 18)
readonly -a PNC_TBL_MUL03=(00 03 06 09 12 15 18 21 24 27)
readonly -a PNC_TBL_MUL04=(00 04 08 12 16 20 24 28 32 36)
readonly -a PNC_TBL_MUL05=(00 05 10 15 20 25 30 35 40 45)
readonly -a PNC_TBL_MUL06=(00 06 12 18 24 30 36 42 48 54)
readonly -a PNC_TBL_MUL07=(00 07 14 21 28 35 42 49 56 63)
readonly -a PNC_TBL_MUL08=(00 08 16 24 32 40 48 56 64 72)
readonly -a PNC_TBL_MUL09=(00 09 18 27 36 45 54 63 72 81)
readonly -a PNC_TBL_CMP00=(00 01 01 01 01 01 01 01 01 01)
readonly -a PNC_TBL_CMP01=(10 00 01 01 01 01 01 01 01 01)
readonly -a PNC_TBL_CMP02=(10 10 00 01 01 01 01 01 01 01)
readonly -a PNC_TBL_CMP03=(10 10 10 00 01 01 01 01 01 01)
readonly -a PNC_TBL_CMP04=(10 10 10 10 00 01 01 01 01 01)
readonly -a PNC_TBL_CMP05=(10 10 10 10 10 00 01 01 01 01)
readonly -a PNC_TBL_CMP06=(10 10 10 10 10 10 00 01 01 01)
readonly -a PNC_TBL_CMP07=(10 10 10 10 10 10 10 00 01 01)
readonly -a PNC_TBL_CMP08=(10 10 10 10 10 10 10 10 00 01)
readonly -a PNC_TBL_CMP09=(10 10 10 10 10 10 10 10 10 00)
PNC_PZR="$(printf %x -1)"
PNC_PZR="$(printf %d 0x${PNC_PZR//f/7})"
PNC_PZR="${PNC_PZR:1}"
readonly PNC_PDL=${#PNC_PZR} PNC_PZR="${PNC_PZR//?/0}"

PNC.addInt() {
  PNC._addsubInt "${1}" 'ADD' "${2}" "${3}"
}

PNC.addFlt() {
  PNC._addsubFlt "${1}" 'ADD' "${2}" "${3}" "${4}" "${5}"
}

PNC.addObj() {
  [ "${2}" == 'pncOb1' ] || local -n pncOb1="${2}"
  [ "${3}" == 'pncOb2' ] || local -n pncOb2="${3}"
  local pncKey
  (( ${#pncOb1[neg]} ^ ${#pncOb2[neg]} )) && {
    pncKey='SUB' || :
  } || pncKey='ADD'
  PNC._addsubObj "${1}" "${pncKey}" "${2}" "${3}"
}

PNC.subInt() {
  PNC._addsubInt "${1}" 'SUB' "${2}" "${3}"
}

PNC.subFlt() {
  PNC._addsubFlt "${1}" 'SUB' "${2}" "${3}" "${4}" "${5}"
}

PNC.subObj() {
  [ "${2}" == 'pncOb1' ] || local -n pncOb1="${2}"
  [ "${3}" == 'pncOb2' ] || local -n pncOb2="${3}"
  local pncKey
  (( ${#pncOb1[neg]} ^ ${#pncOb2[neg]} )) && {
    pncKey='ADD' || :
  } || pncKey='SUB'
  PNC._addsubObj "${1}" "${pncKey}" "${2}" "${3}"
}

PNC.mulInt() {
  [ "${1}" == 'pncOut' ] || local -n pncOut="${1}"
  local pncIn1="${2}" pncIn2="${3}"
  PNC.trmInt pncIn1 pncIn2
  PNC.clrObj "${1}"
  PNC._mul "${pncIn1}" "${pncIn2}"
  pncOut[int]="${pncOut[res]}"
  PNC.trmObj "${1}"
}

PNC.mulFlt() {
  (( ${#3} || ${#5} )) && {
    [ "${1}" == 'pncOut' ] || local -n pncOut="${1}"
    local pncFl1="${3}" pncFl2="${5}" pncIn1="${2}" pncIn2="${4}"
    PNC.trmFlt pncFl1 pncFl2
    PNC.alnFlt pncFl1 pncFl2
    PNC.trmInt pncIn1 pncIn2
    PNC.clrObj "${1}"
    PNC._mul "${pncIn1}""${pncFl1}" "${pncIn2}""${pncFl2}"
    [ ! "${pncOut[res]}" == '0' ] && {
      local pncLen=$(( ${#pncFl1} + ${#pncFl2} ))
      (( pncLen )) && {
        pncOut[flt]="${pncOut[res]: -${pncLen}}"
        pncOut[int]="${pncOut[res]:0:-${pncLen}}" || :
      }
    } || pncOut[int]="${pncOut[res]}"
    PNC.trmObj "${1}" || :
  } || PNC.mulInt "${1}" "${2}" "${4}"
}

PNC.mulObj() {
  PNC._muldivObj "${1}" 'mul' "${2}" "${3}"
}

PNC.divInt() {
  [ "${1}" == 'pncOut' ] || local -n pncOut="${1}"
  local pncIn1="${2}" pncIn2="${3}"
  PNC.trmInt pncIn1 pncIn2
  PNC.clrObj "${1}"
  PNC._div "${pncIn1}" "${pncIn2}"
  PNC.trmObj "${1}"
}

PNC.divFlt() {
  (( ${#3} || ${#5} )) && {
    [ "${1}" == 'pncOut' ] || local -n pncOut="${1}"
    local pncFl1="${3}" pncFl2="${5}" pncIn1="${2}" pncIn2="${4}"
    PNC.trmFlt pncFl1 pncFl2
    PNC.alnFlt pncFl1 pncFl2
    PNC.trmInt pncIn1 pncIn2
    PNC.clrObj "${1}"
    PNC._div "${pncIn1}""${pncFl1}" "${pncIn2}""${pncFl2}"
    PNC.trmObj "${1}" || :
  } || PNC.divInt "${1}" "${2}" "${4}"
}

PNC.divObj() {
  PNC._muldivObj "${1}" 'div' "${2}" "${3}"
}

PNC.cmpInt() {
  [ "${1}" == 'pncOut' ] || local -n pncOut="${1}"
  local pncIn1="${2}" pncIn2="${3}"
  PNC.trmInt pncIn1 pncIn2
  PNC.clrObj "${1}"
  PNC._cmp "${pncIn1}" "${pncIn2}"
}

PNC.cmpFlt() {
  (( ${#3} || ${#5} )) && {
    [ "${1}" == 'pncOut' ] || local -n pncOut="${1}"
    local pncFl1="${3}" pncFl2="${5}" pncIn1="${2}" pncIn2="${4}"
    PNC.trmFlt pncFl1 pncFl2
    PNC.alnFlt pncFl1 pncFl2
    PNC.trmInt pncIn1 pncIn2
    PNC.clrObj "${1}"
    PNC._cmp "${pncIn1}""${pncFl1}" "${pncIn2}""${pncFl2}" || :
  } || PNC.cmpInt "${1}" "${2}" "${4}"
}

PNC.cmpObj() {
  [ "${1}" == 'pncOut' ] || local -n pncOut="${1}"
  [ "${2}" == 'pncOb1' ] || local -n pncOb1="${2}"
  [ "${3}" == 'pncOb2' ] || local -n pncOb2="${3}"
  (( ${#pncOb1[neg]} )) && {
    (( ${#pncOb2[neg]} )) || {
      PNC.clrObj "${1}"
      pncOut[neg]='neg'
      return
    }
  } || {
    (( ${#pncOb2[neg]} )) && {
      PNC.clrObj "${1}"
      pncOut[pos]='pos'
      return
    }
  }
  (( ${#pncOb1[pos]} )) && {
    (( ${#pncOb2[pos]} )) || {
      PNC.clrObj "${1}"
      pncOut[pos]='pos'
      return
    }
  } || {
    (( ${#pncOb2[pos]} )) && {
      PNC.clrObj "${1}"
      pncOut[neg]='neg'
      return
    }
  }
  (( ${#pncOb1[neg]} && ${#pncOb2[neg]} )) && {
    PNC.cmpFlt "${1}" "${pncOb2[int]}" "${pncOb2[flt]}" "${pncOb1[int]}" \
        "${pncOb1[flt]}" || :
  } || PNC.cmpFlt "${1}" "${pncOb1[int]}" "${pncOb1[flt]}" "${pncOb2[int]}" \
      "${pncOb2[flt]}"
}

PNC.shlObj() {
  (( ${#2} == 0 )) || [ "${2}" == '0' ] || {
    [ "${2:0:1}" == '-' ] && {
      PNC.shrObj "${1}" "${2:1}" || :
    } || {
      [ "${1}" == 'pncObj' ] || local -n pncObj="${1}"
      local pncItr="${2}"
      while (( pncItr-- )); do
        (( ${#pncObj[flt]} )) && {
          pncObj[int]+="${pncObj[flt]:0:1}"
          pncObj[flt]="${pncObj[flt]:1}" || :
        } || pncObj[int]+='0'
      done
    }
  }
}

PNC.shrObj() {
  (( ${#2} == 0 )) || [ "${2}" == '0' ] || {
    [ "${2:0:1}" == '-' ] && {
      PNC.shlObj "${1}" "${2:1}" || :
    } || {
      [ "${1}" == 'pncObj' ] || local -n pncObj="${1}"
      local pncItr="${2}"
      while (( pncItr-- )); do
        (( ${#pncObj[int]} )) && {
          pncObj[flt]="${pncObj[int]: -1}""${pncObj[flt]}"
          pncObj[int]="${pncObj[int]:0:-1}" || :
        } || pncObj[flt]='0'"${pncObj[flt]}"
      done
      (( ${#pncObj[int]} )) || pncObj[int]=0
    }
  }
}

PNC.alnFlt() {
  local pncStr
  while (( ${#} >= 2 )); do
    [ "${1}" == 'pncFl1' ] || local -n pncFl1="${1}"
    [ "${2}" == 'pncFl2' ] || local -n pncFl2="${2}"
    pncStr="${pncFl1:${#pncFl2}}"
    (( ${#pncStr} )) && {
      pncFl2+="${pncStr//?/0}" || :
    } || {
      pncStr="${pncFl2:${#pncFl1}}"
      pncFl1+="${pncStr//?/0}"
    }
    [ "${1}" == 'pncFl1' ] || unset -n pncFl1
    [ "${2}" == 'pncFl2' ] || unset -n pncFl2
    shift 2
  done
}

PNC.clrObj() {
  while (( ${#} )); do
    [ "${1}" == 'pncObj' ] || local -n pncObj="${1}"
    pncObj[err]=
    pncObj[flt]=
    pncObj[int]=
    pncObj[neg]=
    pncObj[pos]=
    pncObj[res]=
    [ "${1}" == 'pncObj' ] || unset -n pncObj
    shift
  done
}

PNC.cpyObj() {
  [ "${!#}" == 'pncOb1' ] || local -n pncOb1="${!#}"
  while (( ${#} > 1 )); do
    [ "${1}" == 'pncOb2' ] || local -n pncOb2="${1}"
    pncOb2[err]="${pncOb1[err]}"
    pncOb2[flt]="${pncOb1[flt]}"
    pncOb2[int]="${pncOb1[int]}"
    pncOb2[neg]="${pncOb1[neg]}"
    pncOb2[pos]="${pncOb1[pos]}"
    pncOb2[res]="${pncOb1[res]}"
    [ "${1}" == 'pncOb2' ] || unset -n pncOb2
    shift
  done
}

PNC.trmFlt() {
  while (( ${#} )); do
    [ "${1}" == 'pncFlt' ] || local -n pncFlt="${1}"
    while [ "${pncFlt: -1}" == '0' ]; do
      pncFlt="${pncFlt:0:-1}"
    done
    [ "${1}" == 'pncFlt' ] || unset -n pncFlt
    shift
  done
}

PNC.trmInt() {
  while (( ${#} )); do
    [ "${1}" == 'pncInt' ] || local -n pncInt="${1}"
    while [ "${pncInt:0:1}" == '0' ]; do
      pncInt="${pncInt:1}"
    done
    #(( ${#pncInt} ))
    [ "${pncInt:0:1}" ] || pncInt=0
    [ "${1}" == 'pncInt' ] || unset -n pncInt
    shift
  done
}

PNC.trmObj() {
  while (( ${#} )); do
    [ "${1}" == 'pncObj' ] || local -n pncObj="${1}"
    PNC.trmFlt pncObj[flt]
    PNC.trmInt pncObj[int]
    [ "${1}" == 'pncObj' ] || unset -n pncObj
    shift
  done
}

PNC.tstObj() {
  while (( ${#} )); do
    [ "${1}" == 'pncObj' ] || local -n pncObj="${1}"
    (( ${#pncObj[err]} )) || (( ${#pncObj[flt]} )) || (( ${#pncObj[int]} )) \
        || (( ${#pncObj[neg]} )) || (( ${#pncObj[pos]} )) \
        || (( ${#pncObj[res]} )) || return 1
    [ "${1}" == 'pncObj' ] || unset -n pncObj
    shift
  done || :
}

PNC.eval() {
  local -A pncEol pncEor pncEou
  local pncEop pncEos
  while (( ${#} && ${#pncEou[err]} == 0 )); do
    case "${1}" in
      '*' | 'mul' )
        pncEop='mul' ;;
      '+' | 'add' )
        pncEop='add' ;;
      '-' | 'sub' )
        pncEop='sub' ;;
      '/' | 'div' )
        pncEop='div' ;;
      '<<' | 'shl' )
        pncEop='shl' ;;
      '<>' | 'cmp' )
        pncEop='cmp' ;;
      '>>' | 'shr' )
        pncEop='shr' ;;
      * )
        [[ "${1}" == *([[:digit:]]).+([[:digit:]]) ]] && {
          pncEor[flt]="${1##*.}"
          pncEor[int]="${1%%.*}" || :
        } || pncEor[int]="${1}"
        [[ "${pncEor[flt]}""${pncEor[int]}" == +(0) ]] || pncEor[pos]='pos'
        case "${pncEop}" in
          'add' | 'cmp' | 'div' | 'mul' | 'sub' )
            PNC."${pncEop}"Obj pncEol pncEou pncEor ;;
          'shl' | 'shr' )
            PNC."${pncEop}"Obj pncEol "${pncEor[int]}" ;;
          * )
            PNC.cpyObj pncEol pncEor ;;
        esac
        PNC.cpyObj pncEou pncEol
        PNC.clrObj pncEor ;;
    esac
    shift
  done
  (( ${#pncEou[err]} )) && {
    echo "${pncEou[err]}"
    return 1
  }
  (( ${#pncEou[neg]} )) && pncEos+='-'
  (( ${#pncEou[pos]} )) && pncEos+='+'
  pncEos+="${pncEou[int]}"
  (( ${#pncEou[flt]} )) && pncEos+='.'"${pncEou[flt]}"
  echo "${pncEos}"
}

PNC._addsub() {
  local pncCry=0 pncDgt pncIdx pncIn1="${2}" pncIn2="${3}" pncJdx pncNeg \
      pncPos pncRes pncVal
  [ "${1}" == 'SUB' ] && {
    PNC._cmp "${2}" "${3}"
    (( ${#pncOut[neg]} )) && {
      pncIn1="${3}"
      pncIn2="${2}"
      pncNeg='neg' || :
    } || (( ${#pncOut[pos]} )) || {
      pncOut[res]=0
      return
    }
  }
  while (( ${#pncIn1} || ${#pncIn2} )); do
    pncIdx="${pncIn1: -1}"
    (( ${#pncIdx} )) || pncIdx='0'
    pncJdx="${pncIn2: -1}"
    (( ${#pncJdx} )) || pncJdx='0'
    local -n pncTbl=PNC_TBL_"${1}""${pncCry}""${pncIdx}"
    pncVal="${pncTbl[${pncJdx}]}"
    pncCry="${pncVal:0:1}"
    pncDgt="${pncVal:1:1}"
    pncRes="${pncDgt}""${pncRes}"
    # Non-zero results are positive by default.
    (( ${#pncNeg} || ${#pncPos} )) || [ "${pncVal}" == '00' ] || pncPos='pos'
    (( ${#pncIn1} )) && pncIn1="${pncIn1:0:-1}"
    (( ${#pncIn2} )) && pncIn2="${pncIn2:0:-1}"
  done
  [ "${pncCry}" == '0' ] || pncRes="${pncCry}""${pncRes}"
  pncOut[neg]="${pncNeg}"
  pncOut[pos]="${pncPos}"
  pncOut[res]="${pncRes}"
}

PNC._addsubInt() {
  [ "${1}" == 'pncOut' ] || local -n pncOut="${1}"
  local pncIn1="${3}" pncIn2="${4}"
  PNC.trmInt pncIn1 pncIn2
  PNC.clrObj "${1}"
  PNC._addsub "${2}" "${pncIn1}" "${pncIn2}"
  pncOut[int]="${pncOut[res]}"
  PNC.trmObj "${1}"
}

PNC._addsubFlt() {
  (( ${#4} || ${#6} )) && {
    [ "${1}" == 'pncOut' ] || local -n pncOut="${1}"
    local pncFl1="${4}" pncFl2="${6}" pncIn1="${3}" pncIn2="${5}"
    PNC.trmFlt pncFl1 pncFl2
    PNC.alnFlt pncFl1 pncFl2
    PNC.trmInt pncIn1 pncIn2
    PNC.clrObj "${1}"
    PNC._addsub "${2}" "${pncIn1}""${pncFl1}" "${pncIn2}""${pncFl2}"
    [ ! "${pncOut[res]}" == '0' ] && {
      (( ${#pncFl1} )) && {
        pncOut[flt]="${pncOut[res]: -${#pncFl1}}"
        pncOut[int]="${pncOut[res]:0:-${#pncFl1}}" || :
      }
    } || pncOut[int]="${pncOut[res]}"
    PNC.trmObj "${1}" || :
  } || PNC._addsubInt "${1}" "${2}" "${3}" "${5}"
}

PNC._addsubObj() {
  [ "${1}" == 'pncOut' ] || local -n pncOut="${1}"
  [ "${3}" == 'pncOb1' ] || local -n pncOb1="${3}"
  [ "${4}" == 'pncOb2' ] || local -n pncOb2="${4}"
  PNC._addsubFlt "${1}" "${2}" "${pncOb1[int]}" "${pncOb1[flt]}" \
      "${pncOb2[int]}" "${pncOb2[flt]}"
  (( ${#pncOb1[neg]} )) && {
    (( ${#pncOut[neg]} )) && {
      pncOut[neg]=
      pncOut[pos]='pos' || :
    } || {
      (( ${#pncOut[pos]} )) && {
        pncOut[neg]='neg'
        pncOut[pos]=
      }
    }
  }
}

PNC._mul() {
  local pncCry pncIdx pncIn1="${1}" pncIn2 pncRes pncRs1=0 pncRs2 pncVal
  while (( ${#pncIn1} )); do
    local -n pncTb1=PNC_TBL_MUL0"${pncIn1: -1}"
    pncCry=0
    pncIn2="${2}"
    pncRs2=
    while (( ${#pncIn2} )); do
      pncVal="${pncTb1[${pncIn2: -1}]}"
      pncIdx="${pncCry}"
      pncCry="${pncVal:0:1}"
      local -n pncTb2=PNC_TBL_ADD0"${pncVal:1:1}"
      pncVal="${pncTb2[${pncIdx}]}"
      [ "${pncVal:0:1}" == '1' ] && pncCry="${PNC_TBL_ADD01[${pncCry}]:1:1}"
      pncRs2="${pncVal:1:1}""${pncRs2}"
      pncIn2="${pncIn2:0:-1}"
    done
    [ "${pncCry}" == '0' ] && pncCry=
    PNC._addsub 'ADD' "${pncRs1}" "${pncCry}""${pncRs2}"
    pncRes="${pncOut[res]: -1}""${pncRes}"
    pncRs1="${pncOut[res]:0:-1}"
    pncIn1="${pncIn1:0:-1}"
  done
  pncOut[res]="${pncRs1}""${pncRes}"
}

PNC._div() {
  PNC._div_"${pncDivAlg}" "${@}"
}

PNC._div_pcs() {
  local pncDgt=0 pncFlt pncIn1="${1}" pncIn2="${2}" pncInt pncItr=0 \
      pncNeg pncPos pncShf pncZro
  PNC.trmInt pncIn1 pncIn2
  [ "${pncIn2}" == '0' ] && {
    pncOut[err]='Division by zero.' || :
  } || {
    [ "${pncIn1}" == '0' ] || {
      PNC._addsub 'SUB' ${#pncIn1} ${#pncIn2}
      (( ${#pncOut[pos]} )) && {
        pncShf="${pncOut[res]}"
        PNC.alnFlt pncIn1 pncIn2
      }
      while true; do
        PNC._addsub 'SUB' "${pncIn1}" "${pncIn2}"
        pncNeg="${pncOut[neg]}"
        pncPos="${pncOut[pos]}"
        (( ${#pncNeg} )) || {
          pncIn1="${pncOut[res]}"
          PNC.trmInt pncIn1
          PNC._addsub 'ADD' "${pncDgt}" 1
          pncDgt="${pncOut[res]}"
        }
        (( ${#pncPos} )) || {
          (( ${#pncInt} )) && {
            pncFlt+="${pncDgt}" || :
          } || pncInt="${pncDgt}"
          [ "${pncItr}" == "${pncDivPcs}" ] && break
          pncDgt=0
          pncIn1+='0'
          PNC._addsub 'ADD' "${pncItr}" 1
          pncItr="${pncOut[res]}"
        }
        (( ${#pncNeg} || ${#pncPos} )) || break
      done
      pncOut[flt]="${pncFlt}"
      pncOut[int]="${pncInt}"
      pncOut[neg]=
      pncOut[pos]='pos'
      pncOut[res]="${pncInt}""${pncFlt}"
      PNC.shlObj pncOut "${pncShf}"
    }
  }
}

PNC._div_pdv() {
  local pncDvs pncIn1="${1}" pncIn2="${2}" pncLn1 pncPos pncRes pncRs1 \
      pncZro="${PNC_PZR}"
  PNC.trmInt pncIn1 pncIn2
  [ "${pncIn2}" == '0' ] && {
    pncOut[err]='Division by zero.' || :
  } || {
    pncDvs="${pncIn2:${PNC_PDL}}"
    while (( ${#pncDvs} )); do
      (( ${#pncIn1} )) && {
        pncIn1="${pncIn1:0:-1}" || :
      } || {
        pncIn1=0
        break
      }
      pncDvs="${pncDvs:1}"
    done
    pncDvs="${pncIn2:0:${PNC_PDL}}"
    pncLn1=${#pncIn1}
    while true; do
      PNC._addsub 'ADD' "${pncRs1:-0}" \
          $(( "${pncIn1: -1}""${PNC_PZR}" / pncDvs ))
      (( ${#pncPos} )) || pncPos="${pncOut[pos]}"
      pncRs1="${pncOut[res]}"
      pncIn1="${pncIn1:0:-1}"
      (( ${#pncIn1} )) || break
      (( ${#pncZro} )) && {
        pncZro="${pncZro:0:-1}" || :
      } || pncRes="${pncRs1: -1}""${pncRes}"
      pncRs1="${pncRs1:0:-1}"
    done
    [[ "${pncRs1}" == *(0)+([[:digit:]])+(9) ]] && {
      PNC._addsub 'ADD' "${pncRs1}" 1
      pncRs1="${pncOut[res]}"
    }
    PNC._addsub 'SUB' "${pncLn1}" ${#pncDvs}
    (( ${#pncOut[neg]} )) && {
      pncOut[int]=0
      pncOut[neg]=
      pncZro="$(eval printf '0%.s' "{1..${pncOut[res]}}")"
      [[ "${2}" == "${1}"+(0) ]] && pncZro="${pncZro:1}"
      pncOut[flt]="${pncZro}""${pncRs1}" || :
    } || {
      (( ${#pncZro} )) && {
        [ "${pncRs1}" == '0' ] || {
          pncOut[flt]="${pncRs1: -${#pncZro}}"
          pncOut[int]="${pncRs1:0:-${#pncZro}}" || :
        }
      } || pncOut[int]="${pncRs1}""${pncRes}"
    }
    pncOut[pos]="${pncPos}"
    pncOut[res]="${pncOut[int]}""${pncOut[flt]}" || :
  }
}

PNC._muldivObj() {
  [ "${1}" == 'pncOut' ] || local -n pncOut="${1}"
  [ "${3}" == 'pncOb1' ] || local -n pncOb1="${3}"
  [ "${4}" == 'pncOb2' ] || local -n pncOb2="${4}"
  PNC."${2}"Flt "${1}" "${pncOb1[int]}" "${pncOb1[flt]}" "${pncOb2[int]}" \
      "${pncOb2[flt]}"
  (( ${#pncOut[pos]} )) && {
    (( ${#pncOb1[neg]} ^ ${#pncOb2[neg]} )) && {
      pncOut[neg]='neg'
      pncOut[pos]=
    }
  }
}

PNC._cmp() {
  local pncIn1="${1}" pncIn2="${2}" pncStr pncVal
  pncStr="${pncIn1:${#pncIn2}}"
  (( ${#pncStr} )) && {
    pncOut[neg]=
    pncOut[pos]='pos'
    return
  }
  pncStr="${pncIn2:${#pncIn1}}"
  (( ${#pncStr} )) && {
    pncOut[neg]='neg'
    pncOut[pos]=
    return
  }
  while (( ${#pncIn1} )); do
    local -n pncTbl=PNC_TBL_CMP0"${pncIn1:0:1}"
    pncVal="${pncTbl[${pncIn2:0:1}]}"
    [ "${pncVal}" == '10' ] && {
      pncOut[neg]=
      pncOut[pos]='pos'
      break
    }
    [ "${pncVal}" == '01' ] && {
      pncOut[neg]='neg'
      pncOut[pos]=
      break
    }
    pncIn1="${pncIn1:1}"
    pncIn2="${pncIn2:1}"
  done
}

shopt -q 'extglob' || shopt -qs 'extglob' || {
  echo '`extglob` shell option can not be set.'
  exit 1
}
