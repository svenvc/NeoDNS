"
I am MXRecord.
I am a DNSRecord.

I hold mail exchange information.
"
Class {
	#name : #MXRecord,
	#superclass : #DNSRecord,
	#instVars : [
		'priority',
		'mx'
	],
	#category : #'Net-Protocols-DNS-MessageFormat'
}

{ #category : #accessing }
MXRecord class >> type [
	^ 15
]

{ #category : #accessing }
MXRecord >> mx [
	^ mx
]

{ #category : #printing }
MXRecord >> printOn: aStream [
	aStream nextPutAll: name; nextPutAll: ': MX '; nextPutAll: mx; nextPutAll: ' ('; print: priority; nextPut: $)
]

{ #category : #accessing }
MXRecord >> priority [
	^ priority
]

{ #category : #'reading/writing' }
MXRecord >> readFrom: aStream [
	super readFrom: aStream.
	aStream skip: 2.
	priority := aStream nextNumber: 2.
	mx := self class readNameFrom: aStream
]
