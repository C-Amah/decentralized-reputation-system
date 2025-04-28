;; Define constants
(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-constant ERR-INVALID-SIGNATURE (err u402))
(define-constant ERR-ATTESTATION-EXISTS (err u403))
(define-constant ERR-NO-ATTESTATION (err u404))
(define-constant ERR-INVALID-RATING (err u405))
(define-constant ERR-SELF-ATTESTATION (err u406))
(define-constant ERR-FRAUD-DETECTED (err u407))
(define-constant ERR-NO-IDENTITY (err u408))
(define-constant ERR-COOLDOWN-PERIOD (err u409))
(define-constant ERR-DISPUTE-EXISTS (err u410))
(define-constant ERR-NO-DISPUTE (err u411))
(define-constant ERR-NOT-DISPUTE-PARTICIPANT (err u412))

;; Define data maps
(define-map identities
  { owner: principal }
  {
    btc-address: (optional (buff 33)),
    created-at: uint,
    total-score: int,
    attestation-count: uint,
    verification-level: uint,
    last-active: uint,
    dispute-count: uint
  }
)

(define-map attestations
  { from: principal, to: principal }
  {
    rating: int,
    timestamp: uint,
    category: (string-utf8 64),
    description: (string-utf8 256),
    signature-verified: bool,
    transaction-hash: (optional (buff 32)),
    revoked: bool
  }
)

(define-map categories
  { name: (string-utf8 64) }
  {
    weight: uint,
    description: (string-utf8 256),
    created-by: principal,
    created-at: uint
  }
)

(define-map fraud-reports
  { reporter: principal, subject: principal }
  {
    reason: (string-utf8 256),
    evidence: (string-utf8 512),
    timestamp: uint,
    status: (string-utf8 20), ;; "pending", "approved", "rejected"
    votes-for: uint,
    votes-against: uint
  }
)

(define-map disputes
  { id: uint }
  {
    creator: principal,
    defendant: principal,
    attestation-from: principal,
    attestation-to: principal,
    reason: (string-utf8 256),
    evidence: (string-utf8 512),
    created-at: uint,
    status: (string-utf8 20), ;; "pending", "resolved", "dismissed"
    resolution: (optional (string-utf8 256))
  }
)



