"
I am ARecord.
I am a DNSRecord.

I hold the actual IP address of a host.
"
Class {
	#name : #ARecord,
	#superclass : #DNSRecord,
	#instVars : [
		'address'
	],
	#category : #'Net-Protocols-DNS-MessageFormat'
}

{ #category : #accessing }
ARecord class >> type [
	^ 1
]

{ #category : #accessing }
ARecord >> address [
	^ address
]

{ #category : #accessing }
ARecord >> address: aByteArray [
	address := aByteArray
]

{ #category : #resolving }
ARecord >> addressUsing: resolver [

	^ self address
]

{ #category : #resolving }
ARecord >> addressesUsing: resolver [

	^ { self address }
]

{ #category : #printing }
ARecord >> printOn: aStream [
	aStream nextPutAll: name; nextPutAll: ': A '; print: address
]

{ #category : #'reading/writing' }
ARecord >> readFrom: aStream [
	super readFrom: aStream.
	address := (aStream next: (aStream nextNumber: 2)) asByteArray
]

{ #category : #'reading/writing' }
ARecord >> writeOn: aStream [
	super writeOn: aStream.
	aStream
		nextNumber: 2 put: address size;
		nextPutAll: address
]
