;; --------------------------------------------------
;; Contract: stacks-access
;; Description: Subscription-based paywall using STX
;; Author: [Your Name]
;; License: MIT
;; --------------------------------------------------

(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_INVALID_PAYMENT (err u101))
(define-constant ERR_ALREADY_SUBSCRIBED (err u102))
(define-constant ERR_INSUFFICIENT_FUNDS (err u103))

;; === Admin Variables ===
(define-data-var contract-owner principal tx-sender)
(define-data-var subscription-price uint u5000000) ;; Default: 5 STX
(define-data-var subscription-duration uint u4320) ;; ~30 days (in blocks)
(define-data-var collected-funds uint u0)

;; === Subscriptions Map ===
(define-map subscriptions
    {subscriber: principal}    ;; key
    {expires: uint}           ;; value
)

;; === Admin-Only: Set subscription price ===
(define-public (set-subscription-price (price uint))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_UNAUTHORIZED)
        (ok (var-set subscription-price price))))

;; === Admin-Only: Set subscription duration ===
(define-public (set-subscription-duration (duration uint))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_UNAUTHORIZED)
        (ok (var-set subscription-duration duration))))

;; === Admin-Only: Withdraw collected funds ===
(define-public (withdraw-funds (amount uint) (recipient principal))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_UNAUTHORIZED)
        (asserts! (<= amount (var-get collected-funds)) ERR_INSUFFICIENT_FUNDS)
        (var-set collected-funds (- (var-get collected-funds) amount))
        (stx-transfer? amount (as-contract tx-sender) recipient)))

;; === User: Subscribe with STX payment ===
(define-public (subscribe)
    (let 
        ((price (var-get subscription-price))
         (current-block stacks-block-height)
         (duration (var-get subscription-duration))
         (new-expiry (+ current-block duration)))
        (begin
            ;; Transfer STX from user to contract
            (try! (stx-transfer? price tx-sender (as-contract tx-sender)))
            ;; Update subscription
            (map-set subscriptions {subscriber: tx-sender} {expires: new-expiry})
            ;; Update collected funds
            (var-set collected-funds (+ (var-get collected-funds) price))
            (ok new-expiry))))

;; === Read: Check if user has valid subscription ===
(define-read-only (check-access (user principal))
    (let ((user-data (map-get? subscriptions {subscriber: user})))
        (if (is-some user-data)
            (ok (>= (get expires (unwrap-panic user-data)) stacks-block-height))
            (ok false))))

;; === Admin-Only: View collected funds ===
(define-read-only (get-collected-funds)
    (ok (var-get collected-funds)))

;; === Read: View subscription expiry ===
(define-read-only (get-subscription-expiry (user principal))
    (let ((user-data (map-get? subscriptions {subscriber: user})))
        (if (is-some user-data)
            (ok (get expires (unwrap-panic user-data)))
            (ok u0))))