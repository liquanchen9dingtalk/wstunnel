
<p align="center">
  <img src="https://github.com/erebe/wstunnel/raw/master/logo_wstunnel.png" alt="wstunnel logo"/>
</p>

## Description

Most of the time when you are using a public network, you are behind some kind of firewall or proxy. One of their purpose is to constrain you to only use certain kind of protocols. Nowadays, the most widespread protocol is http and is de facto allowed by third party equipment.

This tool understands this fact and uses the websocket protocol which is compatible with http in order to bypass firewalls and proxies. Wstunnel allows you to tunnel what ever traffic you want.

My inspiration came from [this project](https://www.npmjs.com/package/wstunnel) but as I don't want to install npm and nodejs to use this tool, I remade it in Haskell and improved it. 

**What to expect:**

* Good error messages and debug informations
* Static tunneling (TCP and UDP)
* Dynamic tunneling (socks5 proxy)
* Support for http proxy (when behind one)
* Support for tls/https server (with embedded self signed certificate, see comment in the example section)
* Support IPv6
* **Standalone binary for linux x86_64** (so just cp it where you want)
* Standalone archive for windows

P.S: Please do not pay attention to Main.hs because as I hate to write command line code this file is crappy

## Command line

```
Use the websockets protocol to tunnel {TCP,UDP} traffic
wsTunnelClient <---> wsTunnelServer <---> RemoteHost
Use secure connection (wss://) to bypass proxies

wstunnel [OPTIONS] ws[s]://wstunnelServer[:port]

Client options:
  -L --localToRemote=[BIND:]PORT:HOST:PORT      Listen on local and forwards
                                                traffic from remote. Can be
                                                used multiple time
  -D --dynamicToRemote=[BIND:]PORT              Listen on local and
                                                dynamically (with socks5 proxy)
                                                forwards traffic from remote
  -u --udp                                      forward UDP traffic instead
                                                of TCP
     --udpTimeoutSec=INT                        When using udp forwarding,
                                                timeout in seconds after when
                                                the tunnel connection is
                                                closed. Default 30sec, -1 means
                                                no timeout
  -p --httpProxy=USER:PASS@HOST:PORT            If set, will use this proxy
                                                to connect to the server
     --soMark=int                               (linux only) Mark network
                                                packet with SO_MARK sockoption
                                                with the specified value. You
                                                need to use {root, sudo,
                                                capabilities} to run wstunnel
                                                when using this option
     --upgradePathPrefix=String                 Use a specific prefix that
                                                will show up in the http path
                                                in the upgrade request. Useful
                                                if you need to route requests
                                                server side but don't have
                                                vhosts
     --hostHeader=String                        If set, add the custom string
                                                as host http header
     --tlsSNI=String                            If set, use custom string in
                                                the SNI during TLS handshake
     --websocketPingFrequencySec=int            do a hearthbeat ping every x
                                                seconds to maintain websocket
                                                connection
     --upgradeCredentials=USER[:PASS]           Credentials for the Basic
                                                HTTP authorization type sent
                                                with the upgrade request.
  -H --customHeaders="HeaderName: HeaderValue"  Send custom headers in the
                                                upgrade request. Can be used
                                                multiple time
  -h --help                                     Display help message
  -V --version                                  Print version information
Server options:
     --server                                   Start a server that will
                                                forward traffic for you
  -r --restrictTo=HOST:PORT                     Accept traffic to be
                                                forwarded only to this service
     --tlsCertificate=FILE                      [optional] provide a custom
                                                tls certificate (.crt) that the
                                                server will use instead of the
                                                embeded one
     --tlsKey=FILE                              [optional] provide a custom
                                                tls key (.key) that the server
                                                will use instead of the embeded
                                                one
Common options:
  -v --verbose                                  Print debug information
  -q --quiet                                    Print only errors
```

## Examples
### Simplest one
On your remote host, start the wstunnel's server by typing this command in your terminal
```bash
wstunnel --server ws://0.0.0.0:8080
```
This will create a websocket server listening on any interface on port 8080.
On the client side use this command to forward traffic through the websocket tunnel
```bash
wstunnel -D 8888 ws://myRemoteHost:8080
```
This command will create a sock5 server listening on port 8888 of a loopback interface and will forward traffic.

With firefox you can setup a proxy using this tunnel, by setting in networking preferences 127.0.0.1:8888 and selecting socks5 proxy

or with curl

```bash
curl -x socks5h://127.0.0.1:8888 http://google.com/
#Please note h after the 5, it is to avoid curl resolving DNS name locally
```

### As proxy command for SSH
You can specify `stdio` as source port on the client side if you wish to use wstunnel as part of a proxy command for ssh
```
ssh -o ProxyCommand="wstunnel -L stdio:%h:%p ws://localhost:8080" my-server
```

### When behind a corporate proxy
An other useful example is when you want to bypass an http proxy (a corporate proxy for example)
The most reliable way to do it is to use wstunnel as described below

Start your wstunnel server with tls activated
```
wstunnel --server wss://0.0.0.0:443 -r 127.0.0.1:22
```
The server will listen on any interface using port 443 (https) and restrict traffic to be forwarded only to the ssh daemon.

**Be aware that the server will use self signed certificate with weak cryptographic algorithm.
It was made in order to add the least possible overhead while still being compliant with tls.**

**Do not rely on wstunnel to protect your privacy, as it only forwards traffic that is already secure by design (ex: https)**

Now on the client side start the client with
```
wstunnel -L 9999:127.0.0.1:22 -p mycorporateproxy:8080 wss://myRemoteHost:443
```
It will start a tcp server on port 9999 that will contact the corporate proxy, negotiate a tls connection with the remote host and forward traffic to the ssh daemon on the remote host.

You may now access your server from your local machine on ssh by using
```
ssh -p 9999 login@127.0.0.1
```

### Wireguard and wstunnel
https://kirill888.github.io/notes/wireguard-via-websocket/

- If you see some throughput issue, be sure to lower the MTU of your wireguard interface (you can do it via config file) to something like 1300 or you will endup fragmenting udp packet (due to overhead of other layer) which is always causing issues
- If wstunnel cannot connect to server while wireguard is on, be sure you have added a static route via your main gateway for the ip of wstunnel server.
Else if you forward all the traffic without putting a static route, you will endup looping your traffic wireguard interface -> wstunnel client -> wireguard interface


## How to Build
Install the stack tool https://docs.haskellstack.org/en/stable/README/ or if you are a believer
```
curl -sSL https://get.haskellstack.org/ | sh
``` 
and run those commands at the root of the project
```
stack init
stack install
```

## TODO
- [x] Add sock5 proxy
- [x] Add better logging
- [x] Add better error handling
- [x] Add httpProxy authentification
- [ ] Add Reverse tunnel
- [x] Add more tests for socks5 proxy
