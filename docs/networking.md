# Networking & Ports

Stable networking is crucial for your V Rising dedicated server to be visible and joinable.

## Default Ports

The container exposes two primary UDP ports:

| Container Port | Protocol | Usage |
| :--- | :--- | :--- |
| `9876` | UDP | Game Traffic (Joining the server) |
| `9877` | UDP | Steam Query Traffic (Server list visibility) |

## Port Forwarding (WAN)

To allow players outside your local network to join, you MUST forward the game and query ports on your router to the internal IP address of your Docker host.

- **Requirement**: Use the same internal and external port numbers whenever possible.
- **Example**: Forward WAN `9876/UDP` to Docker Host `9876/UDP`.

## Server List Visibility

To ensure your server appears in the in-game server list:

1. Ensure both `9876/UDP` and `9877/UDP` are correctly forwarded.
2. In your `ServerHostSettings.json` (or via dynamic env vars), set:
   - `"ListOnSteam": true`
   - `"ListOnEOS": true`

## Custom Ports (Advanced)

If you want to use non-standard ports (e.g., `27015/UDP` and `27016/UDP`):

1. **Update Configuration**: Alter the ports in `/mnt/vrising/persistentdata/Settings/ServerHostSettings.json`:
   ```json
   {
     "Port": 27015,
     "QueryPort": 27016
   }
   ```
2. **Update Docker Mapping**: Restart your container with the new ports mapped 1:1:
   ```yaml
   ports:
     - '27015:27015/udp'
     - '27016:27016/udp'
   ```

> **Warning**: If you use different internal and external ports (e.g., `-p 12345:6789/udp`), the server will become invisible in the server list, and players will only be able to join via **Direct Connect**.

## Connectivity Issues

- **Passwords**: joining via Steam can be unreliable when the server is password-protected. We recommend using the **in-game server list** to join.
- **Firewalls**: Ensure your host's software firewall (e.g., `ufw`, `iptables`, Windows Firewall) is not blocking the UDP traffic.
