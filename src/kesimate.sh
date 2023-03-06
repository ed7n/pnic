#!/usr/bin/env bash

# KESIMATE u0r7 by Brendon, 03/06/2023.
# ——Pocket calculator simulator. https://ed7n.github.io/pnic/kesimate
#
# It covers my collection of contemporary pocket calculators as much as humanly
# possible. Behavioral variations are noted by commented expressions. By
# default, it follows closely to those of a BD-6750.

{
  declare -p ews || declare -A ews=([base]="${0%/*}" [exec]="${0}" \
      [name]='KESIMATE' [cols]=17 [rows]=1)
} &> /dev/null
. "${ews[base]}"/pnic.sh

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
readonly -A KSM_KEYS=(
  [add]='+'     [clr]=$'\u7f' [dec]='.'     [div]='/'     [evl]=$'\n'
  [m+=]='[5~'   [m-=]='[6~'   [mrc]='[H'    [mul]='*'     [nk0]='0'
  [nk1]='1'     [nk2]='2'     [nk3]='3'     [nk4]='4'     [nk5]='5'
  [nk6]='6'     [nk7]='7'     [nk8]='8'     [nk9]='9'     [pct]='%'
  [rt2]='r'     [sgn]='[2~'   [sub]='-'
)
# Root-2 setup:
#   max   Maximum iteration count.
#   pcs   Precision in digits.
#   rnd   Round up i.(9)+ to (i + 1).0?
readonly -A KSM_RT2S=([max]=50 [pcs]=13 [rnd]='rnd')
# Spacers:
#   dis   Display.
#   seg   Segments.
declare -A KSM_SPCS=([dis]='                ' [seg]='            ')
# Display symbols.
readonly -A KSM_SYMS=([err]=$'\u1d07' [kon]=$'\u1d0b' [mem]=$'\u1d0d' [neg]='−')
# Unit delay in seconds.
readonly KSM_DLY=0.05
# Enable constant mode?
readonly KSM_KEN='ken'
# Pnic division setup:
#   Alg=pcs   Algorithm: `pcs` | `pdv`.
#   Pcs=20    Precision or significant figures.
pncDivAlg=pcs
pncDivPcs=12

readonly KSM_RT2S
# For display operations.
KSM_SPCS[len]=${#KSM_SPCS[seg]}
readonly KSM_SPCS
# One, half, and zero.
readonly -A KSM_ONE=([int]=1) KSM_HLF=([flt]=5) KSM_ZRO=([int]=0)
# Constant, display, input, memory, result.
declare -A ksmCon ksmDis ksmInp ksmMem ksmRes
# Decimal flag.
ksmDec=
# Error flag.
ksmErr=
# Flush flag.
ksmFlu=
# Input enable flag.
ksmIen='ien'
# Last instruction.
ksmIns=
# Nul variable.
ksmNul=
# Last operator.
ksmOpr=

KSM.clr() {
  # Clear the error first.
  (( ${#ksmErr} )) && {
    ksmErr=
    KSM.dis ksmRes || :
  } || {
    # Clear only the input (CE) when it is filled and on display.
    PNC.tstObj ksmInp && {
      PNC.clrObj ksmInp
      ksmDec=
      ksmIen='ien'
      [ "${ksmDis[key]}" == 'ksmInp' ] && {
        # EL-240SA.
        #KSM.dis ksmRes
        KSM.dis ksmInp
        return
      }
    }
    # Clear everything else (AC).
    PNC.clrObj ksmRes
    ksmIns=
    ksmOpr=
    KSM.dly
    KSM.dis ksmInp
  }
}

KSM.dly() {
  read -p $'\r'"${KSM_SPCS[dis]}"$' \r' -st "${KSM_DLY}" ksmNul
}

KSM.dis() {
  [ "${1}" == 'ksmObj' ] || local -n ksmObj="${1}"
  local ksmLen
  # Prevents empty displays.
  (( ksmLen = ${#ksmObj[flt]} + ${#ksmObj[int]} ))
  (( ksmLen > 0 || (ksmLen = 1) ))
  ksmDis[key]="${1}"
  (( ${#ksmMem[neg]} || ${#ksmMem[pos]} )) && {
    ksmDis[str]="${KSM_SYMS[mem]}" || :
  } || ksmDis[str]=' '
  (( ${#ksmErr} )) && {
    ksmDis[str]+="${KSM_SYMS[err]}" || :
  } || ksmDis[str]+=' '
  (( ${#ksmObj[neg]} )) && {
    ksmDis[str]+="${KSM_SYMS[neg]}" || :
  } || ksmDis[str]+=' '
  ksmDis[str]+="${KSM_SPCS[seg]:0:-${ksmLen}}"
  (( ${#ksmObj[int]} )) && {
    ksmDis[str]+="${ksmObj[int]}"
  } || ksmDis[str]+='0'
  ksmDis[str]+='.'"${ksmObj[flt]}"
}

KSM.evl() {
  local ksmCmd
  case "${2}" in
    '*' )
      ksmCmd='mul' ;;
    '+' )
      ksmCmd='add' ;;
    '-' )
      ksmCmd='sub' ;;
    '/' )
      ksmCmd='div' ;;
  esac
  (( ${#ksmCmd} )) && PNC."${ksmCmd}"Obj "${1}" "${3}" "${4}"
}

KSM.inp() {
  # When the input is not on display, subsequent keystrokes make up a new
  # one. Alternatively, an empty `$ksmIen` simulates this condition.
  (( ${#ksmIen} )) && [ "${ksmDis[key]}" == 'ksmInp' ] || {
    PNC.clrObj ksmInp
    ksmDec=
    ksmIen='ien'
    (( ${#KSM_KEN} == 0 )) && [ "${ksmIns}" == '=' ] && ksmOpr=
  }
  (( ${#ksmInp[flt]} + ${#ksmInp[int]} == KSM_SPCS[len] )) && {
    # Daiso no.89.
    #ksmErr='err' || :
    :
  } || {
    case "${1}" in
      '.' )
        (( ${#ksmDec} )) || {
          ksmDec='dec'
          (( ${#ksmInp[int]} )) || ksmInp[int]=0
        } ;;
      # Prevents leading 0s.
      '0' )
        (( ${#ksmDec} )) || PNC.tstObj ksmInp || {
          KSM.dis ksmInp
          return
        } ;&
      '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9' )
        (( ${#ksmDec} )) && {
          ksmInp[flt]+="${1}" || :
        } || ksmInp[int]+="${1}" ;;
    esac
  }
  KSM.dis ksmInp
}

KSM.ist() {
  local -A ksmAcc ksmOb1 ksmOb2
  local ksmDly='dly'
  (( ${#ksmOpr} )) && {
    case "${ksmIns}" in
      '*' | '+' | '-' | '/' )
        PNC.cpyObj ksmOb1 ksmRes
        PNC.cpyObj ksmOb2 "${ksmDis[key]}"
        case "${ksmDis[key]}" in
          'ksmInp' | 'ksmMem' )
            case "${1}" in
              '%' )
                case "${ksmOpr}" in
                  '*' | '+' | '-' | '/' )
                    PNC.shrObj ksmOb2 2 ;;&
                  '+' | '-' )
                    PNC.mulObj ksmAcc ksmOb1 ksmOb2
                    PNC.cpyObj ksmOb2 ksmAcc
                    PNC.cpyObj ksmInp ksmRes ;;
                esac ;;&
              '%' | '=' | '[' | ']' )
                case "${ksmOpr}" in
                  '*' )
                    PNC.cpyObj ksmCon ksmRes ;;
                  '+' | '-' | '/' )
                    PNC.cpyObj ksmCon ksmInp ;;
                esac ;;&
              '%' | '*' | '+' | '-' | '/' | '=' | '[' | ']' )
                KSM.res "${ksmOpr}" ksmOb1 ksmOb2 ;;&
              '[' | ']' )
                KSM.mem "${1}" ksmMem ksmRes ;;
            esac ;;
          'ksmRes' )
            case "${1}" in
              '%' )
                case "${ksmOpr}" in
                  '*' | '/' )
                    PNC.shrObj ksmOb2 2 ;;
                  '+' | '-' )
                    # LS-270H.
                    #PNC.clrObj ksmRes ;;
                    return ;;
                esac ;;&
              '%' | '=' | '[' | ']' )
                case "${ksmOpr}" in
                  '*' | '+' | '-' | '/' )
                    PNC.cpyObj ksmCon ksmRes ;;&
                  '/' )
                    # HS-8LU.
                    #;;&
                    PNC.cpyObj ksmOb1 KSM_ONE ;;&
                  '*' | '/' )
                    KSM.res "${ksmOpr}" ksmOb1 ksmOb2 ;;
                esac ;;&
              '[' | ']' )
                KSM.mem "${1}" ksmMem ksmRes ;;
            esac ;;
        esac ;;
      '=' )
        case "${ksmDis[key]}" in
          'ksmInp' | 'ksmMem' )
            case "${1}" in
              '%' | '=' )
                case "${ksmOpr}" in
                  '+' | '-' | '/' )
                    PNC.cpyObj ksmOb1 ksmInp
                    PNC.cpyObj ksmOb2 ksmCon ;;
                  '*' )
                    PNC.cpyObj ksmOb1 ksmCon
                    PNC.cpyObj ksmOb2 ksmInp ;;
                esac ;;&
              '%' )
                case "${ksmOpr}" in
                  '*' | '+' | '-' | '/' )
                    PNC.shrObj ksmOb2 2 ;;&
                  '+' | '-' )
                    PNC.mulObj ksmAcc ksmOb1 ksmOb2
                    PNC.cpyObj ksmOb2 ksmAcc
                    PNC.cpyObj ksmOb1 ksmCon ;;
                esac ;;&
              '%' | '=' )
                KSM.res "${ksmOpr}" ksmOb1 ksmOb2 ;;
              '*' | '+' | '-' | '/' | '[' | ']' )
                PNC.cpyObj ksmRes ksmInp ;;&
              '[' | ']' )
                KSM.mem "${1}" ksmMem ksmInp ;;
            esac ;;
          'ksmRes' )
            case "${1}" in
              '%' | '=' )
                PNC.cpyObj ksmOb1 ksmRes
                PNC.cpyObj ksmOb2 ksmCon ;;&
              '%' )
                case "${ksmOpr}" in
                  '*' | '/' )
                    PNC.shrObj ksmOb2 2
                    KSM.res "${ksmOpr}" ksmOb1 ksmOb2 ;;
                  '+' | '-' )
                    ksmDly= ;;
                esac ;;
              '=' )
                KSM.res "${ksmOpr}" ksmOb1 ksmOb2 ;;
              '[' | ']' )
                KSM.mem "${1}" ksmMem ksmRes ;;
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
        #ksmDly= ;;
        (( ${#KSM_KEN} )) || PNC.clrObj ksmRes ;;
      '*' | '+' | '-' | '/' | '=' | '[' | ']' )
        PNC.cpyObj ksmRes "${ksmDis[key]}" ;;&
      '[' | ']' )
        KSM.mem "${1}" ksmMem ksmRes ;;
    esac
  }
  case "${1}" in
    '%' | '[' | ']' )
      ksmIns='=' ;;
    '*' | '+' | '-' | '/' | '=' )
      ksmIns="${1}" ;;&
    '*' | '+' | '-' | '/' )
      ksmOpr="${1}" ;;
  esac
  (( ${#ksmDly} )) && KSM.dly
  KSM.dis ksmRes
}

KSM.k2i() {
  [ "${1}" == 'ksmKey' ] || local -n ksmKey="${1}"
  case "${ksmKey}" in
    "${KSM_KEYS[add]}" )
      ksmKey='+' ;;
    "${KSM_KEYS[clr]}" )
      ksmKey=$'\u7f' ;;
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
      (( ${#ksmDbug} )) && declare -p ksmDis ksmInp ksmCon ksmMem ksmRes \
          ksmDec ksmErr ksmFlu ksmIen ksmIns ksmNul ksmOpr ;;
    * )
      ksmKey= ;;
  esac
}

KSM.mem() {
  local -A ksmOut
  local ksmSym
  case "${1}" in
    ']' )
      ksmSym='+' ;;
    '[' )
      ksmSym='-' ;;
  esac
  KSM.evl ksmOut "${ksmSym}" "${2}" "${3}"
  KSM.trm ksmOut "${KSM_SPCS[len]}"
  (( ${#ksmOut[err]} )) && {
    # Clear on overflow.
    #PNC.clrObj ksmRes
    # Do not copy overflows to memory.
    PNC.cpyObj ksmRes ksmOut
    ksmErr='err'
    KSM.dis ksmRes || :
  } || {
    PNC.cpyObj ksmMem ksmOut
    ksmIen=
    KSM.dis "${3}"
  }
}

KSM.mrc() {
  # Clear the memory (MC) only when it is on display.
  [ "${ksmDis[key]}" == 'ksmMem' ] && {
    PNC.clrObj ksmMem
    ksmIen=
    KSM.dis ksmInp || :
  } || {
    # For the value to remain on display after MC.
    PNC.cpyObj ksmInp ksmMem
    (( ${#KSM_KEN} == 0 )) && [ "${ksmIns}" == '=' ] && ksmOpr=
    KSM.dis ksmMem
  }
}

KSM.res() {
  local -A ksmOut
  KSM.evl ksmOut "${1}" "${2}" "${3}"
  KSM.trm ksmOut "${KSM_SPCS[len]}"
  ksmErr="${ksmOut[err]}"
  PNC.cpyObj ksmRes ksmOut
}

# Based on Heron's method.
KSM.rt2() {
  local -A ksmAc1 ksmAc2 ksmAcA ksmAcB ksmLen ksmOut
  local ksmItr="${KSM_RT2S[max]}"
  KSM.dly
  PNC.cpyObj ksmInp "${ksmDis[key]}"
  (( ${#ksmInp[neg]} )) && {
    ksmInp[neg]=
    ksmErr='err'
  }
  PNC.cpyObj ksmAc1 ksmInp
  PNC.mulFlt ksmLen ${#ksmAc1[int]} 0 0 5
  PNC.shrObj ksmAc1 "${ksmLen[int]}"
  while (( ksmItr-- )); do
    PNC.divObj ksmOut ksmInp ksmAc1
    PNC.addObj ksmAc2 ksmOut ksmAc1
    PNC.mulObj ksmOut ksmAc2 KSM_HLF
    KSM.trm ksmOut "${KSM_RT2S[pcs]}"
    PNC.cpyObj ksmAcA ksmOut
    KSM.trm ksmAcA "${KSM_SPCS[len]}"
    [ "${ksmAcA[int]}""${ksmAcA[flt]}" \
        == "${ksmAcB[int]}""${ksmAcB[flt]}" ] && break
    PNC.cpyObj ksmAc1 ksmOut
    PNC.cpyObj ksmAcB ksmAcA
  done
  PNC.cpyObj ksmInp ksmOut
  (( ${#KSM_RT2S[rnd]} )) && [[ "${ksmOut[flt]}" == +(9) ]] && {
    PNC.addObj ksmInp ksmOut KSM_ONE
    ksmInp[flt]=
  }
  KSM.trm ksmInp "${KSM_SPCS[len]}"
  ksmInp[err]=
  ksmIen=
  KSM.dis ksmInp
}

KSM.sgn() {
  local -n ksmObj
  # If the input is on display, then change its sign.
  [ "${ksmDis[key]}" == 'ksmInp' ] && {
    ksmObj=ksmInp || :
  # Otherwise, the display should not mutate here. Copy
  # it to the result and change the latter's sign.
  } || {
    PNC.cpyObj ksmRes "${ksmDis[key]}"
    ksmObj=ksmRes
  }
  # HS-8LU.
  #(( ${#ksmDec} || ${#ksmObj[int]} )) && {
  # LS-154TG.
  #[[ "${ksmObj[flt]}""${ksmObj[int]}" == *(0) ]] || {
  {
    (( ${#ksmObj[neg]} )) && {
      ksmObj[neg]=
    } || ksmObj[neg]='neg'
    KSM.dis "${!ksmObj}"
  }
}

KSM.trm() {
  [ "${1}" == 'ksmObj' ] || local -n ksmObj="${1}"
  local -A ksmDif ksmLen
  PNC.subInt ksmDif "${2}" ${#ksmObj[int]}
  (( ${#ksmDif[neg]} )) && {
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
  ksmDbug='dbug'
  shift
}
KSM.dis ksmInp
while true; do
  (( ${#ksmFlu} )) || while read -st 0.01 ksmNul; do
    :
  done
  read -d $'\u0' -sn 1 -p $'\r'"${KSM_SPCS[dis]}"$' \r'"${ksmDis[str]}"
  echo -en '\r'"${KSM_SPCS[dis]}"' \r'
  [ "${REPLY}" == $'\u1b' ] && {
    read -st 0.01
    ksmFlu='flu' || :
  } || ksmFlu=
  KSM.k2i REPLY
  case "${REPLY}" in
    '.' | '0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9' )
      (( ${#ksmErr} )) || KSM.inp "${REPLY}" ;;
    '%' | '*' | '+' | '-' | '/' | '=' | '[' | ']' )
      (( ${#ksmErr} )) || KSM.ist "${REPLY}" ;;
    $'\u7f' )
      KSM.clr ;;
    '`' )
      (( ${#ksmErr} )) || KSM.sgn ;;
    'p' )
      (( ${#ksmErr} )) || KSM.mrc ;;
    'r' )
      (( ${#ksmErr} )) || KSM.rt2 ;;
  esac
done
