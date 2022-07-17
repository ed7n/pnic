#!/bin/env bash

# KESIMATE u0r2 by Brendon, 07/17/2022.
# ——Pocket calculator simulator. https://ed7n.github.io/pnic/kesimate
#
# It covers my collection of contemporary pocket calculators as much as humanly
# possible. Behavioral variations are noted by commented expressions. By
# default, it follows closely to those of a BD-6750.

{
  declare -p ews || declare -Ax ews=([base]="${0%/*}" [exec]="${0}" \
      [name]='KESIMATE' [cols]=17 [rows]=1)
} &> /dev/null
. "${ews[base]}"/pnic.sh

# Pnic division setup:
#   Alg=pcs   Algorithm: `pcs` | `pdv`.
#   Pcs=20    Precision or significant figures.
pncDivAlg=pcs
pncDivPcs=12
# Key assignments:
#   add   Add.
#   clr   Clear Entry/All.
#   dec   Decimal.
#   div   Divide.
#   evl   Evaluate.
#   m+=   Memory Plus/Equal.
#   m-=   Memory Minus/Equal.
#   mrc   Memory Recall/Clear.
#   mul   Multiply.
#   nk*   Number keys.
#   pct   Percentage.
#   rt2   Square Root.
#   sgn   Sign Change.
#   sub   Subtract.
declare -Ar KSM_KEYS=(
  [add]='+'
  [clr]=''
  [dec]='.'
  [div]='/'
  [evl]=$'\n'
  [m+=]='[5~'
  [m-=]='[6~'
  [mrc]='[H'
  [mul]='*'
  [nk0]='0'
  [nk1]='1'
  [nk2]='2'
  [nk3]='3'
  [nk4]='4'
  [nk5]='5'
  [nk6]='6'
  [nk7]='7'
  [nk8]='8'
  [nk9]='9'
  [pct]='%'
  [rt2]='r'
  [sgn]='[2~'
  [sub]='-'
)
# Root-2 setup:
#   mxi   Maximum iteration count.
#   pcs   Precision in digits.
#   rdu   Round up i.(9)+ to (i + 1).0?
declare -A KSM_RT2S=(
  [mxi]=50
  [pcs]=13
  [rdu]='rdu'
)
KSM_RT2S[cnt]="$(eval printf '0%.s' {1..${KSM_RT2S[mxi]}})"
readonly KSM_RT2S
# Spacers:
#   dis   Display.
#   seg   Segments.
declare -A KSM_SPCS=(
  [dis]='                '
  [seg]='            ')
KSM_SPCS[len]="${#KSM_SPCS[seg]}"
readonly KSM_SPCS
# Symbols.
declare -Ar KSM_SYMS=(
  [err]='ᴇ'
  [kon]='ᴋ'
  [mem]='ᴍ'
  [neg]='−')
# Unit delay in seconds.
ews[dly]=0.05
# Konstant mode?
ews[kon]='kon'

clr() {
  local IFS=''
  [ "${ews[err]}" ] && {
    ews[err]=''
    dis ksmRes || :
  } || {
    [ "${ksmInp[*]}" ] && {
      PNC.clrObj ksmInp
      ews[dec]=''
      ews[inp]='inp'
      [ "${ksmDis[key]}" == 'ksmInp' ] && {
        # EL-240SA.
        #dis ksmRes
        dis ksmInp
        return
      }
    }
    PNC.clrObj ksmRes
    ews[ist]=''
    ews[opr]=''
    dly
    dis ksmInp
  }
}

dly() {
  echo -en '\r'"${KSM_SPCS[dis]}"' ''\r'
  read -st "${ews[dly]}" ews[nus]
}

dis() {
  [ "${1}" == 'ksmObj' ] || local -n ksmObj="${1}"
  local ksmLen="${ksmObj[flt]}""${ksmObj[int]}" ksmStr=''
  [ "${ksmLen}" ] && {
    ksmLen="${#ksmLen}" || :
  } || ksmLen=1
  [ "${ksmMem[neg]}""${ksmMem[pos]}" ] && {
    ksmStr="${ksmStr}""${KSM_SYMS[mem]}" || :
  } || ksmStr="${ksmStr}"' '
  [ "${ews[err]}" ] && {
    ksmStr="${ksmStr}""${KSM_SYMS[err]}" || :
  } || ksmStr="${ksmStr}"' '
  [ "${ksmObj[neg]}" ] && {
    ksmStr="${ksmStr}""${KSM_SYMS[neg]}" || :
  } || ksmStr="${ksmStr}"' '
  ksmStr="${ksmStr}""${KSM_SPCS[seg]:0:-${ksmLen}}"
  ksmDis[key]="${1}"
  ksmDis[str]="${ksmStr}""${ksmObj[int]:-0}"'.'"${ksmObj[flt]}"
}

evl() {
  local ksmOpr
  case "${2}" in
    '*' )
      ksmOpr='mul' ;;&
    '+' )
      ksmOpr='add' ;;&
    '-' )
      ksmOpr='sub' ;;&
    '/' )
      ksmOpr='div' ;;&
    '*' | '+' | '-' | '/' )
      PNC."${ksmOpr}"Obj "${1}" "${3}" "${4}" ;;
  esac
}

inp() {
  local IFS='' ksmStr
  [ "${ews[inp]}" ] && [ "${ksmDis[key]}" == 'ksmInp' ] || {
    PNC.clrObj ksmInp
    ews[dec]=''
    ews[inp]='inp'
    [ "${ews[ist]}""${ews[kon]}" == '=' ] && ews[opr]=''
  }
  ksmStr="${ksmInp[flt]}""${ksmInp[int]}"
  [ "${#ksmStr}" == "${KSM_SPCS[len]}" ] && {
    # Daiso no.89.
    #ews[err]='err' || :
    :
  } || {
    case "${1}" in
      '.' )
        [ "${ews[dec]}" ] || {
          [ "${ksmInp[int]}" ] || ksmInp[int]=0
          ews[dec]='dec'
        } ;;
      '0' )
        [ "${ews[dec]}" ] || [ "${ksmInp[*]}" ] || {
          dis ksmInp
          return
        } ;&
      '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9' )
        [ "${ews[dec]}" ] && {
          ksmInp[flt]="${ksmInp[flt]}""${1}" || :
        } || ksmInp[int]="${ksmInp[int]}""${1}" ;;
    esac
  }
  dis ksmInp
}

ist() {
  local -A ksmAcc ksmOb1 ksmOb2
  local ksmNdl
  [ "${ews[opr]}" ] && {
    case "${ews[ist]}" in
      '*' | '+' | '-' | '/' )
        PNC.cpyObj ksmOb1 ksmRes
        PNC.cpyObj ksmOb2 "${ksmDis[key]}"
        case "${ksmDis[key]}" in
          'ksmInp' | 'ksmMem' )
            case "${1}" in
              '%' )
                case "${ews[opr]}" in
                  '*' | '+' | '-' | '/' )
                    PNC.shrObj ksmOb2 2 ;;&
                  '+' | '-' )
                    PNC.mulObj ksmAcc ksmOb1 ksmOb2
                    PNC.cpyObj ksmOb2 ksmAcc
                    PNC.cpyObj ksmInp ksmRes ;;
                esac ;;&
              '%' | '=' | '[' | ']' )
                case "${ews[opr]}" in
                  '*' )
                    PNC.cpyObj ksmKon ksmRes ;;
                  '+' | '-' | '/' )
                    PNC.cpyObj ksmKon ksmInp ;;
                esac ;;&
              '%' | '*' | '+' | '-' | '/' | '=' | '[' | ']' )
                res "${ews[opr]}" ksmOb1 ksmOb2 ;;&
              '[' | ']' )
                mem "${1}" ksmMem ksmRes ;;
            esac ;;
          'ksmRes' )
            case "${1}" in
              '%' )
                case "${ews[opr]}" in
                  '*' | '/' )
                    PNC.shrObj ksmOb2 2 ;;
                  '+' | '-' )
                    # LS-270H.
                    #PNC.clrObj ksmRes ;;
                    return ;;
                esac ;;&
              '%' | '=' | '[' | ']' )
                case "${ews[opr]}" in
                  '*' | '+' | '-' | '/' )
                    PNC.cpyObj ksmKon ksmRes ;;&
                  '/' )
                    # HS-8LU.
                    #;;&
                    PNC.cpyObj ksmOb1 KSM_ONE ;;&
                  '*' | '/' )
                    res "${ews[opr]}" ksmOb1 ksmOb2 ;;
                esac ;;&
              '[' | ']' )
                mem "${1}" ksmMem ksmRes ;;
            esac ;;
        esac ;;
      '=' )
        case "${ksmDis[key]}" in
          'ksmInp' | 'ksmMem' )
            case "${1}" in
              '%' | '=' )
                case "${ews[opr]}" in
                  '+' | '-' | '/' )
                    PNC.cpyObj ksmOb1 ksmInp
                    PNC.cpyObj ksmOb2 ksmKon ;;
                  '*' )
                    PNC.cpyObj ksmOb1 ksmKon
                    PNC.cpyObj ksmOb2 ksmInp ;;
                esac ;;&
              '%' )
                case "${ews[opr]}" in
                  '*' | '+' | '-' | '/' )
                    PNC.shrObj ksmOb2 2 ;;&
                  '+' | '-' )
                    PNC.mulObj ksmAcc ksmOb1 ksmOb2
                    PNC.cpyObj ksmOb2 ksmAcc
                    PNC.cpyObj ksmOb1 ksmKon ;;
                esac ;;&
              '%' | '=' )
                res "${ews[opr]}" ksmOb1 ksmOb2 ;;
              '*' | '+' | '-' | '/' | '[' | ']' )
                PNC.cpyObj ksmRes ksmInp ;;&
              '[' | ']' )
                mem "${1}" ksmMem ksmInp ;;
            esac ;;
          'ksmRes' )
            case "${1}" in
              '%' | '=' )
                PNC.cpyObj ksmOb1 ksmRes
                PNC.cpyObj ksmOb2 ksmKon ;;&
              '%' )
                case "${ews[opr]}" in
                  '*' | '/' )
                    PNC.shrObj ksmOb2 2
                    res "${ews[opr]}" ksmOb1 ksmOb2 ;;
                  '+' | '-' )
                    ksmNdl='ndl' ;;
                esac ;;
              '=' )
                res "${ews[opr]}" ksmOb1 ksmOb2 ;;
              '[' | ']' )
                mem "${1}" ksmMem ksmRes ;;
            esac ;;
        esac ;;
    esac || :
  } || {
    case "${1}" in
      '%' )
        # LS-154TG.
        #return ;;
        # LS-270H.
        #PNC.cpyObj ksmRes "${ksmDis[key]}"
        #ksmNdl='ndl' ;;
        [ "${ews[kon]}" ] || PNC.clrObj ksmRes ;;
      '*' | '+' | '-' | '/' | '=' | '[' | ']' )
        PNC.cpyObj ksmRes "${ksmDis[key]}" ;;&
      '[' | ']' )
        mem "${1}" ksmMem ksmRes ;;
    esac
  }
  case "${1}" in
    '%' | '[' | ']' )
      ews[ist]='=' ;;
    '*' | '+' | '-' | '/' | '=' )
      ews[ist]="${1}" ;;&
    '*' | '+' | '-' | '/' )
      ews[opr]="${1}" ;;
  esac
  [ "${ksmNdl}" ] || dly
  dis ksmRes
}

k2i() {
  [ "${1}" == 'ksmKey' ] || local -n ksmKey="${1}"
  case "${ksmKey}" in
    "${KSM_KEYS[add]}" )
      ksmKey='+' ;;
    "${KSM_KEYS[clr]}" )
      ksmKey='' ;;
    "${KSM_KEYS[dec]}" )
      ksmKey='.' ;;
    "${KSM_KEYS[div]}" )
      ksmKey='/' ;;
    "${KSM_KEYS[evl]}" )
      ksmKey='=' ;;
    "${KSM_KEYS[m+=]}" )
      ksmKey=']' ;;
    "${KSM_KEYS[m-=]}" )
      ksmKey='[' ;;
    "${KSM_KEYS[mrc]}" )
      ksmKey='p' ;;
    "${KSM_KEYS[mul]}" )
      ksmKey='*' ;;
    "${KSM_KEYS[nk0]}" )
      ksmKey='0' ;;
    "${KSM_KEYS[nk1]}" )
      ksmKey='1' ;;
    "${KSM_KEYS[nk2]}" )
      ksmKey='2' ;;
    "${KSM_KEYS[nk3]}" )
      ksmKey='3' ;;
    "${KSM_KEYS[nk4]}" )
      ksmKey='4' ;;
    "${KSM_KEYS[nk5]}" )
      ksmKey='5' ;;
    "${KSM_KEYS[nk6]}" )
      ksmKey='6' ;;
    "${KSM_KEYS[nk7]}" )
      ksmKey='7' ;;
    "${KSM_KEYS[nk8]}" )
      ksmKey='8' ;;
    "${KSM_KEYS[nk9]}" )
      ksmKey='9' ;;
    "${KSM_KEYS[pct]}" )
      ksmKey='%' ;;
    "${KSM_KEYS[rt2]}" )
      ksmKey='r' ;;
    "${KSM_KEYS[sgn]}" )
      ksmKey='`' ;;
    "${KSM_KEYS[sub]}" )
      ksmKey='-' ;;
    'v' )
      [ "${ews[dbug]}" ] && {
        echo
        declare -p ews ksmDis ksmInp ksmKon ksmMem ksmRes
        echo
      } ;;
    * )
      ksmKey='' ;;
  esac
}

mem() {
  local -A ksmOut
  local ksmOpr
  case "${1}" in
    ']' )
      ksmOpr='+' ;;
    '[' )
      ksmOpr='-' ;;
  esac
  evl ksmOut "${ksmOpr}" "${2}" "${3}"
  trm ksmOut "${KSM_SPCS[len]}"
  [ "${ksmOut[err]}" ] && {
    # No overflow.
    #PNC.clrObj ksmRes
    PNC.cpyObj ksmRes ksmOut
    ews[err]='err'
    dis ksmRes || :
  } || {
    PNC.cpyObj ksmMem ksmOut
    ews[inp]=''
    dis "${3}"
  }
}

mrc() {
  [ "${ksmDis[key]}" == 'ksmMem' ] && {
    PNC.clrObj ksmMem
    ews[inp]=''
    dis ksmInp || :
  } || {
    PNC.cpyObj ksmInp ksmMem
    [ "${ews[ist]}""${ews[kon]}" == '=' ] && ews[opr]=''
    dis ksmMem
  }
}

res() {
  local -A ksmOut
  evl ksmOut "${1}" "${2}" "${3}"
  trm ksmOut "${KSM_SPCS[len]}"
  ews[err]="${ksmOut[err]}"
  PNC.cpyObj ksmRes ksmOut
}

rt2() {
  local -A ksmAc1 ksmAc2 ksmLen ksmOut
  local ksmCnt="${KSM_RT2S[cnt]}"
  dly
  PNC.cpyObj ksmInp "${ksmDis[key]}"
  [ "${ksmInp[neg]}" ] && {
    ksmInp[neg]=''
    ews[err]='err'
  }
  PNC.cpyObj ksmAc1 ksmInp
  PNC.mulFlt ksmLen "${#ksmAc1[int]}" 0 0 5
  PNC.shrObj ksmAc1 "${ksmLen[int]}"
  while [ "${ksmCnt}" ]; do
    ksmCnt="${ksmCnt:1}"
    PNC.divObj ksmOut ksmInp ksmAc1
    PNC.addObj ksmAc2 ksmOut ksmAc1
    PNC.mulObj ksmOut ksmAc2 KSM_HLF
    trm ksmOut "${KSM_RT2S[pcs]}"
    [ "${ksmOut[int]}""${ksmOut[flt]}" == "${ksmAc1[int]}""${ksmAc1[flt]}" ] \
        && break
    PNC.cpyObj ksmAc1 ksmOut
  done
  PNC.cpyObj ksmInp ksmOut
  [ "${KSM_RT2S[rdu]}" ] && [[ "${ksmOut[flt]}" == +(9) ]] && {
    PNC.addObj ksmInp ksmOut KSM_ONE
    ksmInp[flt]=''
  }
  trm ksmInp "${KSM_SPCS[len]}"
  ksmInp[err]=''
  ews[inp]=''
  dis ksmInp
}

sgn() {
  PNC.cpyObj ksmInp "${ksmDis[key]}"
  # HS-8LU.
  #[ "${ews[dec]}""${ksmInp[int]}" ] && {
  # LS-154TG.
  #[[ "${ksmInp[flt]}""${ksmInp[int]}" == *(0) ]] || {
  {
    [ "${ksmInp[neg]}" ] && {
      ksmInp[neg]=''
    } || ksmInp[neg]='neg'
    dis ksmInp
  }
}

trm() {
  [ "${1}" == 'ksmObj' ] || local -n ksmObj="${1}"
  local -A ksmDif ksmLen
  PNC.subInt ksmDif "${2}" "${#ksmObj[int]}"
  [ "${ksmDif[neg]}" ] && {
    PNC.subInt ksmLen "${2}" "${ksmDif[int]}"
    ksmObj[err]='Overflow.'
    ksmObj[flt]="${ksmObj[int]:${ksmDif[int]}:${ksmLen[int]}}"
    ksmObj[int]="${ksmObj[int]:0:${ksmDif[int]}}" || :
  } || ksmObj[flt]="${ksmObj[flt]:0:${ksmDif[int]}}"
  PNC.trmFlt ksmObj[flt]
}

shopt -q 'extglob' || shopt -qs 'extglob' || {
  echo '`extglob` shell option can not be set.'
  exit 1
}
[ "${1}" == 'dbug' ] && {
  shift
  ews[dbug]='dbug'
}
declare -Ar KSM_ONE=([int]=1) KSM_HLF=([flt]=5) KSM_ZRO=([int]=0)
declare -A ksmDis ksmInp ksmKon ksmMem ksmRes
ews[dec]=''
ews[err]=''
ews[fsh]=''
ews[inp]='inp'
ews[ist]=''
ews[opr]=''

dis ksmInp
while true; do
  [ "${ews[fsh]}" ] || while read -st 0.01; do
    :
  done
  echo -en '\r'"${KSM_SPCS[dis]}"' ''\r'
  read -d $'\u0' -sn 1 -p "${ksmDis[str]}"
  echo -en '\r'"${KSM_SPCS[dis]}"' ''\r'
  [ "${REPLY}" == '' ] && {
    read -st 0.01
    ews[fsh]='fsh' || :
  } || ews[fsh]=''
  k2i REPLY
  case "${REPLY}" in
    '.' | '0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9' )
      [ "${ews[err]}" ] || inp "${REPLY}" ;;
    '%' | '*' | '+' | '-' | '/' | '=' | '[' | ']' )
      [ "${ews[err]}" ] || ist "${REPLY}" ;;
    '' )
      clr ;;
    '`' )
      [ "${ews[err]}" ] || sgn ;;
    'p' )
      [ "${ews[err]}" ] || mrc ;;
    'r' )
      [ "${ews[err]}" ] || rt2 ;;
  esac
done
