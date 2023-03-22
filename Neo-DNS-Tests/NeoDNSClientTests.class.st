"
Tests for NeoDNSClient
"
Class {
	#name : #NeoDNSClientTests,
	#superclass : #NeoSimplifiedDNSClientTests,
	#category : #'Neo-DNS-Tests'
}

{ #category : #accessing }
NeoDNSClientTests >> dnsClient [
	^ NeoDNSClient default
]
