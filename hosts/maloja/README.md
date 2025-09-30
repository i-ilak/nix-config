# Maloja

## General setup

`maloja` is the homelab server.
It hosts all internal services that don't need a huge amount of resources and in which there is more to lose than to gain by exposing them to the public internet.
The `Let's encrypt` certificates are obtained over `acme` via the `dns-01` challenge, providing `https` for all internal sites.
