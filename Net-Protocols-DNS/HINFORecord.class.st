"
I am HINFORecord.
I am a DNSRecord.

I hold general information about a host.
"
Class {
	#name : #HINFORecord,
	#superclass : #DNSRecord,
	#instVars : [
		'cpu',
		'os'
	],
	#category : #'Net-Protocols-DNS-MessageFormat'
}

{ #category : #accessing }
HINFORecord class >> type [
	^ 13
]

{ #category : #'reading/writing' }
HINFORecord >> readFrom: aStream [
	super readFrom: aStream.
	aStream skip: 2.
	cpu := self class readNameFrom: aStream.
	os := self class readNameFrom: aStream
]
