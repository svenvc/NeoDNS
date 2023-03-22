"
I am SRVRecord.
I am a DNSRecord.

I hold server selection information.
"
Class {
	#name : #SRVRecord,
	#superclass : #DNSRecord,
	#instVars : [
		'priority',
		'weight',
		'port',
		'target'
	],
	#category : #'Neo-DNS-Core-Messages'
}

{ #category : #accessing }
SRVRecord class >> type [
	^ 33
]

{ #category : #accessing }
SRVRecord >> port [
	"Answer the value of port"

	^ port
]

{ #category : #accessing }
SRVRecord >> port: anObject [
	"Set the value of port"

	port := anObject
]

{ #category : #printing }
SRVRecord >> printOn: aStream [
	aStream
		nextPutAll: name;
		nextPutAll: ': SRV ';
		nextPutAll: target;
		nextPutAll: ':';
		print: port ;
		nextPutAll: ' (';
		print: priority;
		nextPutAll: ' ';
		print: weight;
		nextPut: $)
]

{ #category : #accessing }
SRVRecord >> priority [
	"Answer the value of priority"

	^ priority
]

{ #category : #accessing }
SRVRecord >> priority: anObject [
	"Set the value of priority"

	priority := anObject
]

{ #category : #'reading/writing' }
SRVRecord >> readFrom: aStream [
	super readFrom: aStream.
	aStream skip: 2.
	priority := aStream nextNumber: 2.
	weight := aStream nextNumber: 2.
	port := aStream nextNumber: 2.
	target := self class readNameFrom: aStream
]

{ #category : #accessing }
SRVRecord >> target [
	"Answer the value of target"

	^ target
]

{ #category : #accessing }
SRVRecord >> target: anObject [
	"Set the value of target"

	target := anObject
]

{ #category : #accessing }
SRVRecord >> weight [
	"Answer the value of weight"

	^ weight
]

{ #category : #accessing }
SRVRecord >> weight: anObject [
	"Set the value of weight"

	weight := anObject
]
