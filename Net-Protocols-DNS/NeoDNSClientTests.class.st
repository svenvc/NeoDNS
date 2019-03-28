"
Tests for NeoDNSClient
"
Class {
	#name : #NeoDNSClientTests,
	#superclass : #NeoSimplifiedDNSClientTests,
	#category : #'Net-Protocols-DNS-Experimental'
}

{ #category : #accessing }
NeoDNSClientTests >> dnsClient [
	^ NeoDNSClient default
]
