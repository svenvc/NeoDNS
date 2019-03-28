Class {
	#name : #NameResolverLookupFailure,
	#superclass : #NameLookupFailure,
	#instVars : [
		'errorCode'
	],
	#category : #'Net-Protocols-DNS-NameResolver'
}

{ #category : #'as yet unclassified' }
NameResolverLookupFailure >> defaultAction [
	"Backward compatibility"
	| response |
	response := (UIManager default  chooseFrom: #( 'Retry' 'Give Up' 'halt')
			title: (self messageText , ' - ' , errorCode printString )).
	response = 3
		ifTrue: [self halt].
	^ response = 2
		ifFalse: [self retry]
]

{ #category : #accessing }
NameResolverLookupFailure >> errorCode [
	"Answer the value of errorCode"

	^ errorCode
]

{ #category : #accessing }
NameResolverLookupFailure >> errorCode: anObject [
	"Set the value of errorCode"

	errorCode := anObject
]

{ #category : #accessing }
NameResolverLookupFailure >> isResumable [
	"Determine whether an exception is resumable."

	^ true
]

{ #category : #accessing }
NameResolverLookupFailure >> standardMessageText [
	"Generate a standard textual description"

	^ String
		streamContents: [ :stream | 
			hostName
				ifNotNil: [ 
					stream << 'cannot resolve '.
					stream print: self hostName ].
			messageText
				ifNotNil: [ 
					stream space; << messageText ] ]
]
