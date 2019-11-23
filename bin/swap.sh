#!/bin/bash
display_usage() {
   echo "Usage: <amount> <min_eth> <fee> [nonce] [expiry]"
}

#Domain separator data
VERSION='1'
CHAIN_ID=99
ADDRESS=$DACH
if [ -z "$DACH" ]; then
    echo "DACH address not set"
    exit 1
fi

DOMAIN_SEPARATOR=$(seth keccak \
     $(seth keccak $(seth --from-ascii "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"))\
$(echo $(seth keccak $(seth --from-ascii "Dai Automated Clearing House"))\
$(seth keccak $(seth --from-ascii $VERSION))$(seth --to-uint256 $CHAIN_ID)\
$(seth --to-uint256 $ADDRESS) | sed 's/0x//g'))
#echo $DOMAIN_SEPARATOR

#Permit type data
SWAP_TYPEHASH=$(seth keccak $(seth --from-ascii "Swap(address sender,uint256 amount,uint256 min_eth,uint256 fee,uint256 nonce,uint256 expiry,address relayer)"))
#echo $permit_TYPEHASH

#permit data
SENDER=$ETH_FROM
AMOUNT=$1
MINETH=$2
FEE=$3
NONCE=${4:-0}
EXPIRY=${5:-0}
RELAYER=${6:-0x47f5b4DDAFD69A6271f3E15518076e0305a2C722}

MESSAGE=0x1901\
$(echo $DOMAIN_SEPARATOR\
$(seth keccak \
$SWAP_TYPEHASH\
$(echo $(seth --to-uint256 $SENDER)\
$(seth --to-uint256 $AMOUNT)\
$(seth --to-uint256 $MINETH)\
$(seth --to-uint256 $FEE)\
$(seth --to-uint256 $NONCE)\
$(seth --to-uint256 $EXPIRY)\
$(seth --to-uint256 $RELAYER)\
      | sed 's/0x//g')) \
      | sed 's/0x//g')
#echo "MESSAGE" $MESSAGE
SIG=$(ethsign msg --no-prefix --data $MESSAGE)
#echo $SIG
##JSON output
printf '{"swap": {"sender":"%s","amount":"%s","min_eth":"%s", "fee": "%s", "nonce": "%s", "expiry": "%s", "v": "%s", "r": "%s", "s": "%s"}}\n' "$SENDER" "$AMOUNT" "$MINETH" "$FEE" "$NONCE" "$EXPIRY" $((0x$(echo "$SIG" | cut -c 131-132))) $(echo "$SIG" | cut -c 1-66) "0x"$(echo "$SIG" | cut -c 67-130)