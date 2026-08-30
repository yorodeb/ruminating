QUANTUMMAIL — PROJECT CONTEXT & EXECUTION PLAN
==============================================

CURRENT SITUATION
-----------------

Project: QuantumMail

Goal:
Turn QuantumMail from a working Phase-5 CLI prototype into a convincing,
full-fledged secure email client for a hackathon.

Deadline: August 25, 2026
Today: August 22, 2026

Priority:
1. Working application
2. Reliable real-email functionality
3. Good UX
4. TUI/GUI polish
5. Security/demo clarity

The user prefers a TUI, but recognizes that a GUI sells better at a hackathon.
A GUI should therefore be considered if it can be built without jeopardizing
the working application.

Ideal end result:

Open QuantumMail
    ->
Configure Gmail once (email + App Password)
    ->
Application handles SMTP/IMAP configuration
    ->
User can send/receive encrypted email from QuantumMail


USER / DEVELOPMENT PREFERENCES
------------------------------

The user is an engineering student interested in:

- systems programming
- low-level development
- understanding how things work
- building systems rather than copy-pasting
- Go
- networking
- architecture

The user prefers learning through implementation and decomposition rather
than blindly following generated code.

For this project, however, the deadline is very close.

Therefore:

SHIP A RELIABLE HACKATHON APPLICATION FIRST.

Then improve architecture/polish where time permits.

Do not unnecessarily turn this into a huge production-grade email client.


PROJECT ARCHITECTURE
====================

QuantumMail was deliberately developed in phases.


PHASE 1 — CRYPTOGRAPHIC MESSAGE PROTECTION
-------------------------------------------

Implemented:

- ML-KEM-768
- AES-256-GCM
- encrypted message flow

Core responsibility:

    Encrypt/decrypt messages.

The cryptographic layer is isolated from transport.

Important architectural principle:

    Transport must never decrypt messages.


PHASE 2 — IDENTITY PERSISTENCE + SERIALIZATION
-----------------------------------------------

Implemented:

- persistent QuantumMail identities
- identity loading/saving
- encrypted-message serialization/deserialization
- public identity export

Identity contains the user's cryptographic key material.

Private key material must never be printed/shared.

Public identity can be exported and shared with senders.

Public identity JSON is approximately:

{
  "version": 1,
  "public_key": [...]
}

Added in:

    internal/identity/persistence.go

    type PublicKey = mlkem.EncapsulationKey768

and:

    func ParsePublicKey(data []byte) (*PublicKey, error)

This allows the CLI to load another user's exported public identity.


PHASE 3 — LOCAL FILESYSTEM TRANSPORT
-------------------------------------

Implemented deterministic local transport.

Purpose:

- development
- testing
- demos without Internet/email configuration

The local transport stores opaque serialized encrypted payloads.

Important:

    The transport does not decrypt.

This allowed Alice -> Bob testing without real email.


PHASE 4 — REAL EMAIL TRANSPORT
------------------------------

Implemented real email transport using:

- SMTP for sending
- IMAP for retrieving

Package:

    internal/emailtransport/

Important files:

    internal/emailtransport/config.go
    internal/emailtransport/smtp.go
    internal/emailtransport/imap.go
    internal/emailtransport/message.go
    internal/emailtransport/live_integration_test.go

Environment variables:

    QUANTUMMAIL_SMTP_HOST
    QUANTUMMAIL_SMTP_PORT
    QUANTUMMAIL_SMTP_USERNAME
    QUANTUMMAIL_SMTP_PASSWORD
    QUANTUMMAIL_SMTP_USE_STARTTLS
    QUANTUMMAIL_SMTP_USE_IMPLICIT_TLS

    QUANTUMMAIL_IMAP_HOST
    QUANTUMMAIL_IMAP_PORT
    QUANTUMMAIL_IMAP_USERNAME
    QUANTUMMAIL_IMAP_PASSWORD
    QUANTUMMAIL_IMAP_USE_STARTTLS
    QUANTUMMAIL_IMAP_USE_IMPLICIT_TLS
    QUANTUMMAIL_IMAP_MAILBOX

    QUANTUMMAIL_SENDER_EMAIL


LIVE EMAIL TEST
---------------

The live integration test is:

    TestLiveSMTPIMAPRoundTrip

Correct command:

    go test ./internal/emailtransport -run TestLiveSMTPIMAPRoundTrip -v

It passed:

    === RUN   TestLiveSMTPIMAPRoundTrip
    --- PASS: TestLiveSMTPIMAPRoundTrip (8.85s)
    PASS

Therefore:

    REAL GMAIL SMTP + IMAP SENDING/RETRIEVAL HAS BEEN PROVEN TO WORK.


GMAIL TESTING HISTORY
---------------------

Initially Gmail App Passwords were unavailable because 2-Step Verification
was not enabled.

The user then:

1. Enabled 2-Step Verification.
2. App Passwords became available.
3. Created an App Password.
4. Configured QuantumMail.
5. Successfully ran the live SMTP/IMAP integration test.

The user decided:

    Do not bother setting up a second Gmail account.

Use one Gmail account for the demo/testing.

This works because the QuantumMail cryptographic identity is separate from
the email provider identity.


REAL GMAIL CLI TEST
-------------------

QuantumMail successfully sent an encrypted message through Gmail.

Example:

    Select option: 1

    ── Send Encrypted Message ──
      Recipient public identity file path: demo_data/bob.public.json
      Recipient ID (email or local name): netflixjr622@gmail.com
      Enter message (press Enter twice or Ctrl+D to send):
      > Hello, World!
      > Alice from QuantumLand via Gmail!
      >
      Transport:
        1. Local filesystem (default, no config needed)
        2. Real email (requires QUANTUMMAIL_* environment variables)
      Choose transport [1/2, default 1]: 2
      [OK] Message delivered. ID: 5b44324a5eb5c9d4cfe967d47b2d9d32

Then retrieval:

    Select option: 2

    ── Check Inbox ──
      Your recipient ID (email or local name): netflixjr622@gmail.com
      Transport:
        1. Local filesystem (default, no config needed)
        2. Real email (requires QUANTUMMAIL_* environment variables)
      Choose transport [1/2, default 1]: 2
      Retrieving messages...
      Found 1 message(s), 0 error(s)

      ── Message 1 (ID: 5b44324a5eb5c9d4cfe967d47b2d9d32) ──
    Hello, World!
    Alice from QuantumLand via Gmail!

Therefore:

    REAL GMAIL ROUND-TRIP IS WORKING CORRECTLY.


IMPORTANT BUG THAT WAS FOUND
----------------------------

While checking Gmail inbox, an old QuantumMail message existed that had been
encrypted using a different cryptographic identity.

Result:

    Found 1 message(s), 1 error(s)

    Message ... could not be decrypted:
    decrypt: securemessage: decryption failed:
    authentication tag verification failed

This was NOT a failure of the newly sent message.

The old incompatible message was deleted.

After deleting it:

    Found 1 message(s), 0 error(s)

    ── Message 1 ...
    Hello, World!
    Alice from QuantumLand via Gmail!

Conclusion:

    Real Gmail round-trip works correctly.

This did reveal a future UX improvement:

The application currently reports undecryptable QuantumMail messages as
warnings.

Later, distinguish:

- corrupted message
- message encrypted for another identity
- unsupported message version
- malformed payload

This is useful but NOT required before the deadline.


PHASE 5 — INTERACTIVE CLI APPLICATION
--------------------------------------

Phase 5 was implemented and committed.

Commit:

    Phase-5: Completed

The user committed and pushed Phase 5.

New structure:

    cmd/quantummail/

    internal/cli/

Files:

    cmd/quantummail/main.go

    internal/cli/app.go
    internal/cli/app_test.go
    internal/cli/flows.go
    internal/cli/transports.go
    internal/cli/ui.go


CURRENT CLI
-----------

Menu:

    ╔═══════════════════════════════════════╗
    ║           Q U A N T U M M A I L       ║
    ║   Post-Quantum Encrypted Messaging     ║
    ╚═══════════════════════════════════════╝

      1. Send encrypted message
      2. Check inbox
      3. Show my public identity
      4. Export public identity to file
      5. Exit


IDENTITY STORAGE
----------------

Identity location:

    ~/.quantummail/identity.json

Local mailbox:

    ~/.quantummail/local_mailboxes

First run:

- create ~/.quantummail
- generate identity
- persist identity

Subsequent runs:

- load existing identity
- do NOT silently regenerate identity

Corrupted identity files cause an error instead of silently replacing the
identity.

This is intentional.


CURRENT SEND FLOW
-----------------

User:

1. Selects "Send encrypted message"
2. Provides recipient public identity file
3. Provides recipient email/local ID
4. Enters plaintext
5. Chooses transport
6. Message is encrypted
7. Message is serialized
8. Message is sent through selected transport

Transport receives only:

    opaque serialized encrypted bytes

Transport does NOT receive plaintext.


CURRENT RECEIVE FLOW
--------------------

User:

1. Selects "Check inbox"
2. Enters recipient ID
3. Chooses transport
4. Application retrieves opaque payloads
5. Deserializes
6. Decrypts using local private identity
7. Displays plaintext


CURRENT CLI TESTS
-----------------

internal/cli/app_test.go covers:

- encryption before delivery
- rejecting empty plaintext
- rejecting nil recipient key
- inbox decryption
- malformed messages
- undecryptable messages
- send -> receive round trip
- identity creation
- identity persistence
- corrupted identity rejection
- public identity JSON round trip

Important security test:

    // The transport must NOT receive plaintext.
    if bytes.Contains(ft.messages[0].Payload, plaintext) {
        t.Fatal("transport received plaintext — payload must be opaque encrypted bytes")
    }


VALIDATION STATUS
-----------------

These passed:

    git diff --check

    go vet ./...

    go test ./...

Test output:

    ?       quantummail/cmd/demo    [no test files]
    ?       quantummail/cmd/quantummail     [no test files]
    ok      quantummail/internal/cli
    ok      quantummail/internal/emailtransport
    ok      quantummail/internal/identity
    ok      quantummail/internal/securemessage
    ok      quantummail/internal/transport


README
------

README was updated to describe:

- Phase 1
- Phase 2
- Phase 3
- Phase 4
- Phase 5
- CLI quick start
- Alice -> Bob local demo
- real email configuration

Current README status before further changes:

    Current status: Phase 5 - Interactive CLI Application.


IMPORTANT ARCHITECTURAL BOUNDARY
================================

Current conceptual architecture:

                    ┌──────────────────────┐
                    │      CLI / App       │
                    │       Phase 5        │
                    └──────────┬───────────┘
                               │
                       encrypt/decrypt
                               │
                    ┌──────────▼───────────┐
                    │    Secure Message    │
                    │   Phase 1 + Phase 2  │
                    └──────────┬───────────┘
                               │
                     opaque encrypted bytes
                               │
              ┌────────────────┴────────────────┐
              │                                 │
      ┌───────▼────────┐               ┌────────▼───────┐
      │ Local Transport│               │ Email Transport│
      │    Phase 3     │               │    Phase 4     │
      └────────────────┘               └────────────────┘

Most important rule:

    TRANSPORT CARRIES ENCRYPTED DATA.
    TRANSPORT DOES NOT UNDERSTAND OR DECRYPT THE MESSAGE.


CURRENT PRODUCT OBJECTIVE
=========================

The project is no longer merely:

    "Implement QuantumMail phases."

The new objective is:

    BUILD A USABLE SECURE EMAIL CLIENT BY AUGUST 25, 2026.

Ideal experience:

    Launch QuantumMail
        ->
    First-run setup
        ->
    Enter Gmail email
        ->
    Enter Gmail App Password
        ->
    Application configures SMTP/IMAP
        ->
    Test connection
        ->
    Main application
        ->
    Inbox / Compose / Settings


IMPORTANT PRODUCT INSIGHT
-------------------------

QuantumMail identity is separate from the email provider account.

Conceptually:

    Gmail account
         |
         | SMTP / IMAP
         v
    QuantumMail transport
         |
         | encrypted QuantumMail payload
         v
    QuantumMail cryptographic identity

Gmail is merely the transport provider.

This is an important hackathon selling point.


WHAT NOT TO DO BEFORE DEADLINE
==============================

Do NOT attempt:

- production-grade email server
- new cryptographic primitives
- replacing ML-KEM
- custom SMTP implementation
- custom IMAP implementation
- complete Gmail clone
- contacts system beyond MVP needs
- folders/labels
- advanced search
- multiple email providers
- cloud infrastructure
- mobile apps
- multi-device identity synchronization
- unnecessary persistence redesign
- unnecessary rewrites of working Phase 1-4 code

The crypto and transport implementation works.

Do not destabilize it.


RECOMMENDED REMAINING WORK
==========================

PHASE 6 — USER-FRIENDLY ACCOUNT SETUP
-------------------------------------

This is the immediate next phase.

Goal:

    Hide the environment-variable configuration behind the application.

Instead of requiring users to manually configure:

    QUANTUMMAIL_SMTP_HOST
    QUANTUMMAIL_SMTP_PORT
    QUANTUMMAIL_IMAP_HOST
    etc.

QuantumMail should have a first-run setup screen.

For Gmail, known defaults can be used:

    SMTP:
        smtp.gmail.com
        port 465
        implicit TLS

    IMAP:
        imap.gmail.com
        port 993
        implicit TLS

User supplies:

    Email address
    Gmail App Password

Then:

    [✓] SMTP connection successful
    [✓] IMAP connection successful
    [✓] QuantumMail identity loaded

The App Password must NEVER be printed or logged.

If time permits, store credentials using OS credential storage.

If secure OS credential storage is too much for the deadline, a local config file
with restrictive permissions can be used, with the limitation documented.

Keep the environment-variable mode as a fallback/debug/developer mode if useful.


PHASE 7 — TUI
------------

The user prefers TUI.

Build the actual application interface.

Minimum screens:

    Setup
    Inbox
    Message view
    Compose
    Settings

Potential layout:

    ┌──────────────────────────────────────────────────────┐
    │ QUANTUMMAIL                             Connected ✓ │
    ├───────────────┬──────────────────────────────────────┤
    │               │                                      │
    │  INBOX        │  Inbox                               │
    │               │                                      │
    │  Compose      │  ┌────────────────────────────────┐  │
    │  Sent         │  │ Alice                           │  │
    │  Settings     │  │ Hello Bob!                      │  │
    │               │  │ Aug 22                           │  │
    │               │  └────────────────────────────────┘  │
    │               │                                      │
    ├───────────────┴──────────────────────────────────────┤
    │ ↑↓ Navigate   Enter Open   c Compose   q Quit       │
    └──────────────────────────────────────────────────────┘

Possible keyboard controls:

    ↑ ↓
    Enter
    c
    r
    s
    q

The TUI should call application services.

Do NOT put encryption logic inside UI code.

Target architecture:

    TUI
     |
     v
    Application services
     |
     +-- Identity
     +-- Send
     +-- Receive
     +-- Contacts
     +-- Configuration
          |
          v
       Crypto / Transport


GUI DECISION
------------

GUI is valuable because it immediately communicates:

    "This is an application."

But:

    GUI must NOT consume the remaining time if it threatens reliability.

Decision rule:

If TUI/backend is complete early:

    Build GUI.

If time is tight:

    Ship excellent TUI.

If necessary:

    CUT GUI FIRST.

Never cut:

- crypto
- email transport
- identity persistence
- send/receive
- application usability


PHASE 8 — COMPOSE
-----------------

Final application should allow:

    Compose

    To:
    Subject:
    Message:

    [ Encrypt & Send ]

Internally:

    Recipient public identity
        ->
    Encrypt
        ->
    Serialize
        ->
    SMTP

For the hackathon MVP, recipient public identity can remain a file-based
mechanism if necessary.

Possible future contact book:

    Bob
    bob@gmail.com
    bob.public.json

But do NOT over-engineer this before the deadline.


PHASE 9 — INBOX
---------------

Inbox should:

- retrieve QuantumMail messages
- decrypt valid messages
- display sender
- display subject if implemented
- display message body
- display timestamps
- gracefully handle undecryptable messages

Example:

    INBOX

    ┌──────────────────────────────────────────┐
    │ Alice                                     │
    │ Hello from QuantumLand                   │
    │ Today, 19:42                              │
    └──────────────────────────────────────────┘

    ┌──────────────────────────────────────────┐
    │ Bob                                       │
    │ QuantumMail demo                          │
    │ Today, 18:13                              │
    └──────────────────────────────────────────┘


PHASE 10 — SETTINGS
-------------------

Minimum settings:

    Account
        Email: user@gmail.com

    Connection
        SMTP: Connected
        IMAP: Connected

    Security
        QuantumMail identity: Loaded
        Public identity: Export

    Actions
        Test connection
        Change account

Never display:

- App Password
- private key
- ML-KEM secret key
- AES key
- shared secret


PHASE 11 — HACKATHON POLISH
---------------------------

Ideal demo narrative:

1. Launch QuantumMail.
2. Show QuantumMail identity.
3. Show Gmail account connected.
4. Compose a message.
5. Encrypt and send.
6. Show Gmail/IMAP transport working.
7. Retrieve through QuantumMail.
8. Show decrypted message.
9. Explain:

       "Gmail transports the message,
        but Gmail never sees the plaintext."

This is the central demo.


SECURITY STORY
==============

QuantumMail should be presented as:

    A secure email client that uses post-quantum key encapsulation
    to protect message content while using ordinary email infrastructure
    as the transport layer.

Simplified flow:

    Plaintext
        |
        v
    ML-KEM-768
        |
        v
    AES-256-GCM encrypted message
        |
        v
    Serialized QuantumMail payload
        |
        v
    Gmail SMTP
        |
        v
    Internet
        |
        v
    Gmail IMAP
        |
        v
    QuantumMail
        |
        v
    ML-KEM decapsulation
        |
        v
    AES-GCM authentication/decryption
        |
        v
    Plaintext

Important distinction:

    Gmail sees:
        encrypted QuantumMail payload

    QuantumMail sees:
        plaintext after local decryption


CURRENT REPOSITORY STRUCTURE
============================

cmd/
    demo/
    quantummail/
        main.go

internal/
    cli/
        app.go
        app_test.go
        flows.go
        transports.go
        ui.go

    emailtransport/
        config.go
        imap.go
        message.go
        smtp.go
        live_integration_test.go

    identity/
        persistence.go
        ...

    securemessage/
        ...

    transport/
        ...

README.md
go.mod
go.sum


IMPORTANT:
----------

codebase.txt was deleted.

DO NOT reintroduce it.


CURRENT CODE DETAILS
====================

cmd/quantummail/main.go:

- finds user's home directory
- creates ~/.quantummail
- calls cli.New
- starts cli.NewUI()
- calls app.RunMenu(ui)

cli.New(dataDir):

- creates data directory with 0700
- loads existing identity
- otherwise generates identity
- persists identity
- creates local mailbox root

cli.Send():

    plaintext
        ->
    securemessage.Encrypt
        ->
    securemessage.Serialize
        ->
    transport.Deliver

cli.CheckInbox():

    transport.Retrieve
        ->
    securemessage.Deserialize
        ->
    securemessage.Decrypt
        ->
    plaintext


POSSIBLE SMALL CODE IMPROVEMENTS
================================

These are lower priority than application UX.

1. IdentityFileExists()

The comment currently describes an IsNewIdentity concept, but the actual
method is IdentityFileExists() and simply checks whether the file exists.

Not important right now.

2. Transport selection

Invalid transport input currently falls back to local transport.

For a polished app, invalid input should probably produce an error or re-prompt.

Not urgent.

3. Email account configuration

Currently environment-variable based.

This is the largest UX limitation.

4. Inbox error semantics

Current message:

    [WARN] Message ... could not be decrypted

Later distinguish:

    invalid QuantumMail payload
    wrong identity
    corrupt message
    unsupported version

Not required immediately.


SUGGESTED DEVELOPMENT TIMELINE
==============================

AUGUST 22 — BACKEND / PRODUCT FOUNDATION
----------------------------------------

Goal:

Make QuantumMail behave like an actual application rather than a developer CLI.

Tasks:

1. Freeze Phase 1-5.
2. Add persistent email account configuration.
3. Add Gmail-specific setup.
4. Remove the need for manual QUANTUMMAIL_* environment variables for normal users.
5. Build clean application-level configuration API.
6. Test Gmail connection from application code.
7. Keep environment-variable mode as fallback/debug functionality.


AUGUST 23 — TUI
---------------

Build actual TUI.

Minimum:

    Setup
    Inbox
    Message view
    Compose
    Settings

Do not move crypto logic into UI.

Keep the backend architecture clean.


AUGUST 24 — POLISH + OPTIONAL GUI
---------------------------------

First:

- fix bugs
- improve error messages
- test Gmail
- test fresh install
- test restart
- test invalid credentials
- test empty inbox
- test undecryptable message
- test sending
- test receiving
- test identity persistence

Then, ONLY if stable:

    Build GUI.

If GUI takes too long:

    Skip GUI and polish TUI.


AUGUST 25 — SUBMISSION
----------------------

No architectural experiments.

Only:

- final testing
- README
- screenshots
- demo video if needed
- presentation
- cleanup
- final Git commit/tag
- final submission


WHAT COUNTS AS DONE
===================

Already complete:

[x] QuantumMail identity generated
[x] Identity persistence
[x] Public identity export
[x] Recipient public identity import
[x] Message encryption
[x] Message serialization
[x] Local transport
[x] SMTP
[x] IMAP
[x] Gmail App Password authentication
[x] Gmail real-email round trip
[x] CLI send
[x] CLI receive
[x] Tests
[x] go vet
[x] git diff --check
[x] Phase 5 committed and pushed

Remaining:

[ ] User-friendly first-run account setup
[ ] Application-managed Gmail configuration
[ ] Proper inbox UI
[ ] Compose UI
[ ] Message view
[ ] Settings
[ ] Polished TUI
[ ] Optional GUI
[ ] Final hackathon demo polish


ABSOLUTE PRIORITY ORDER
=======================

If time starts running out:

    1. Working Gmail application
             |
             v
    2. First-run setup
             |
             v
    3. Good TUI
             |
             v
    4. Reliable inbox + compose
             |
             v
    5. Error handling
             |
             v
    6. Visual polish
             |
             v
    7. GUI
             |
             v
    8. Nice-to-have features

If necessary:

    GUI <- CUT FIRST

Do NOT cut:

- crypto
- email transport
- identity persistence
- send/receive
- application usability


HOW WE SHOULD WORK FROM HERE
============================

The user wants guidance rather than blindly generated code.

For each phase:

1. Explain the goal.
2. Explain why the architectural change is needed.
3. Identify the files/components involved.
4. Break the work into small implementation steps.
5. Let the user implement where practical.
6. Review code/diffs.
7. Test.
8. Commit.
9. Move to next phase.

Do NOT rewrite the entire codebase unnecessarily.

When reviewing code, prioritize:

1. correctness
2. security boundaries
3. data flow
4. error handling
5. maintainability
6. UX
7. polish


IMMEDIATE NEXT STEP
===================

Phase 5 is committed.

Do NOT immediately start building a GUI.

Immediate next phase:

    PHASE 6 — USER-FRIENDLY ACCOUNT SETUP + APPLICATION CONFIGURATION

Goal:

Take the working Gmail SMTP/IMAP backend and make it usable by a normal
person without manually setting 14 environment variables.

First milestone:

    QuantumMail
        ->
    First launch
        ->
    Enter Gmail address
        ->
    Enter Gmail App Password
        ->
    Test SMTP + IMAP
        ->
    Save configuration
        ->
    Open application

After that:

    PHASE 7 — TUI

Then:

    PHASE 8 — POLISH / OPTIONAL GUI


ONE-SENTENCE PROJECT DEFINITION
===============================

QuantumMail is a Go-based secure email client that uses ML-KEM-768 and
AES-256-GCM to encrypt message content end-to-end while using standard
Gmail SMTP/IMAP infrastructure purely as the transport layer.


IMPORTANT FOR FUTURE CHATGPT
============================

If this context is pasted into a new conversation:

DO NOT restart the project from Phase 1.

DO NOT suggest rebuilding the crypto layer.

DO NOT assume Gmail integration is untested.

The following has already been proven:

    Gmail SMTP send
        +
    Gmail IMAP retrieval
        +
    QuantumMail encryption
        +
    QuantumMail decryption
        =
    SUCCESS

Current project position:

    POST-PHASE-5 / BEGINNING PHASE 6

The remaining task is primarily:

    TURN THE WORKING SECURE MESSAGING BACKEND
    INTO A POLISHED APPLICATION BEFORE AUGUST 25, 2026.