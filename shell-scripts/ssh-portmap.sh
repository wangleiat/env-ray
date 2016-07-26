#!/bin/bash
# ssh port map

# Socks5 and DNS
#ssh -g -D 8080 -L 5353:127.0.0.1:5353 10.10.41.32
#socat tcp4-listen:5353,reuseaddr,fork udp:8.8.8.8:53 # server
#socat udp4-listen:53,reuseaddr,fork tcp:127.0.0.1:5353

# Pop3
#ssh -g -L 110:159.226.40.154:110 10.10.41.32

# SMTP
#ssh -gf -N -L 25:159.226.40.154:25 10.10.41.32

