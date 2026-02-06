# WebScan.sh – Automated Web Recon & Vulnerability Scanner

WebScan.sh is a **bash-based web reconnaissance and vulnerability scanning pipeline** that chains together popular open-source security tools.  
It is designed for **authorized penetration testing, bug bounty reconnaissance, and lab environments**.

The script automates:
- Subdomain enumeration
- IP & subnet discovery
- Live host probing
- Common path fuzzing
- Website screenshots
- Basic vulnerability detection (Open Redirects & XSS)

---



---

## Features

- Passive & active **subdomain enumeration**
- **IP resolution** and subnet discovery
- Fast **HTTP probing** with technology detection
- **Common path fuzzing** using a wordlist
- Automated **screenshots** of live web applications
- Detection of:
  - Open Redirects
  - Reflected & DOM XSS (via Dalfox)

---

## Toolchain Used

This script is a wrapper around the following tools:

- `subfinder`
- `assetfinder`
- `amass`
- `httpx`
- `dalfox`
- `gowitness`
- `dig`
- `whois`

Optional but recommended:
- `ffuf`
- `gau`
- `waybackurls`
- `nuclei`

---

## Installation

### 1. Clone the repository

```bash
git clone https://github.com/yourusername/webscan.sh
cd webscan.sh
