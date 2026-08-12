#!/usr/bin/env nu

let ipv4 = "https://www.cloudflare.com/ips-v4/#"
let ipv6 = "https://www.cloudflare.com/ips-v6/#"
let rootdir = git rev-parse --show-toplevel 

http $ipv4 | save --force ($rootdir | path join "modules/caddy/cloudflare-ip-v4.txt")
http $ipv6 | save --force ($rootdir | path join "modules/caddy/cloudflare-ip-v6.txt")
