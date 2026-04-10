#!/usr/bin/env bash
set -euo pipefail

mkdir -p /run/sshd
chown root:root /run/sshd
chmod 755 /run/sshd

mkdir -p /root/.ssh
chmod 700 /root/.ssh
if [ -f /root/.ssh/authorized_keys ]; then
  chmod 600 /root/.ssh/authorized_keys
fi

if [ -f /etc/ssh/sshd_config ]; then
  sed -i 's/^[#[:space:]]*PasswordAuthentication .*/PasswordAuthentication no/' /etc/ssh/sshd_config || true
  sed -i 's/^[#[:space:]]*ChallengeResponseAuthentication .*/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config || true
  sed -i 's/^[#[:space:]]*UsePAM .*/UsePAM no/' /etc/ssh/sshd_config || true
  if ! grep -q '^PasswordAuthentication no$' /etc/ssh/sshd_config; then
    echo 'PasswordAuthentication no' >> /etc/ssh/sshd_config
  fi
  if ! grep -q '^ChallengeResponseAuthentication no$' /etc/ssh/sshd_config; then
    echo 'ChallengeResponseAuthentication no' >> /etc/ssh/sshd_config
  fi
  if ! grep -q '^UsePAM no$' /etc/ssh/sshd_config; then
    echo 'UsePAM no' >> /etc/ssh/sshd_config
  fi
fi

if [ "${DISABLE_AUTO_TMUX:-0}" != "1" ] && [ -f /root/.ssh/authorized_keys ]; then
  tmp_keys="$(mktemp)"
  printf '%s\n' 'command="if [ -z \"$TMUX\" ]; then tmux new-session -A -s main; else exec \"$SHELL\"; fi"' > "$tmp_keys"
  cat /root/.ssh/authorized_keys >> "$tmp_keys"
  mv "$tmp_keys" /root/.ssh/authorized_keys
  chmod 600 /root/.ssh/authorized_keys
fi

exec /usr/sbin/sshd -D -e
