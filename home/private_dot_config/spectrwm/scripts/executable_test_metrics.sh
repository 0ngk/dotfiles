#!/bin/sh

echo "=== CPU Test ==="
echo "Command: sysctl -n kern.cp_time"
sysctl -n kern.cp_time
echo ""

echo "Number of fields:"
sysctl -n kern.cp_time | awk '{print NF}'
echo ""

echo "Fields:"
sysctl -n kern.cp_time | awk '{for(i=1;i<=NF;i++) print i":", $i}'
echo ""

echo "=== Network Test ==="
echo "Default interface:"
netstat -rn | awk '/^default/ {print $NF; exit}'
echo ""

IFACE="$(netstat -rn | awk '/^default/ {print $NF; exit}')"
echo "Using interface: $IFACE"
echo ""

if [ -n "$IFACE" ]; then
  echo "Command: netstat -I $IFACE -bn (header + first line)"
  netstat -I "$IFACE" -bn | head -n 2
  echo ""

  echo "Extracting RX/TX bytes (columns 7 and 10 from Link line):"
  netstat -I "$IFACE" -bn | awk 'NR==2 {print "RX (col 7):", $7, "TX (col 10):", $10}'
  echo ""
fi

echo "Command: netstat -ibn (all interfaces)"
netstat -ibn | head -n 10
echo ""

echo "=== Testing variable persistence ==="
test_vars() {
  test_var="initial"
  echo "Inside function, before: $test_var"
  test_var="updated"
  echo "Inside function, after: $test_var"
}

test_var="global"
echo "Before function call: $test_var"
test_vars
echo "After function call: $test_var"
echo ""

echo "=== Delta calculation test ==="
prev_ticks="$(sysctl -n kern.cp_time)"
echo "First reading: $prev_ticks"
sleep 2
curr_ticks="$(sysctl -n kern.cp_time)"
echo "Second reading: $curr_ticks"
echo ""

set -- $prev_ticks
echo "Previous: user=$1 nice=$2 sys=$3 intr=$4 idle=$5"
p_user=$1 p_nice=$2 p_sys=$3 p_intr=$4 p_idle=$5

set -- $curr_ticks
echo "Current: user=$1 nice=$2 sys=$3 intr=$4 idle=$5"
c_user=$1 c_nice=$2 c_sys=$3 c_intr=$4 c_idle=$5

echo ""
echo "Deltas:"
echo "user: $((c_user - p_user))"
echo "nice: $((c_nice - p_nice))"
echo "sys: $((c_sys - p_sys))"
echo "intr: $((c_intr - p_intr))"
echo "idle: $((c_idle - p_idle))"

total=$((c_user - p_user + c_nice - p_nice + c_sys - p_sys + c_intr - p_intr + c_idle - p_idle))
active=$((c_user - p_user + c_nice - p_nice + c_sys - p_sys + c_intr - p_intr))
echo ""
echo "Total delta: $total"
echo "Active delta: $active"
if [ "$total" -gt 0 ]; then
  cpu_percent=$((active * 100 / total))
  echo "CPU usage: $cpu_percent%"
fi
