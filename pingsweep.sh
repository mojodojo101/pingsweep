#!/bin/bash
first_ip=${1:-192.168.1.1}
last_ip=${2:-192.168.1.254}

alternate_dotted_quad_to_integer()
{
  IFS="." read a b c d <<< `echo $1`
  echo "($a * 256 * 256 * 256) + ($b * 256 * 256) + ($c * 256) + $d" | bc
}

dotted_quad_to_integer()
{
  IFS="." read a b c d <<< `echo $1`
  expr $(( (a<<24) + (b<<16) + (c<<8) + d))
}

integer_to_dotted_quad()
{
  local ip=$1
  let a=$((ip>>24&255))
  let b=$((ip>>16&255))
  let c=$((ip>>8&255))
  let d=$((ip&255))
  echo "${a}.${b}.${c}.${d}"
}
usage= echo "pingsweep.sh <ip_start> <ip_end>"
ARGC=$#
if [ $ARGC -ne 2 ]
then
	echo $usage >2;
	exit 0;
fi

start=$(dotted_quad_to_integer $first_ip)
end=$(dotted_quad_to_integer $last_ip)
for ip in `seq $start $end`
do
  ( ping -c1 -w1 ${ip} > /dev/null 2>&1 && integer_to_dotted_quad ${ip} ) &
done
wait
