# SSLStrip-proof-of-concept
A educational demonstration of advanced ARP spoofing and SSL stripping techniques. For authorized security testing and research purposes only.

# Stealth Network Analysis PoC

**Disclaimer: This tool is provided for educational and authorized security testing purposes only. The creator is not responsible for any misuse or damage caused by this program. It is the end user's responsibility to obey all applicable local, state, and federal laws. Unauthorized use on networks you do not own or have explicit permission to test is illegal.**

## 📖 Description

This is a Proof-of-Concept (PoC) script designed to demonstrate advanced Man-in-the-Middle (MiTM) techniques, specifically:
- Stealth, low-frequency ARP spoofing/poisoning
- SSL Stripping (downgrading HTTPS to HTTP)
- Traffic interception and analysis

The script is designed to be as evasive as possible, incorporating techniques to avoid basic detection by network intrusion detection systems (NIDS).

## 🛡️ Legal and Ethical Warning

**YOU MUST HAVE EXPLICIT, WRITTEN PERMISSION to run this tool against any network that is not your own.** Using this tool on a network without permission is:
- **Illegal** in most countries.
- **Unethical** and a violation of privacy.
- **Likely to get you banned** from networks (e.g., university, workplace).
- **Could result in severe legal consequences.**

This tool is intended for:
- Security professionals to test their own defenses.
- Students learning about network security in a controlled lab environment.
- Security research and academia.

## 🚀 Getting Started (In a Lab Environment)

### Prerequisites
- A Linux machine (Kali Linux recommended for a lab setup).
- Root privileges.
- The following packages: `bettercap`, `arping`
    ```bash
    sudo apt update && sudo apt install bettercap iputils-arping
    ```

### Usage
1. Clone the repository:
   ```bash
   git clone https://github.com/VastScientist69/SSLStrip-proof-of-concept.git
   cd SSLStrip-proof-of-concept

   chmod +x stealth_script.sh

   sudo ./stealth_script.sh

   Press Ctrl+C to stop the script and trigger the cleanup routine.

   🔧 How It Works (The Theory)
The script works by:

Enabling IP Forwarding: Turns the machine into a router to pass traffic silently.

ARP Spoofing: Sends forged ARP replies to trick the target and gateway into sending their traffic through this machine.

SSL Stripping: Intercepts HTTP requests and transparently downgrades HTTPS links to HTTP, allowing plaintext inspection.

Cleanup: Upon exit, it reverses the ARP spoof and removes all iptables rules to hide its activity.

📝 License
This project is licensed under the MIT License - see the LICENSE.md file for details. This license requires that the disclaimer and warning be included in any redistribution.
