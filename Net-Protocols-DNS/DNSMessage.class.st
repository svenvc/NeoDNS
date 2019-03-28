"
I am DNSMessage.

All communications inside of the domain protocol are carried in a single
format called a message.  The top level format of message is divided
into 5 sections (some of which are empty in certain cases) shown below:

    +---------------------+
    |        Header       |
    +---------------------+
    |       Question      | the question for the name server
    +---------------------+
    |        Answer       | RRs answering the question
    +---------------------+
    |      Authority      | RRs pointing toward an authority
    +---------------------+
    |      Additional     | RRs holding additional information
    +---------------------+

The header section is always present.  The header includes fields that
specify which of the remaining sections are present, and also specify
whether the message is a query or a response, a standard query or some
other opcode, etc.

The names of the sections after the header are derived from their use in
standard queries.  The question section contains fields that describe a
question to a name server.  These fields are a query type (QTYPE), a
query class (QCLASS), and a query domain name (QNAME).  The last three
sections have the same format: a possibly empty list of concatenated
resource records (RRs).  The answer section contains RRs that answer the
question; the authority section contains RRs that point toward an
authoritative name server; the additional records section contains RRs
which relate to the query, but are not strictly answers for the
question.
"
Class {
	#name : #DNSMessage,
	#superclass : #Object,
	#instVars : [
		'id',
		'flags',
		'questions',
		'answers',
		'authority',
		'additional'
	],
	#category : #'Net-Protocols-DNS-MessageFormat'
}

{ #category : #'instance creation' }
DNSMessage class >> addressByName: hostName [
	^ self new
		recursionDesired: true;
		addQuestion: (DNSQuery name: hostName type: ARecord type class: self classIN);
		yourself
]

{ #category : #'instance creation' }
DNSMessage class >> anyRecordsFor: hostName [
	^ self new
		recursionDesired: true;
		addQuestion: (DNSQuery name: hostName type: ANYRecord type class: self classIN);
		yourself
]

{ #category : #'instance creation' }
DNSMessage class >> axfr: domain [
	^ self new
		addQuestion: (DNSQuery name: domain type: 252 class: self classIN);
		yourself
]

{ #category : #constants }
DNSMessage class >> classIN [
	^1
]

{ #category : #'instance creation' }
DNSMessage class >> mailExchangerFor: hostName [
	^ self new
		recursionDesired: true;
		addQuestion: (DNSQuery name: hostName type: MXRecord type class: self classIN);
		yourself
]

{ #category : #'instance creation' }
DNSMessage class >> nameServersFor: domain [
	^ self new
		recursionDesired: true;
		addQuestion: (DNSQuery name: domain type: NSRecord type class:  self classIN);
		yourself
]

{ #category : #'instance creation' }
DNSMessage class >> ptrRecordsFor: hostName [
	^ self new
		recursionDesired: true;
		addQuestion: (DNSQuery name: hostName type: PTRRecord type class: self classIN);
		yourself
]

{ #category : #'instance creation' }
DNSMessage class >> readFrom: aStream [
	^ self basicNew readFrom: aStream
]

{ #category : #'instance creation' }
DNSMessage class >> reverseLookup: address [
	| ptrName |
	ptrName := address inject: 'IN-ADDR.ARPA' into: [ :cur :new | new asString , '.' , cur ].
	^ self new
		recursionDesired: true;
		addQuestion: (DNSQuery name: ptrName type: PTRRecord type class: self classIN);
		yourself
]

{ #category : #'instance creation' }
DNSMessage class >> servicesFor: domain [
	^ self new
		recursionDesired: true;
		addQuestion: (DNSQuery name: domain type: SRVRecord type class: self classIN);
		yourself
]

{ #category : #'instance creation' }
DNSMessage class >> txtRecordsFor: hostName [
	^ self new
		recursionDesired: true;
		addQuestion: (DNSQuery name: hostName type: TXTRecord type class: self classIN);
		yourself
]

{ #category : #accessing }
DNSMessage >> addAnswer: aDNSRecord [
	answers := answers copyWith: aDNSRecord.
	^ aDNSRecord
]

{ #category : #accessing }
DNSMessage >> addQuestion: aDNSQuery [
	questions := questions copyWith: aDNSQuery.
	^ aDNSQuery
]

{ #category : #accessing }
DNSMessage >> answers [
	^ answers
]

{ #category : #'reading/writing' }
DNSMessage >> asByteArray [
	| stream |
	stream := ByteArray new writeStream.
	self writeOn: stream.
	^ stream contents
]

{ #category : #accessing }
DNSMessage >> authoritativeAnswer [
	^ (flags bitAnd: 2r0000010000000000) ~= 0
]

{ #category : #accessing }
DNSMessage >> authoritativeAnswer: aBoolean [
	flags := aBoolean ifTrue: [flags bitOr: 2r10000000000] ifFalse: [flags bitClear: 2r10000000000]
]

{ #category : #accessing }
DNSMessage >> beInverseQuery [
	self opcode: 1
]

{ #category : #accessing }
DNSMessage >> checkResponseCodeDo: block [
	"Check the response code. 
	In case it is non-zero, evaluate block with the code and an error string as arguments."
	
	| errorStr |
	self responseCode = 0
		ifTrue: [ ^ self ].
	errorStr := self responseCode > 10
		ifTrue: [ 'Undefined response code: ' , self responseCode printString ]
		ifFalse:
			[ #('Format error' 'Server failure' 'Non existent domain' 'Not implemented' 'Query refused' 'Name exists' 'RRset exists' 'RRset does not exist' 'Not authoritative for zone' 'Zone of record different from zone section')
				at: self responseCode ].
	block value: self responseCode value: errorStr
]

{ #category : #accessing }
DNSMessage >> id [
	^ id
]

{ #category : #accessing }
DNSMessage >> id: int16 [
	id := int16
]

{ #category : #initialization }
DNSMessage >> initialize [
	self id: (0 to: 16rFFFF) atRandom.
	flags := 0.
	questions := answers := authority := additional := #()
]

{ #category : #testing }
DNSMessage >> isInverseQuery [
	^ self opcode = 1
]

{ #category : #testing }
DNSMessage >> isQuery [
	^ self isResponse not
]

{ #category : #testing }
DNSMessage >> isResponse [
	^ (flags bitAnd: 16r8000) ~= 0
]

{ #category : #testing }
DNSMessage >> isStandardQuery [
	^ self opcode = 0
]

{ #category : #accessing }
DNSMessage >> opcode [
	^ (flags bitShift: -11) bitAnd: 2r01111
]

{ #category : #accessing }
DNSMessage >> opcode: anInteger [
	^ flags := (flags bitClear: 2r01111) + anInteger
]

{ #category : #accessing }
DNSMessage >> questions [
	^ questions
]

{ #category : #'reading/writing' }
DNSMessage >> readFrom: aStream [
	| questionsCount answersCount authorityCount additionalCount |
	aStream position = 0 ifFalse: [self error: 'the stream should be at position 0 in order to correctly unpack domain names'].
	id := aStream nextNumber: 2.
	flags := aStream nextNumber: 2.
	questionsCount := aStream nextNumber: 2.
	answersCount := aStream nextNumber: 2.
	authorityCount := aStream nextNumber: 2.
	additionalCount := aStream nextNumber: 2.
	questions := (1 to: questionsCount) collect: [:each | DNSQuery readFrom: aStream].
	answers := (1 to: answersCount) collect: [:each | DNSRecord readFrom: aStream].
	authority := (1 to: authorityCount) collect: [:each | DNSRecord readFrom: aStream].
	additional := (1 to: additionalCount) collect: [:each | DNSRecord readFrom: aStream]
]

{ #category : #accessing }
DNSMessage >> recursionAvaliable: aBoolean [
	flags := aBoolean ifTrue: [flags bitOr: 2r10000000] ifFalse: [flags bitClear: 2r10000000]
]

{ #category : #accessing }
DNSMessage >> recursionDesired: aBoolean [
	flags := aBoolean ifTrue: [flags bitOr: 2r100000000] ifFalse: [flags bitClear: 2r100000000]
]

{ #category : #accessing }
DNSMessage >> response: aBoolean [
	flags := aBoolean ifTrue: [flags bitOr: 2r1000000000000000] ifFalse: [flags bitClear: 2r1000000000000000]
]

{ #category : #accessing }
DNSMessage >> responseCode [
	^ flags bitAnd: 2r1111
]

{ #category : #testing }
DNSMessage >> timedOut [
	self answers isEmpty
		ifTrue: [
			^ authority isEmpty
				ifTrue: [true]
				ifFalse: [ authority anySatisfy: [:any | any timedOut] ]
		].
	^ self answers anySatisfy: [:any | any timedOut]
]

{ #category : #accessing }
DNSMessage >> truncated [
	^ (flags bitAnd: 2r1000000000) ~= 0
]

{ #category : #accessing }
DNSMessage >> truncated: aBoolean [
	flags := aBoolean ifTrue: [flags bitOr: 2r1000000000] ifFalse: [flags bitClear: 2r1000000000]
]

{ #category : #'reading/writing' }
DNSMessage >> writeHeaderOn: aStream [
	aStream
		nextNumber: 2 put: id;
		nextNumber: 2 put: flags;
		nextNumber: 2 put: questions size;
		nextNumber: 2 put: answers size;
		nextNumber: 2 put: authority size;
		nextNumber: 2 put: additional size
]

{ #category : #'reading/writing' }
DNSMessage >> writeOn: aStream [
	self writeHeaderOn: aStream.
	questions do: [:each | each writeOn: aStream].
	answers do: [:each | each writeOn: aStream].
	authority do: [:each | each writeOn: aStream].
	additional do: [:each | each writeOn: aStream]
]
