# NeoDNS
Experimental in-image DNS implementation for Pharo.

[![CI](https://github.com/svenvc/NeoDNS/actions/workflows/CI.yml/badge.svg)](https://github.com/svenvc/NeoDNS/actions/workflows/CI.yml)

There are two DNS clients, **NeoSimplifiedDNSClient** and **NeoDNSClient** using the same interface but different implementations, see their class comments for more information.

Additionally, there is **NeoNetworkState** that uses a simple DNS operation to maintain whether we have an operational network.

## Usage
```Smalltalk
  NeoSimplifiedDNSClient default addressForName: 'stfx.eu'.
  NeoSimplifiedDNSClient new useMulticastDNS; addressForName: 'zappy.local'.
  
  NeoDNSClient default addressForName: 'stfx.eu'.
  NeoDNSClient default nameForAddress: #[46 137 113 215] asSocketAddress.
  
  NeoNetworkState default hasInternetConnection.
  NeoNetworkState default ensureInternetConnection.

  NeoNetworkState default airplaneMode.
  NeoNetworkState default airplaneMode: true.
  NeoNetworkState default airplaneMode: false.
```

## References
https://en.wikipedia.org/wiki/DomainNameSystem

## Message code copied from 
http://www.smalltalkhub.com/#!/~BenComan/DNS/

MIT License
