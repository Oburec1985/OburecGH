#!/bin/bash
set -u
result=/tmp/CoordinatorClaimUiProbe.result
printf '%s\n' "$CLAIM_UI_SUDO_PASSWORD" | sudo -S -p '' unshare -n /bin/bash -c 'ip link set lo up; runuser -u user -- env DISPLAY=:0 XAUTHORITY=/home/user/.Xauthority timeout 25 /tmp/rcpanel-claim-ui/CoordinatorClaimUiProbe' > "$result.log" 2>&1
echo $? > "$result.exit"
