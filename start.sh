#!/bin/bash
set -e
[ -n "$1" ] && DNSMASQ_OPTS="--dhcp-option=option:router,$1"

echo Waiting for pipework to give us the eth1 interface...
/sbin/pipework --wait

NET=`ip addr show dev eth1|awk '/inet[^6]/ {print $2}'`

IP=`echo $NET|cut -d/ -f1`
MASK_CIDR=`echo $NET|cut -d/ -f2`
MASK=`perl -e 'print join ".", unpack "C4", pack "B*", "1" x $ARGV[0] . "0" x (32 - $ARGV[0])' $MASK_CIDR`

FIRST=`IFS=.;set -- $IP; echo $1.$2.$3.$(( $4 + 1))`
LAST=`IFS=.;set -- $IP; echo $1.$2.$3.230`

BANKSMAN_PORT=8080
BANKSMAN_URL="http://$IP:$BANKSMAN_PORT"


[ -n "$COLLINS_USER" ] && BANKSMAN_OPTS="-user $COLLINS_USER"
[ -n "$COLLINS_PASS" ] && BANKSMAN_OPTS="$BANKSMAN_OPTS -password $COLLINS_PASS"

echo Starting banksman
/banksman/banksman -uri "http://$IP:9000/api" \
				 -listen "$IP:$BANKSMAN_PORT" \
				 -kernel "$BANKSMAN_URL/static/kernel" \
				 -initrd "$BANKSMAN_URL/static/registration-initrd.gz" \
				 $BANKSMAN_OPTS &

echo Starting socat/collins proxy
socat TCP-LISTEN:9000,fork $(echo $COLLINS_PORT|tr -d '/') &

echo Starting DHCP+TFTP server...
dnsmasq --interface=eth1 \
  --dhcp-range=$FIRST,$LAST,$MASK,1h \
  --enable-tftp --tftp-root=`pwd`/static/ --no-daemon \
  --dhcp-match=set:ipxe,175 \
  --dhcp-boot=tag:!ipxe,undionly.kpxe \
  --dhcp-boot="tag:ipxe,$BANKSMAN_URL/ipxe/\${uuid}" \
  $DNSMASQ_OPTS
