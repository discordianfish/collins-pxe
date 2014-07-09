#!/bin/bash
set -e
if [ -z "$3" ]
then
  echo "$0 collins-addr first,last interface [default gw]"
  exit 1
fi

COLLINS=$1
RANGE=$2
DEV=$3
[ -n "$4" ] && DNSMASQ_OPTS="--dhcp-option=option:router,$4"

NET=`ip addr show $DEV | awk '/inet / {print $2}'`
IP=`echo $NET|cut -d/ -f1`
MASK_CIDR=`echo $NET|cut -d/ -f1`
MASK=`perl -e 'print join ".", unpack "C4", pack "B*", "1" x $ARGV[0] . "0" x (32 - $ARGV[0])' $MASK_CIDR`

BANKSMAN_PORT=8080
BANKSMAN_URL="http://$IP:$BANKSMAN_PORT"


[ -n "$COLLINS_USER" ] && BANKSMAN_OPTS="-user $COLLINS_USER"
[ -n "$COLLINS_PASS" ] && BANKSMAN_OPTS="$BANKSMAN_OPTS -password $COLLINS_PASS"

echo Starting banksman
/banksman/banksman -uri "http://$COLLINS/api" \
				 -listen "$IP:$BANKSMAN_PORT" \
				 -kernel "$BANKSMAN_URL/static/kernel" \
				 -initrd "$BANKSMAN_URL/static/registration-initrd.gz" \
				 $BANKSMAN_OPTS &

echo Starting DHCP+TFTP server...
dnsmasq --interface=$DEV \
  --dhcp-range=$RANGE,$MASK,1h \
  --enable-tftp --tftp-root=`pwd`/static/ --no-daemon \
  --dhcp-match=set:ipxe,175 \
  --dhcp-boot=tag:!ipxe,undionly.kpxe \
  --dhcp-boot="tag:ipxe,$BANKSMAN_URL/ipxe/\${uuid}" \
  $DNSMASQ_OPTS
