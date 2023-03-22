"
I am TXTRecord.
I am a DNSRecord.

I hold descriptive text.
"
Class {
	#name : #TXTRecord,
	#superclass : #DNSRecord,
	#instVars : [
		'strings'
	],
	#category : #'Neo-DNS-Core-Messages'
}

{ #category : #accessing }
TXTRecord class >> type [
	^ 16
]

{ #category : #printing }
TXTRecord >> printOn: aStream [
	aStream nextPutAll: name; nextPutAll: ': TXT '; nextPutAll: strings printString
]

{ #category : #'reading/writing' }
TXTRecord >> readFrom: aStream [
	| len |
	super readFrom: aStream.
	len := aStream nextNumber: 2.
	self stringsFromData: (aStream next: len).

]

{ #category : #accessing }
TXTRecord >> strings [
	"Answer the value of strings"

	^ strings
]

{ #category : #accessing }
TXTRecord >> strings: anObject [
	"Set the value of strings"

	strings := anObject
]

{ #category : #'reading/writing' }
TXTRecord >> stringsFromData: anObject [
	"Set the value of strings"

	| inStrm len data |
	strings := OrderedCollection new.
	inStrm := ReadStream on: anObject.
	[inStrm atEnd]
		whileFalse: [
			len := inStrm next asInteger.
			data := inStrm next: len.
			strings addLast: data .
		].

]
