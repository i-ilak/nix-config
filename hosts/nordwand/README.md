# Nordwand

Provide isolated, secure way to server passwords.

## Design doc

Goals:

- Run on local network, but compromise of the service should not compromise local network
  - Use Tailscale to create a isolated "VLAN" to which nothing can connect, and which cannot communicate to the outside.
- Use [Cloudflare Tunnel]() to make use of Cloudflares DDoS protection, etc.
- Make sure that HTTPS is used wherever possible
- Backup data
  - [ ] Still a Todo.

Non-goals:

- Run on VPS to avoid most security considerations

Intended sequence diagram:

```mermaid
sequenceDiagram
    participant U as User/Browser
    participant CF as Cloudflare
    participant CFD as Cloudflared
    participant C as Caddy
    participant VW as Vaultwarden
    participant FS as File System

    Note over U,FS: Initial HTTPS Request to DOMAIN

    U->>+CF: HTTPS GET DOMAIN
    Note right of CF: SSL termination, DDoS protection,<br/>WAF filtering, bot detection

    CF->>+CFD: Forward request via tunnel
    Note right of CFD: Cloudflared tunnel daemon<br/>receives encrypted request

    CFD->>+C: HTTPS request to 127.0.0.1:8080
    Note right of C: mTLS verification using<br/>Cloudflare origin pull CA

    Note over C: Reverse proxy headers added:<br/>Host, X-Real-IP, X-Forwarded-For,<br/>X-Forwarded-Proto

    C->>+VW: HTTP request to 127.0.0.1:8000
    Note right of VW: Vaultwarden processes request<br/>(authentication, vault operations)

    alt Database Operations
        VW->>+FS: SQLite read/write
        Note right of FS: Encrypted LUKS volume<br/>/persist/var/lib/vaultwarden
        FS-->>-VW: Data response
    end

    VW-->>-C: HTTP response
    Note left of C: Response processed by Caddy<br/>reverse proxy

    C-->>-CFD: HTTPS response
    Note left of CFD: Response encrypted for tunnel

    CFD-->>-CF: Encrypted response via tunnel
    Note left of CF: Response optimization,<br/>caching headers, security headers

    CF-->>-U: HTTPS response

    Note over U,FS: Subsequent WebSocket Connection (for real-time sync)

    U->>+CF: WebSocket Upgrade to DOMAIN
    CF->>+CFD: WebSocket via tunnel
    CFD->>+C: WebSocket to 127.0.0.1:8080
    C->>+VW: WebSocket to 127.0.0.1:8000

    Note over VW: WEBSOCKET_ENABLED = true<br/>Real-time vault synchronization

    VW-->>C: WebSocket data
    C-->>CFD: WebSocket data
    CFD-->>CF: WebSocket data
    CF-->>U: WebSocket data

    Note over U,VW: Persistent WebSocket connection<br/>for real-time updates
```
