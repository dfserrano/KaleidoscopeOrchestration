# Parameters:
# 1 - interval
# 2 - count
# Example: bash collect_metrics.sh 5 5000

#sudo apt-get install sysstat;

# Memory
sar -r -o memory.log $1 $2 >/dev/null 2>&1 &
# sar -r -f memory.log > memory.txt

# CPU
sar -o cpu.log $1 $2 >/dev/null 2>&1 &
# sar -f cpu.log > cpu.txt

# Network
sar -n ALL -o network.log $1 $2 >/dev/null 2>&1 &
# sar -n ALL -f network.log > network.txt
