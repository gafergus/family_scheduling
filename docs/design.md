# Design

Status: draft, 2026-11-15. This file is the spec the code builds against. Change the spec first, then the code.

## Product

A free iOS app that helps married parents connect their calendars, mail and messages and get one priority list for each day. It is for parents. It is not a safety or monitoring app.

- Publisher: Chrysalis AI LLC (Delaware). License: AGPL-3.0-only.
- No backend, no server, no accounts, no analytics, no remote LLM. The app talks only to each user's own providers and to the family's iCloud.
- No relationship with users by design. Support is GitHub issues. Updates are App Store updates.

## Members and roles

| Role | Who | Access |
|---|---|---|
| Owner | Married adult who creates the family | Read and write all family and parent zones |
| Spouse | Married adult invited by the owner | Read and write all family and parent zones |
| Teen | Child aged 13 to 17 | Read only, family zone only |

- Under 13: blocked. The Declared Age Range API gates at 13. The App Store age rating is 13+ so Screen Time blocks managed child accounts.
- Under 18 cannot own a family. The app refuses the owner role.
- Teens ingest nothing. They connect no sources.
- Read only is enforced by CloudKit with `CKShare` participant permission `.readOnly`, not only in the UI.

## Attestation

Every attestation is a yes or no. A no stops the app on that device. Each record stores the timestamp, who attested and a hash of the exact wording, in the family's encrypted store. Nothing is sent to the publisher.

- Owner, on inviting: "I attest that [Name] is my spouse and is joining with their own device and consent."
- Spouse, on their own device: "I attest that I am the spouse of [Name] and am joining this family voluntarily."
- Owner or spouse, per teen: "I attest that I am the parent or legal guardian of [Name], who is 13 or older."

Wording is a draft for legal review.

## Storage and encryption

- CloudKit. Each family has two zones: a parent zone shared only between spouses and a family zone also shared read only with teens.
- Family-key encryption is opt in. Each adult has a Curve25519 keypair in iCloud Keychain. Each zone key is wrapped once per member who may read it. A teen cannot unwrap the parent zone key.
- Removing a member rotates the affected zone keys and re-wraps them for remaining members.
- If every adult loses every device and their Keychain, the data is gone. The opt-in screen says so.
- On device: main store `NSFileProtectionComplete`. Staging inbox `NSFileProtectionCompleteUnlessOpen` so automations can write while the phone is locked. Credentials in Keychain with `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly`.

## Ingestion

Each adult's sources are read only on that adult's device. Raw message and mail text never syncs. Only items the owner of the source confirms become shared tasks. Raw text is deleted from the staging inbox after extraction.

### Calendars

- EventKit for every account added in iOS Settings: iCloud, Google, Exchange, Outlook. No OAuth.
- ICS subscription feeds for school, sports and Proton Calendar. Conditional GET with ETag.

### Mail

- IMAP. Gmail through an app password first, on-device OAuth with PKCE later. Outlook.com through on-device OAuth (MSAL public client).
- Proton Mail has no route on iOS. Not supported.
- A sender allowlist (school domains, coaches, spouse) decides which messages reach extraction.

### Texts and iMessage

- Automatic: a Shortcuts personal automation with the Message trigger, one per sender, set to run immediately. It calls the write-only App Intent `IngestMessageIntent(sender, body, receivedAt)`, which writes to the staging inbox. The app ships a guided setup for this automation.
- Manual: the share extension accepts selected message text.

### WhatsApp

WhatsApp has no API for personal accounts and iOS gives no app access to another app's messages or notifications. Supported routes:

- Share extension: select messages, share to the app.
- Screenshot: share a screenshot of a chat. Vision `VNRecognizeTextRequest` runs on device to read the text.
- Chat export: WhatsApp Export Chat as a .zip, shared to the app. The importer parses `_chat.txt`, keeps only messages after the last imported timestamp and deduplicates on sender, timestamp and a body hash.

Rejected: unofficial WhatsApp clients (Baileys, whatsmeow) and WhatsApp Web automation. They break WhatsApp terms, risk bans and need a server.

### eCalendar and other wall displays

eCalendar syncs two ways with Google Calendar. The bridge is a dedicated Google calendar, for example "Family Board", that both sides use.

- App to wall: the app writes confirmed family-zone items to the Family Board calendar through EventKit.
- Wall to app: events created on the wall arrive through the same calendar and enter the app as proposals.
- Split events: the title is minimal plaintext such as "Pickup 3:30", because the wall cannot decrypt. Full details go in the event notes as an encrypted block only the app can read. Google and eCalendar see the title and time.
- Echo guard: each event the app writes carries an app marker in its notes. On read, the app recognizes its own events and does not import them again.
- Edits from the wall to an app event: plaintext title and time win. The app re-encrypts the details.
- Wall events are unattributed. Anyone standing at the wall can add one, teens included. They stay proposals until an adult confirms them.
- Limits from the eCalendar manual: tasks do not sync, recurring Google events can only be edited one instance at a time, sync takes about a minute.
- Setup shows a plain notice: anything on this calendar is stored by Google and by eCalendar under their own privacy policies.

## Extraction and ranking

- Extraction: Apple Foundation Models on device where available, deterministic rules otherwise. Each candidate task keeps a link to its source item.
- Ranking: deterministic. Hard constraints first (time, place, who can drive, dependencies), then weighted goals. Conflict detection across both spouses.
- Each member's view shows when their sources were last read.

## No API

- No inbound API, no server, no URL scheme or App Intent that reads data out.
- App Intents that write into the staging inbox are inputs, not an API.
- Notifications are local only.

## Donations

Opt in, never required, no feature behind them.

- In-app tip jar with consumable purchases. The only route that tells the publisher nothing about the donor.
- External link (GitHub Sponsors, Ko-fi) shown only in storefronts that allow it, checked with StoreKit `Storefront.current?.countryCode`.
- Links on the website and README.

## Verification

The App Store description lists every host the app contacts. Users check it against iOS App Privacy Report.
