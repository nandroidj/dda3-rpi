
export MACINTOSH_HOSTIP=$(ifconfig | grep "inet " | grep broadcast | awk ' NR==1 { gsub(/\/.*/, "", $4); print $2 } ')
export LINUX_HOSTIP=$(nmcli device show | grep IP4.ADDRESS | head -1 | awk '{print $2}' | rev | cut -c 4- | rev)

