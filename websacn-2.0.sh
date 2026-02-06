#!/bin/bash

# ===============================
# Author: You 😎
# Purpose: Automated Web Recon & Vuln Scanning
# ===============================

if [ $# -lt 2 ]; then
  echo "Usage: $0 <domain> <path_wordlist>"
  exit 1
fi

DOMAIN=$1
WORDLIST=$2
OUTDIR="scan_$DOMAIN"

mkdir -p $OUTDIR/{subdomains,ips,subnets,httpx,paths,screenshots,vulns}

echo "[+] Target: $DOMAIN"
echo "[+] Output: $OUTDIR"
echo

# ===============================
# 1. Resolve IPs & Subnets
# ===============================

echo "[+] Resolving IPs..."
dig +short A $DOMAIN | tee $OUTDIR/ips/ips.txt

echo "[+] Identifying subnets..."
while read ip; do
  whois $ip | grep -E "CIDR|NetRange" >> $OUTDIR/subnets/subnets.txt
done < $OUTDIR/ips/ips.txt

# ===============================
# 2. Subdomain Enumeration
# ===============================

echo "[+] Enumerating subdomains..."

subfinder -d $DOMAIN -silent > $OUTDIR/subdomains/subfinder.txt
assetfinder --subs-only $DOMAIN > $OUTDIR/subdomains/assetfinder.txt
amass enum -passive -d $DOMAIN > $OUTDIR/subdomains/amass.txt

cat $OUTDIR/subdomains/*.txt | sort -u > $OUTDIR/subdomains/all.txt

# ===============================
# 3. Live Host Detection
# ===============================

echo "[+] Probing live hosts..."

cat $OUTDIR/subdomains/all.txt | \
httpx -silent -status-code -title -tech-detect \
-o $OUTDIR/httpx/live.txt

cut -d " " -f1 $OUTDIR/httpx/live.txt > $OUTDIR/httpx/urls.txt

# ===============================
# 4. Path Fuzzing (httpx)
# ===============================

echo "[+] Fuzzing common paths..."

httpx \
  -l $OUTDIR/httpx/urls.txt \
  -path $WORDLIST \
  -status-code \
  -content-length \
  -silent \
  -o $OUTDIR/paths/fuzzed_paths.txt

# ===============================
# 5. Screenshots
# ===============================

echo "[+] Taking screenshots..."

gowitness file \
  -f $OUTDIR/httpx/urls.txt \
  -P $OUTDIR/screenshots \
  --disable-db

# ===============================
# 6. Open Redirect Checks
# ===============================

echo "[+] Checking for open redirects..."

cat $OUTDIR/httpx/urls.txt | \
qsreplace "https://evil.com" | \
httpx -silent -location -mc 301,302 \
-o $OUTDIR/vulns/open_redirects.txt

# ===============================
# 7. XSS Scanning (Dalfox)
# ===============================

echo "[+] Running Dalfox XSS scan..."

cat $OUTDIR/httpx/urls.txt | \
dalfox pipe \
  --skip-bav \
  --silent \
  -o $OUTDIR/vulns/xss.txt

# ===============================
# Done
# ===============================

echo
echo "[✔] Scan completed!"
echo "[✔] Results saved in $OUTDIR"
