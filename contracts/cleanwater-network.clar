(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-member (err u101))
(define-constant err-already-member (err u102))
(define-constant err-insufficient-funds (err u103))
(define-constant err-station-not-found (err u104))
(define-constant err-project-not-found (err u105))
(define-constant err-invalid-quality (err u106))
(define-constant err-already-voted (err u107))
(define-constant err-voting-closed (err u108))
(define-constant err-invalid-amount (err u109))
(define-constant err-project-not-active (err u110))
(define-constant err-unauthorized (err u111))

(define-data-var next-member-id uint u1)
(define-data-var next-station-id uint u1)
(define-data-var next-project-id uint u1)
(define-data-var next-proposal-id uint u1)
(define-data-var network-treasury uint u0)
(define-data-var total-members uint u0)
(define-data-var membership-fee uint u25000)
(define-data-var min-funding-amount uint u100000)
(define-data-var voting-duration uint u720)

(define-map network-members principal {
    id: uint,
    name: (string-ascii 256),
    location: (string-ascii 128),
    role: (string-ascii 32),
    reputation: uint,
    join-block: uint,
    active: bool,
    stations-managed: uint,
    projects-completed: uint
})

(define-map water-stations uint {
    id: uint,
    name: (string-ascii 256),
    location: (string-ascii 128),
    manager: principal,
    water-quality: uint,
    last-tested: uint,
    capacity-liters: uint,
    operational: bool,
    installation-cost: uint,
    maintenance-fund: uint
})

(define-map quality-reports uint {
    station-id: uint,
    reporter: principal,
    ph-level: uint,
    tds-ppm: uint,
    bacteria-count: uint,
    safety-rating: uint,
    test-timestamp: uint,
    verified: bool
})

(define-map purification-projects uint {
    id: uint,
    title: (string-ascii 256),
    description: (string-ascii 512),
    location: (string-ascii 128),
    project-type: (string-ascii 64),
    target-capacity: uint,
    estimated-cost: uint,
    current-funding: uint,
    project-manager: principal,
    status: (string-ascii 32),
    created-block: uint,
    deadline-block: uint,
    beneficiaries: uint,
    completed: bool
})

(define-map funding-proposals uint {
    id: uint,
    project-id: uint,
    title: (string-ascii 256),
    description: (string-ascii 512),
    amount-requested: uint,
    proposer: principal,
    created-block: uint,
    voting-end-block: uint,
    yes-votes: uint,
    no-votes: uint,
    total-voters: uint,
    executed: bool,
    approved: bool
})

(define-map member-votes {member: principal, proposal-id: uint} bool)

(define-map maintenance-requests uint {
    station-id: uint,
    requester: principal,
    issue-description: (string-ascii 512),
    urgency-level: uint,
    estimated-cost: uint,
    status: (string-ascii 32),
    created-block: uint,
    assigned-to: (optional principal)
})

(define-data-var next-report-id uint u1)
(define-data-var next-maintenance-id uint u1)

(define-public (join-network (name (string-ascii 256)) (location (string-ascii 128)) (role (string-ascii 32)))
    (let ((member-id (var-get next-member-id)))
        (asserts! (is-none (map-get? network-members tx-sender)) err-already-member)
        (try! (stx-transfer? (var-get membership-fee) tx-sender (as-contract tx-sender)))
        (map-set network-members tx-sender {
            id: member-id,
            name: name,
            location: location,
            role: role,
            reputation: u100,
            join-block: stacks-block-height,
            active: true,
            stations-managed: u0,
            projects-completed: u0
        })
        (var-set next-member-id (+ member-id u1))
        (var-set total-members (+ (var-get total-members) u1))
        (var-set network-treasury (+ (var-get network-treasury) (var-get membership-fee)))
        (ok member-id)
    )
)

(define-public (install-water-station 
    (name (string-ascii 256))
    (location (string-ascii 128))
    (capacity-liters uint)
    (installation-cost uint)
)
    (let ((station-id (var-get next-station-id)))
        (asserts! (is-some (map-get? network-members tx-sender)) err-not-member)
        (asserts! (> capacity-liters u0) err-invalid-amount)
        (map-set water-stations station-id {
            id: station-id,
            name: name,
            location: location,
            manager: tx-sender,
            water-quality: u0,
            last-tested: u0,
            capacity-liters: capacity-liters,
            operational: true,
            installation-cost: installation-cost,
            maintenance-fund: u0
        })
        (var-set next-station-id (+ station-id u1))
        (let ((member (unwrap! (map-get? network-members tx-sender) err-not-member)))
            (map-set network-members tx-sender (merge member {
                stations-managed: (+ (get stations-managed member) u1)
            }))
        )
        (ok station-id)
    )
)

(define-public (submit-quality-report 
    (station-id uint)
    (ph-level uint)
    (tds-ppm uint)
    (bacteria-count uint)
    (safety-rating uint)
)
    (let ((report-id (var-get next-report-id))
          (station (unwrap! (map-get? water-stations station-id) err-station-not-found)))
        (asserts! (is-some (map-get? network-members tx-sender)) err-not-member)
        (asserts! (<= safety-rating u10) err-invalid-quality)
        (map-set quality-reports report-id {
            station-id: station-id,
            reporter: tx-sender,
            ph-level: ph-level,
            tds-ppm: tds-ppm,
            bacteria-count: bacteria-count,
            safety-rating: safety-rating,
            test-timestamp: stacks-block-height,
            verified: false
        })
        (map-set water-stations station-id (merge station {
            water-quality: safety-rating,
            last-tested: stacks-block-height
        }))
        (var-set next-report-id (+ report-id u1))
        (ok report-id)
    )
)

(define-public (create-purification-project 
    (title (string-ascii 256))
    (description (string-ascii 512))
    (location (string-ascii 128))
    (project-type (string-ascii 64))
    (target-capacity uint)
    (estimated-cost uint)
    (deadline-blocks uint)
    (beneficiaries uint)
)
    (let ((project-id (var-get next-project-id)))
        (asserts! (is-some (map-get? network-members tx-sender)) err-not-member)
        (asserts! (> estimated-cost u0) err-invalid-amount)
        (map-set purification-projects project-id {
            id: project-id,
            title: title,
            description: description,
            location: location,
            project-type: project-type,
            target-capacity: target-capacity,
            estimated-cost: estimated-cost,
            current-funding: u0,
            project-manager: tx-sender,
            status: "planning",
            created-block: stacks-block-height,
            deadline-block: (+ stacks-block-height deadline-blocks),
            beneficiaries: beneficiaries,
            completed: false
        })
        (var-set next-project-id (+ project-id u1))
        (ok project-id)
    )
)

(define-public (create-funding-proposal 
    (project-id uint)
    (title (string-ascii 256))
    (description (string-ascii 512))
    (amount-requested uint)
)
    (let ((proposal-id (var-get next-proposal-id))
          (project (unwrap! (map-get? purification-projects project-id) err-project-not-found)))
        (asserts! (is-some (map-get? network-members tx-sender)) err-not-member)
        (asserts! (>= amount-requested (var-get min-funding-amount)) err-invalid-amount)
        (map-set funding-proposals proposal-id {
            id: proposal-id,
            project-id: project-id,
            title: title,
            description: description,
            amount-requested: amount-requested,
            proposer: tx-sender,
            created-block: stacks-block-height,
            voting-end-block: (+ stacks-block-height (var-get voting-duration)),
            yes-votes: u0,
            no-votes: u0,
            total-voters: u0,
            executed: false,
            approved: false
        })
        (var-set next-proposal-id (+ proposal-id u1))
        (ok proposal-id)
    )
)

(define-public (vote-on-funding (proposal-id uint) (vote-for bool))
    (let ((proposal (unwrap! (map-get? funding-proposals proposal-id) err-project-not-found))
          (member (unwrap! (map-get? network-members tx-sender) err-not-member)))
        (asserts! (< stacks-block-height (get voting-end-block proposal)) err-voting-closed)
        (asserts! (is-none (map-get? member-votes {member: tx-sender, proposal-id: proposal-id})) err-already-voted)
        (map-set member-votes {member: tx-sender, proposal-id: proposal-id} vote-for)
        (if vote-for
            (map-set funding-proposals proposal-id (merge proposal {
                yes-votes: (+ (get yes-votes proposal) u1),
                total-voters: (+ (get total-voters proposal) u1)
            }))
            (map-set funding-proposals proposal-id (merge proposal {
                no-votes: (+ (get no-votes proposal) u1),
                total-voters: (+ (get total-voters proposal) u1)
            }))
        )
        (ok vote-for)
    )
)

(define-public (execute-funding-proposal (proposal-id uint))
    (let ((proposal (unwrap! (map-get? funding-proposals proposal-id) err-project-not-found))
          (project-id (get project-id proposal))
          (project (unwrap! (map-get? purification-projects project-id) err-project-not-found)))
        (asserts! (>= stacks-block-height (get voting-end-block proposal)) err-voting-closed)
        (asserts! (not (get executed proposal)) err-already-voted)
        (let ((approved (> (get yes-votes proposal) (get no-votes proposal))))
            (map-set funding-proposals proposal-id (merge proposal {
                executed: true,
                approved: approved
            }))
            (if approved
                (begin
                    (map-set purification-projects project-id (merge project {
                        current-funding: (+ (get current-funding project) (get amount-requested proposal)),
                        status: "funded"
                    }))
                    (var-set network-treasury (- (var-get network-treasury) (get amount-requested proposal)))
                    (try! (as-contract (stx-transfer? (get amount-requested proposal) tx-sender (get project-manager project))))
                    (ok true)
                )
                (ok false)
            )
        )
    )
)

(define-public (contribute-to-treasury (amount uint))
    (begin
        (asserts! (is-some (map-get? network-members tx-sender)) err-not-member)
        (asserts! (> amount u0) err-invalid-amount)
        (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
        (var-set network-treasury (+ (var-get network-treasury) amount))
        (let ((member (unwrap! (map-get? network-members tx-sender) err-not-member)))
            (map-set network-members tx-sender (merge member {
                reputation: (+ (get reputation member) (/ amount u1000))
            }))
        )
        (ok amount)
    )
)

(define-public (request-maintenance 
    (station-id uint)
    (issue-description (string-ascii 512))
    (urgency-level uint)
    (estimated-cost uint)
)
    (let ((maintenance-id (var-get next-maintenance-id))
          (station (unwrap! (map-get? water-stations station-id) err-station-not-found)))
        (asserts! (is-some (map-get? network-members tx-sender)) err-not-member)
        (asserts! (<= urgency-level u5) err-invalid-quality)
        (map-set maintenance-requests maintenance-id {
            station-id: station-id,
            requester: tx-sender,
            issue-description: issue-description,
            urgency-level: urgency-level,
            estimated-cost: estimated-cost,
            status: "pending",
            created-block: stacks-block-height,
            assigned-to: none
        })
        (var-set next-maintenance-id (+ maintenance-id u1))
        (ok maintenance-id)
    )
)

(define-public (complete-project (project-id uint))
    (let ((project (unwrap! (map-get? purification-projects project-id) err-project-not-found)))
        (asserts! (is-eq tx-sender (get project-manager project)) err-unauthorized)
        (asserts! (not (get completed project)) err-project-not-active)
        (map-set purification-projects project-id (merge project {
            completed: true,
            status: "completed"
        }))
        (let ((member (unwrap! (map-get? network-members tx-sender) err-not-member)))
            (map-set network-members tx-sender (merge member {
                projects-completed: (+ (get projects-completed member) u1),
                reputation: (+ (get reputation member) u100)
            }))
        )
        (ok true)
    )
)

(define-public (verify-quality-report (report-id uint))
    (let ((report (unwrap! (map-get? quality-reports report-id) err-project-not-found)))
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (map-set quality-reports report-id (merge report {verified: true}))
        (ok true)
    )
)

(define-public (deactivate-member (member-principal principal))
    (let ((member (unwrap! (map-get? network-members member-principal) err-not-member)))
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (map-set network-members member-principal (merge member {active: false}))
        (ok true)
    )
)

(define-read-only (get-member (member-principal principal))
    (map-get? network-members member-principal)
)

(define-read-only (get-water-station (station-id uint))
    (map-get? water-stations station-id)
)

(define-read-only (get-project (project-id uint))
    (map-get? purification-projects project-id)
)

(define-read-only (get-proposal (proposal-id uint))
    (map-get? funding-proposals proposal-id)
)

(define-read-only (get-quality-report (report-id uint))
    (map-get? quality-reports report-id)
)

(define-read-only (get-maintenance-request (maintenance-id uint))
    (map-get? maintenance-requests maintenance-id)
)

(define-read-only (get-network-stats)
    (ok {
        treasury: (var-get network-treasury),
        total-members: (var-get total-members),
        membership-fee: (var-get membership-fee),
        total-stations: (- (var-get next-station-id) u1),
        total-projects: (- (var-get next-project-id) u1),
        active-proposals: (- (var-get next-proposal-id) u1),
        quality-reports: (- (var-get next-report-id) u1),
        maintenance-requests: (- (var-get next-maintenance-id) u1)
    })
)

(define-read-only (get-member-vote (member-principal principal) (proposal-id uint))
    (map-get? member-votes {member: member-principal, proposal-id: proposal-id})
)

(define-read-only (get-station-quality (station-id uint))
    (match (map-get? water-stations station-id)
        station (ok (get water-quality station))
        err-station-not-found
    )
)