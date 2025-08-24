The only safe way to test this tool is in a controlled lab. Here are two methods:

## Method 1: Virtual Machines (Recommended)
1. Use VirtualBox or VMware.
2. Create three virtual machines:
   - **Attacker:** Kali Linux.
   - **Victim:** Windows 10 or Linux.
   - **Gateway:** A Linux VM with `iptables` set up to act as a router (e.g., using `dhcpd`).
3. Set the VMs to an **Internal Network** or **Host-Only Network** in your hypervisor. This ensures they are completely isolated from the internet and your real network.

## Method 2: Isolated Physical Hardware
Use a physical switch and machines that are **not connected to your home router or the internet**.
