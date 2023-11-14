#!/bin/bash

pcli view sync

current_balance=$(pcli view balance | grep penumbra | awk '{ print $2 }' | tr -d 'penumbra' | head -1) &>/dev/null
dif=10
sleep 1
ceremony_bid=$(($current_balance-$dif))

if [ $ceremony_bid -gt 0 ]; then
    pcli ceremony contribute --phase 1 --bid ${ceremony_bid}penumbra --coordinator-address penumbra1qvqr8cvqyf4pwrl6svw9kj8eypf3fuunrcs83m30zxh57y2ytk94gygmtq5k82cjdq9y3mlaa3fwctwpdjr6fxnwuzrsy4ezm0u2tqpzw0sed82shzcr42sju55en26mavjnw4
else 
    echo "ERROR: Недостаточный баланс, получите токены с крана в дискорде и повторите попытку"
    exit 1
fi