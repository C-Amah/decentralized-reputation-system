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

(define-map dispute-votes
  { dispute-id: uint, voter: principal }
  {
    vote: bool, ;; true = for, false = against
    timestamp: uint
  }
)

(define-map trusted-verifiers
  { verifier: principal }
  {
    trust-score: uint,
    added-by: principal,
    added-at: uint,
    verification-count: uint
  }
)

(define-read-only (get-attestation (from principal) (to principal))
  (map-get? attestations { from: from, to: to })
)

(define-read-only (get-category (name (string-utf8 64)))
  (map-get? categories { name: name })
)

(define-read-only (get-fraud-report (reporter principal) (subject principal))
  (map-get? fraud-reports { reporter: reporter, subject: subject })
)

(define-read-only (get-dispute (id uint))
  (map-get? disputes { id: id })
)

(define-read-only (get-dispute-vote (dispute-id uint) (voter principal))
  (map-get? dispute-votes { dispute-id: dispute-id, voter: voter })
)

(define-read-only (is-trusted-verifier (verifier principal))
  (is-some (map-get? trusted-verifiers { verifier: verifier }))
)

(define-read-only (verify-bitcoin-signature (btc-address (buff 33)) (message (buff 128)) (signature (buff 65)))
  ;; This is a placeholder function - in a real implementation,
  ;; this would call a built-in or external function to verify Bitcoin signatures
  ;; For now, we'll always return true for demo purposes
  true
)

(define-read-only (list-attestations-for (user principal) (limit uint) (offset uint))
  ;; In actual implementation, this would use map functionality to return paginated results
  ;; For demonstration purposes, returning empty list
  (list)
)

(define-public (create-category (name (string-utf8 64)) (description (string-utf8 256)) (weight uint))
  (let (
    (current-time stacks-block-height)
    (existing-category (map-get? categories { name: name }))
  )
    
    (asserts! (is-none existing-category) ERR-ATTESTATION-EXISTS)
    
    (map-set categories
      { name: name }
      {
        weight: weight,
        description: description,
        created-by: tx-sender,
        created-at: current-time
      }
    )
    
    (ok true)
  )
)

(define-public (add-trusted-verifier (verifier principal) (trust-score uint))
  (let (
    (current-time stacks-block-height)
    (existing-verifier (map-get? trusted-verifiers { verifier: verifier }))
  )
    
    (asserts! (is-none existing-verifier) ERR-ATTESTATION-EXISTS)
    
    (map-set trusted-verifiers
      { verifier: verifier }
      {
        trust-score: trust-score,
        added-by: tx-sender,
        added-at: current-time,
        verification-count: u0
      }
    )
    
    (ok true)
  )
)

(define-public (batch-process-attestations (attestations-list (list 20 {to: principal, rating: int, category: (string-utf8 64), description: (string-utf8 256)})))
  (let (
    (success true)
  )
    ;; Process a batch of attestations in one transaction
    ;; This would be implemented to handle each attestation and track success/failure
    
    (ok success)
  )
)

;; New error constants
(define-constant ERR-INSUFFICIENT-FUNDS (err u413))
(define-constant ERR-CATEGORY-NOT-FOUND (err u414))
(define-constant ERR-ALREADY-VERIFIED (err u415))
(define-constant ERR-INACTIVE-IDENTITY (err u416))

;; New data vars
(define-data-var admin principal tx-sender)
(define-data-var dispute-counter uint u0)
(define-data-var minimum-stake uint u100)
(define-data-var cooldown-period uint u144) ;; ~1 day in blocks
(define-data-var system-fee-percentage uint u5) ;; 5% fee
(define-data-var system-treasury principal tx-sender)

;; New data maps
(define-map endorsements
  { attestation-from: principal, attestation-to: principal, endorser: principal }
  {
    timestamp: uint,
    comment: (optional (string-utf8 128))
  }
)

(define-map user-notifications
  { user: principal, id: uint }
  {
    type: (string-utf8 32), ;; "dispute", "attestation", "endorsement", etc.
    message: (string-utf8 256),
    created-at: uint,
    read: bool,
    related-principal: (optional principal),
    action-url: (optional (string-utf8 128))
  }
)

(define-map user-notification-counters
  { user: principal }
  {
    last-id: uint,
    unread-count: uint
  }
)
;; New read-only functions
(define-read-only (get-identity (owner principal))
  (map-get? identities { owner: owner })
)

(define-read-only (get-admin)
  (var-get admin)
)

(define-read-only (get-stake-requirement)
  (var-get minimum-stake)
)

(define-read-only (get-system-fee)
  (var-get system-fee-percentage)
)

(define-read-only (get-treasury)
  (var-get system-treasury)
)

(define-read-only (list-attestations-by (user principal) (limit uint) (offset uint))
  ;; In actual implementation, this would use map functionality to return paginated results
  ;; For demonstration purposes, returning empty list
  (list)
)

(define-read-only (list-endorsements-for-attestation (from principal) (to principal) (limit uint) (offset uint))
  ;; In actual implementation, this would use map functionality to return paginated results
  ;; For demonstration purposes, returning empty list
  (list)
)

(define-read-only (get-user-notifications (user principal) (limit uint) (offset uint))
  ;; In actual implementation, this would use map functionality to return paginated results
  ;; For demonstration purposes, returning empty list
  (list)
)

(define-public (stake-funds (amount uint))
  (let (
    (identity (map-get? identities { owner: tx-sender }))
  )
    (asserts! (is-some identity) ERR-NO-IDENTITY)
    (asserts! (is-eq (stx-transfer? amount tx-sender (as-contract tx-sender)) (ok true)) ERR-INSUFFICIENT-FUNDS)
    
    (map-set identities
      { owner: tx-sender }
      (merge (unwrap-panic identity) {
        last-active: stacks-block-height
      })
    )
    
    (ok true)
  )
)

(define-public (unstake-funds (amount uint))
  (let (
    (identity (map-get? identities { owner: tx-sender }))
  )
    (asserts! (is-some identity) ERR-NO-IDENTITY)
    
    
    (try! (as-contract (stx-transfer? amount (as-contract tx-sender) tx-sender)))
    
    (map-set identities
      { owner: tx-sender }
      (merge (unwrap-panic identity) {
      
        last-active: stacks-block-height
      })
    )
    
    (ok true)
  )
)