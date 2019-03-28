"
I am NeoDNSRequest.

I represent an outstanding DNS request as processed by NeoDNSClient.

I am an implementation class, not to be used directly.
"
Class {
	#name : #NeoDNSRequest,
	#superclass : #Object,
	#instVars : [
		'requestMessage',
		'responseMessage',
		'timestamp',
		'ttl',
		'semaphore',
		'sent'
	],
	#category : #'Net-Protocols-DNS-Experimental'
}

{ #category : #initialization }
NeoDNSRequest >> initialize [
	super initialize.
	timestamp := Time millisecondClockValue.
	semaphore := Semaphore new.
	ttl := NeoDNSTimeout value.
	sent := false
]

{ #category : #testing }
NeoDNSRequest >> isExpired [
	^ (Time millisecondsSince: timestamp) > (ttl * 1000) 
]

{ #category : #testing }
NeoDNSRequest >> isSent [
	^ sent
]

{ #category : #operations }
NeoDNSRequest >> markAsReceived [
	semaphore signal
]

{ #category : #operations }
NeoDNSRequest >> markAsSent [
	sent := true
]

{ #category : #accessing }
NeoDNSRequest >> requestMessage [
	^ requestMessage
]

{ #category : #accessing }
NeoDNSRequest >> requestMessage: anObject [
	requestMessage := anObject
]

{ #category : #accessing }
NeoDNSRequest >> responseMessage [
	^ responseMessage
]

{ #category : #accessing }
NeoDNSRequest >> responseMessage: anObject [
	responseMessage := anObject
]

{ #category : #operations }
NeoDNSRequest >> waitThenDo: block [
	^ (semaphore wait: ttl seconds)
		ifTrue: [ ConnectionTimedOut signal ] 
		ifFalse: [ block value: self responseMessage ]
]
