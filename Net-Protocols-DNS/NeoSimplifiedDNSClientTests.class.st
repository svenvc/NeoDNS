"
Tests for NeoSimplifiedDNSClient
"
Class {
	#name : #NeoSimplifiedDNSClientTests,
	#superclass : #TestCase,
	#category : #'Net-Protocols-DNS-Experimental'
}

{ #category : #accessing }
NeoSimplifiedDNSClientTests >> dnsClient [
	^ NeoSimplifiedDNSClient default
]

{ #category : #tests }
NeoSimplifiedDNSClientTests >> testAddressForBogusName [
	| bogusName |
	bogusName := 'name-{1}.com' format: { 1e12 atRandom }.
	self 
		should: [ self dnsClient addressForName: bogusName ] 
		raise: NameLookupFailure
]

{ #category : #tests }
NeoSimplifiedDNSClientTests >> testAddressForName [
	| address |
	address := self dnsClient addressForName: 'stfx.eu'.
	self assert: address equals: #[146 185 177 20] asSocketAddress
]

{ #category : #tests }
NeoSimplifiedDNSClientTests >> testAddressForNameCNAME [
	| address |
	"Test a CNAME record that is an alias to another ANAME record"
	address := self dnsClient addressForName: 'mc.stfx.eu'.
	self assert: address equals: #[146 185 177 20] asSocketAddress
]

{ #category : #tests }
NeoSimplifiedDNSClientTests >> testDotDecimalNotation [
	self 
		assert: (self dnsClient addressForName: '1.2.3.4') 
		equals: #[1 2 3 4] asSocketAddress 
]

{ #category : #tests }
NeoSimplifiedDNSClientTests >> testLocalHost [
	self 
		assert: (self dnsClient addressForName: 'localhost') 
		equals: #[127 0 0 1] asSocketAddress 
]

{ #category : #tests }
NeoSimplifiedDNSClientTests >> testNameForAddress [
	| hostname |
	hostname := self dnsClient nameForAddress: #[46 137 113 215] asSocketAddress.
	self assert: (hostname includesSubstring: 'aws').
	self assert: (hostname includesSubstring: 'amazon').
	self assert: (hostname includesSubstring: 'compute').
]
