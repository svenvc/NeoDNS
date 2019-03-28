"
I am UnrecognizedRecord.
I am a DNSRecord.

I represent any RR with no explicit subclass under DNSRecord.
"
Class {
	#name : #UnrecognizedRecord,
	#superclass : #DNSRecord,
	#instVars : [
		'data',
		'type'
	],
	#category : #'Net-Protocols-DNS-MessageFormat'
}

{ #category : #accessing }
UnrecognizedRecord >> data [
	^ data
]

{ #category : #accessing }
UnrecognizedRecord >> data: aByteArray [
	data := aByteArray
]

{ #category : #'reading/writing' }
UnrecognizedRecord >> readFrom: aStream [
	super readFrom: aStream.
	data := aStream next: (aStream nextNumber: 2)
]

{ #category : #accessing }
UnrecognizedRecord >> type [
	^ type
]

{ #category : #accessing }
UnrecognizedRecord >> type: anInteger [
	type := anInteger
]

{ #category : #'reading/writing' }
UnrecognizedRecord >> writeOn: aStream [
	super writeOn: aStream.
	aStream nextNumber: 2 put: data size; nextPutAll: data
]
