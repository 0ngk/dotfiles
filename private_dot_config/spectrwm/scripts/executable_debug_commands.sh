#!/bin/sh

# Debug script to check actual command outputs on OpenBSD

echo "=== CPU Info ==="
echo "sysctl kern.cp_time:"
sysctl kern.cp_time 2>&1
echo ""
echo "sysctl -n kern.cp_time:"
sysctl -n kern.cp_time 2>&1
echo ""

echo "=== Memory Info ==="
echo "top -b -1 | grep -i memory:"
top -b -1 2>&1 | grep -i 'memory' | head -n 1
echo ""

echo "=== Load Average ==="
echo "sysctl vm.loadavg:"
sysctl vm.loadavg 2>&1
echo ""
echo "sysctl -n vm.loadavg:"
sysctl -n vm.loadavg 2>&1
echo ""

echo "=== Network Info ==="
echo "netstat -rn (default route):"
netstat -rn 2>&1 | grep '^default'
echo ""
echo "netstat -ibn:"
netstat -ibn 2>&1 | head -n 10
echo ""

echo "=== Volume Info ==="
echo "sndioctl output.level:"
sndioctl -n output.level 2>&1
echo ""
echo "mixerctl outputs.master:"
mixerctl -n outputs.master 2>&1
echo ""

echo "=== Available Commands ==="
for cmd in xdotool xprop playerctl; do
  if command -v "$cmd" >/dev/null 2>&1; then
    echo "$cmd: available"
  else
    echo "$cmd: NOT available"
  fi
done
