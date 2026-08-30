# QuantumMail Development Archive

## Conversation Scope

This document archives the project-development history available in this conversation context. It preserves the chronological engineering flow, implementation reports, validation output, code reviews, decisions, and Phase 8 implementation contract discussed here.

---

# 1. Phase 6 Validation and Repository Work

## Validation Results

### User Prompt

The following validation commands and results were provided:

```text
 go test -count=1 ./...
go test -race -count=1 ./...
go vet ./...
go build ./...
git diff --check
?       quantummail/cmd/demo    [no test files]
?       quantummail/cmd/quantummail     [no test files]
ok      quantummail/internal/cli        0.005s
ok      quantummail/internal/emailtransport     0.006s
ok      quantummail/internal/identity   0.004s
ok      quantummail/internal/securemessage      0.006s
ok      quantummail/internal/transport  0.006s
ok      quantummail/internal/web        0.009s
?       quantummail/cmd/demo    [no test files]
?       quantummail/cmd/quantummail     [no test files]
ok      quantummail/internal/cli        1.022s
ok      quantummail/internal/emailtransport     1.023s
ok      quantummail/internal/identity   1.024s
ok      quantummail/internal/securemessage      1.028s
ok      quantummail/internal/transport  1.027s
ok      quantummail/internal/web        1.039s
```

### AI Implementation

The validation sequence was understood as successful:

- deterministic tests passed;
- race-enabled tests passed;
- `go vet ./...` passed;
- `go build ./...` passed;
- `git diff --check` passed.

The project was considered ready for commit after repository inspection.

---

# 2. Commit and Push

## User Commit Commands

### User Prompt

```bash
git add --all
git commit -m "XxX"
git push origin main
```

The repository to inspect was:

```text
https://github.com/yorodeb/QuantumMail
```

### AI Implementation

The commit/push workflow was treated as the correct sequence:

```bash
git add --all
git commit -m "..."
git push origin main
```

The repository was later reviewed as part of the project progression.

---

# 3. Project Recap and Next Phase

## User Request

### User Prompt

The user asked for a recap of where the project had been left and what implementation step should come next.

### AI Implementation

The next major implementation phase became **Phase 7: persistent contact management and contact-based recipient selection**.

The rationale was:

- the application already had cryptographic identities;
- public identities could be exported;
- Compose still depended on selecting or supplying a public identity file;
- users needed a persistent way to store recipient public identities;
- cryptographic recipient identity needed to remain separate from transport routing information.

The resulting workflow was designed as:

1. User obtains another user's public identity JSON.
2. User imports that JSON into local Contacts.
3. Contact stores public cryptographic identity material.
4. Contact optionally stores:
   - email recipient;
   - local transport recipient ID.
5. Compose selects a saved contact.
6. The selected contact's public key is used for encryption.
7. The appropriate transport recipient is selected separately according to active transport mode.

---

# 4. Phase 7 Implementation Contract

## User Request

### User Prompt

The user requested an implementation-contract prompt for the phase.

### AI Implementation

The phase was implemented around these core requirements:

- add a local contacts/public-identity system;
- persist contacts under the QuantumMail application data directory;
- import public identity JSON files;
- explicitly reject private identity material;
- store public key material only;
- reject duplicate contact names and duplicate public identities;
- integrate Contacts into the web UI;
- replace Compose's filesystem-path public-key workflow with contact selection;
- preserve the separation between:
  - cryptographic identity;
  - transport recipient address;
- avoid modifying cryptographic primitives or transport internals unnecessarily.

The phase remained explicitly out of scope for:

- global public directories;
- identity discovery;
- key servers;
- accounts;
- authentication;
- OAuth;
- cloud synchronization.

---

# 5. Phase 7 Repository Inspection and Baseline

## AI Implementation Activity

The implementation process began by inspecting the actual repository state rather than assuming an earlier architecture.

The repository was checked with:

```bash
cd /home/peter/QuantumMail && git status --short && git branch --show-current && git rev-parse --short HEAD
```

The implementation report established:

- the repository was clean;
- the commit was `c972f5f`;
- the current Compose flow depended on a public-key file path;
- the relevant web, identity, persistence, transport, and test code was inspected.

A deterministic baseline was run.

Result:

```text
16/16 tests passed (100%)
```

Further architecture inspection mapped:

- send/decrypt boundaries;
- transport boundaries;
- identity parsing;
- persistence;
- web entrypoints;
- configuration;
- templates;
- tests.

The implementation specifically aimed to integrate contacts without changing the crypto or transport boundaries.

---

# 6. Phase 7: Contacts Architecture

## New Package

### AI Implementation

A new package was introduced:

```text
internal/contacts/
```

With:

```text
contacts.go
contacts_test.go
```

The package owns:

- contact model;
- persistence;
- duplicate rules;
- import validation orchestration.

The web layer remains responsible for:

- HTTP handling;
- multipart form processing;
- rendering;
- user-facing orchestration.

The identity package remains responsible for:

- cryptographic identity representation;
- parsing public identities;
- reconstructing public keys.

---

## Contact Persistence Location

### Engineering Decision

Contacts are stored locally at:

```text
~/.quantummail/contacts.json
```

The contact persistence model includes:

- versioning;
- validation on load;
- atomic replacement through temporary file and rename;
- restricted permissions on persisted contact files.

Contacts contain:

- stable local ID;
- display name;
- stored public key bytes;
- optional email recipient;
- optional local recipient ID;
- creation timestamp;
- update timestamp.

Contacts do not contain private identity material.

---

# 7. Phase 7: Public Identity Import Hardening

## User/Engineering Requirement

Public identity files imported as contacts must be validated.

### AI Implementation

`identity.ParsePublicKey` was hardened to explicitly detect private identity fields.

### Before

```go
var pub struct {
	Version   int    `json:"version"`
	PublicKey []byte `json:"public_key"`
}
if err := json.Unmarshal(data, &pub); err != nil {
	return nil, fmt.Errorf("identity: parse public key: %w", err)
}
if pub.Version != identityFileVersion {
	return nil, fmt.Errorf("identity: unsupported public key version %d", pub.Version)
}
if len(pub.PublicKey) == 0 {
	return nil, fmt.Errorf("identity: public key bytes are missing")
}
ek, err := mlkem.NewEncapsulationKey768(pub.PublicKey)
```

### After

```go
var pub struct {
	Version          int    `json:"version"`
	PublicKey        []byte `json:"public_key"`
	PrivateKey       []byte `json:"private_key"`
	PrivateSeed      []byte `json:"private_seed"`
	DecapsulationKey []byte `json:"decapsulation_key"`
}
if err := json.Unmarshal(data, &pub); err != nil {
	return nil, fmt.Errorf("identity: parse public key: %w", err)
}
if len(pub.PrivateKey) > 0 || len(pub.PrivateSeed) > 0 || len(pub.DecapsulationKey) > 0 {
	return nil, fmt.Errorf("identity: input contains private identity material")
}
if pub.Version != identityFileVersion {
	return nil, fmt.Errorf("identity: unsupported public key version %d", pub.Version)
}
if len(pub.PublicKey) == 0 {
	return nil, fmt.Errorf("identity: public key bytes are missing")
}
ek, err := PublicKeyFromBytes(pub.PublicKey)
if err != nil {
	return nil, err
}
return ek, nil
```

A reusable helper was added:

```go
// PublicKeyFromBytes reconstructs an encapsulation key from raw ML-KEM-768
// public key bytes.
func PublicKeyFromBytes(data []byte) (*PublicKey, error) {
	if len(data) == 0 {
		return nil, fmt.Errorf("identity: public key bytes are missing")
	}
	ek, err := mlkem.NewEncapsulationKey768(data)
	if err != nil {
		return nil, fmt.Errorf("identity: invalid public key bytes: %w", err)
	}
	return &PublicKey{key: ek}, nil
}
```

The key security rule became explicit:

> A private identity file must not be accepted where a public identity is expected.

---

# 8. Phase 7: Contact Store Implementation

## User Prompt

The complete `internal/contacts/contacts.go` implementation was provided for review:

```go
package contacts

import (
	"crypto/rand"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"sort"
	"strings"
	"time"

	"quantummail/internal/identity"
)

const fileVersion = 1

// Contact contains public-only recipient identity information and transport routing hints.
type Contact struct {
	ID             string    `json:"id"`
	Name           string    `json:"name"`
	PublicKey      []byte    `json:"public_key"`
	Email          string    `json:"email,omitempty"`
	LocalRecipient string    `json:"local_recipient,omitempty"`
	CreatedAt      time.Time `json:"created_at"`
	UpdatedAt      time.Time `json:"updated_at"`
}

type persistedContacts struct {
	Version  int       `json:"version"`
	Contacts []Contact `json:"contacts"`
}

// Store manages persistent contacts for one QuantumMail data directory.
type Store struct {
	path     string
	contacts []Contact
}

// ImportInput is the required data to create a contact from an uploaded public identity JSON.
type ImportInput struct {
	Name               string
	PublicIdentityJSON []byte
	Email              string
	LocalRecipient     string
}

// Load reads contacts from path. Missing files are treated as an empty store.
func Load(path string) (*Store, error) {
	store := &Store{path: path}

	data, err := os.ReadFile(path)
	if err != nil {
		if os.IsNotExist(err) {
			return store, nil
		}
		return nil, fmt.Errorf("contacts: read store: %w", err)
	}
	if len(data) == 0 {
		return store, nil
	}

	var persisted persistedContacts
	if err := json.Unmarshal(data, &persisted); err != nil {
		return nil, fmt.Errorf("contacts: parse store: %w", err)
	}
	if persisted.Version != fileVersion {
		return nil, fmt.Errorf("contacts: unsupported version %d", persisted.Version)
	}

	seenIDs := map[string]struct{}{}
	for _, c := range persisted.Contacts {
		if err := validateLoaded(c, seenIDs); err != nil {
			return nil, err
		}
		seenIDs[c.ID] = struct{}{}
	}

	store.contacts = append(store.contacts, persisted.Contacts...)
	return store, nil
}

// ImportPublicIdentity adds a new contact after validating public identity content.
func (s *Store) ImportPublicIdentity(input ImportInput) (Contact, error) {
	name := strings.TrimSpace(input.Name)
	if name == "" {
		return Contact{}, fmt.Errorf("contacts: display name is required")
	}
	email := strings.TrimSpace(input.Email)
	localRecipient := strings.TrimSpace(input.LocalRecipient)
	if email == "" && localRecipient == "" {
		return Contact{}, fmt.Errorf("contacts: at least one transport recipient is required")
	}

	key, err := identity.ParsePublicKey(input.PublicIdentityJSON)
	if err != nil {
		return Contact{}, fmt.Errorf("contacts: invalid public identity: %w", err)
	}
	pubKey := key.Bytes()

	for _, existing := range s.contacts {
		if strings.EqualFold(existing.Name, name) {
			return Contact{}, fmt.Errorf("contacts: contact name %q already exists", name)
		}
		if string(existing.PublicKey) == string(pubKey) {
			return Contact{}, fmt.Errorf("contacts: public identity already exists")
		}
	}

	id, err := newContactID()
	if err != nil {
		return Contact{}, err
	}
	now := time.Now().UTC()
	contact := Contact{
		ID:             id,
		Name:           name,
		PublicKey:      append([]byte(nil), pubKey...),
		Email:          email,
		LocalRecipient: localRecipient,
		CreatedAt:      now,
		UpdatedAt:      now,
	}

	s.contacts = append(s.contacts, contact)
	if err := s.persist(); err != nil {
		s.contacts = s.contacts[:len(s.contacts)-1]
		return Contact{}, err
	}

	return contact, nil
}

// Delete removes a contact by ID. It returns true only when a contact existed and was removed.
func (s *Store) Delete(id string) (bool, error) {
	for i := range s.contacts {
		if s.contacts[i].ID != id {
			continue
		}
		s.contacts = append(s.contacts[:i], s.contacts[i+1:]...)
		if err := s.persist(); err != nil {
			return false, err
		}
		return true, nil
	}
	return false, nil
}

// Get finds a contact by ID.
func (s *Store) Get(id string) (Contact, bool) {
	for _, contact := range s.contacts {
		if contact.ID == id {
			copyContact := contact
			copyContact.PublicKey = append([]byte(nil), contact.PublicKey...)
			return copyContact, true
		}
	}
	return Contact{}, false
}

// List returns a copy of contacts sorted by case-insensitive display name.
func (s *Store) List() []Contact {
	result := make([]Contact, len(s.contacts))
	for i := range s.contacts {
		result[i] = s.contacts[i]
		result[i].PublicKey = append([]byte(nil), s.contacts[i].PublicKey...)
	}
	sort.Slice(result, func(i, j int) bool {
		left := strings.ToLower(result[i].Name)
		right := strings.ToLower(result[j].Name)
		if left == right {
			return result[i].ID < result[j].ID
		}
		return left < right
	})
	return result
}

func (s *Store) persist() error {
	persisted := persistedContacts{Version: fileVersion, Contacts: s.contacts}
	data, err := json.MarshalIndent(&persisted, "", "  ")
	if err != nil {
		return fmt.Errorf("contacts: marshal store: %w", err)
	}

	dir := filepath.Dir(s.path)
	if err := os.MkdirAll(dir, 0o700); err != nil {
		return fmt.Errorf("contacts: create directory: %w", err)
	}
	tmp, err := os.CreateTemp(dir, "contacts-*.tmp")
	if err != nil {
		return fmt.Errorf("contacts: create temp file: %w", err)
	}
	tmpPath := tmp.Name()
	defer func() {
		_ = tmp.Close()
		_ = os.Remove(tmpPath)
	}()

	if _, err := tmp.Write(data); err != nil {
		return fmt.Errorf("contacts: write temp file: %w", err)
	}
	_ = tmp.Chmod(0o600)
	if err := tmp.Close(); err != nil {
		return fmt.Errorf("contacts: close temp file: %w", err)
	}
	if err := os.Rename(tmpPath, s.path); err != nil {
		return fmt.Errorf("contacts: replace store: %w", err)
	}
	return nil
}

func validateLoaded(contact Contact, seenIDs map[string]struct{}) error {
	if strings.TrimSpace(contact.ID) == "" {
		return fmt.Errorf("contacts: contact has empty ID")
	}
	if _, exists := seenIDs[contact.ID]; exists {
		return fmt.Errorf("contacts: duplicate contact ID %q", contact.ID)
	}
	if strings.TrimSpace(contact.Name) == "" {
		return fmt.Errorf("contacts: contact %q has empty name", contact.ID)
	}
	if _, err := identity.PublicKeyFromBytes(contact.PublicKey); err != nil {
		return fmt.Errorf("contacts: contact %q has invalid public key: %w", contact.ID, err)
	}
	return nil
}

func newContactID() (string, error) {
	buf := make([]byte, 16)
	if _, err := rand.Read(buf); err != nil {
		return "", fmt.Errorf("contacts: generate ID: %w", err)
	}
	return hex.EncodeToString(buf), nil
}
```

### AI Review

The implementation was approved for the Phase 7 commit.

The review highlighted that it correctly covered:

- public-only contact identity storage;
- random stable IDs;
- versioned persistence;
- missing file handling;
- loaded data validation;
- duplicate-name rejection;
- duplicate-public-key rejection;
- copy semantics for returned public-key slices;
- sorted listing;
- atomic persistence;
- directory permissions;
- contact ID generation using `crypto/rand`.

One robustness observation was explicitly deferred:

> `Delete` mutates `s.contacts` before calling `persist()`, so if persistence fails, the in-memory store remains changed even though the deletion was not successfully saved.

This was not considered a Phase 7 blocker, but was identified as a concrete candidate for Phase 8 hardening.

---

# 9. Phase 7: Contact Tests

## User Prompt

The complete `internal/contacts/contacts_test.go` file was provided:

```go
package contacts_test

import (
	"bytes"
	"os"
	"path/filepath"
	"testing"

	"quantummail/internal/contacts"
	"quantummail/internal/identity"
)

func mustPublicIdentityJSON(t *testing.T) []byte {
	t.Helper()
	id, err := identity.New()
	if err != nil {
		t.Fatalf("identity.New: %v", err)
	}
	pubPath := filepath.Join(t.TempDir(), "recipient.public.json")
	if err := identity.ExportPublic(pubPath, id); err != nil {
		t.Fatalf("ExportPublic: %v", err)
	}
	data, err := os.ReadFile(pubPath)
	if err != nil {
		t.Fatalf("os.ReadFile: %v", err)
	}
	return data
}

func mustPrivateIdentityJSON(t *testing.T) []byte {
	t.Helper()
	id, err := identity.New()
	if err != nil {
		t.Fatalf("identity.New: %v", err)
	}
	path := filepath.Join(t.TempDir(), "recipient.identity.json")
	if err := identity.SaveToFile(id, path); err != nil {
		t.Fatalf("SaveToFile: %v", err)
	}
	data, err := os.ReadFile(path)
	if err != nil {
		t.Fatalf("os.ReadFile: %v", err)
	}
	return data
}

func TestLoadMissingFileReturnsEmptyStore(t *testing.T) {
	t.Parallel()

	store, err := contacts.Load(filepath.Join(t.TempDir(), "contacts.json"))
	if err != nil {
		t.Fatalf("Load: %v", err)
	}
	if got := len(store.List()); got != 0 {
		t.Fatalf("expected empty store, got %d contacts", got)
	}
}

func TestContactPersistenceRoundTrip(t *testing.T) {
	t.Parallel()

	path := filepath.Join(t.TempDir(), "contacts.json")
	store, err := contacts.Load(path)
	if err != nil {
		t.Fatalf("Load: %v", err)
	}

	created, err := store.ImportPublicIdentity(contacts.ImportInput{
		Name:               "Bob",
		PublicIdentityJSON: mustPublicIdentityJSON(t),
		Email:              "bob@example.com",
		LocalRecipient:     "bob-local",
	})
	if err != nil {
		t.Fatalf("ImportPublicIdentity: %v", err)
	}

	reloaded, err := contacts.Load(path)
	if err != nil {
		t.Fatalf("Load second time: %v", err)
	}
	all := reloaded.List()
	if len(all) != 1 {
		t.Fatalf("expected 1 contact, got %d", len(all))
	}
	if all[0].ID != created.ID || all[0].Name != "Bob" {
		t.Fatalf("unexpected contact after reload: %+v", all[0])
	}
	if !bytes.Equal(all[0].PublicKey, created.PublicKey) {
		t.Fatal("stored public key changed after reload")
	}
}

func TestImportValidPublicIdentitySucceeds(t *testing.T) {
	t.Parallel()

	store, _ := contacts.Load(filepath.Join(t.TempDir(), "contacts.json"))
	contact, err := store.ImportPublicIdentity(contacts.ImportInput{
		Name:               "Bob",
		PublicIdentityJSON: mustPublicIdentityJSON(t),
		Email:              "bob@example.com",
	})
	if err != nil {
		t.Fatalf("ImportPublicIdentity: %v", err)
	}
	if contact.Name != "Bob" {
		t.Fatalf("contact name mismatch: %q", contact.Name)
	}
	if len(contact.PublicKey) == 0 {
		t.Fatal("expected non-empty public key")
	}
}

func TestImportMalformedPublicIdentityFails(t *testing.T) {
	t.Parallel()

	store, _ := contacts.Load(filepath.Join(t.TempDir(), "contacts.json"))
	_, err := store.ImportPublicIdentity(contacts.ImportInput{
		Name:               "Bob",
		PublicIdentityJSON: []byte("not-json"),
		Email:              "bob@example.com",
	})
	if err == nil {
		t.Fatal("expected malformed import error")
	}
}

func TestImportPrivateIdentityFails(t *testing.T) {
	t.Parallel()

	store, _ := contacts.Load(filepath.Join(t.TempDir(), "contacts.json"))
	_, err := store.ImportPublicIdentity(contacts.ImportInput{
		Name:               "Bob",
		PublicIdentityJSON: mustPrivateIdentityJSON(t),
		Email:              "bob@example.com",
	})
	if err == nil {
		t.Fatal("expected private identity import to fail")
	}
}

func TestDuplicateBehaviorRejectsNameAndPublicIdentity(t *testing.T) {
	t.Parallel()

	store, _ := contacts.Load(filepath.Join(t.TempDir(), "contacts.json"))
	publicIdentity := mustPublicIdentityJSON(t)

	_, err := store.ImportPublicIdentity(contacts.ImportInput{
		Name:               "Bob",
		PublicIdentityJSON: publicIdentity,
		Email:              "bob@example.com",
	})
	if err != nil {
		t.Fatalf("first import failed: %v", err)
	}

	_, err = store.ImportPublicIdentity(contacts.ImportInput{
		Name:               "Bob",
		PublicIdentityJSON: mustPublicIdentityJSON(t),
		Email:              "bob2@example.com",
	})
	if err == nil {
		t.Fatal("expected duplicate-name import failure")
	}

	_, err = store.ImportPublicIdentity(contacts.ImportInput{
		Name:               "Bob 2",
		PublicIdentityJSON: publicIdentity,
		Email:              "bob3@example.com",
	})
	if err == nil {
		t.Fatal("expected duplicate-public-identity import failure")
	}
}

func TestDeleteContact(t *testing.T) {
	t.Parallel()

	store, _ := contacts.Load(filepath.Join(t.TempDir(), "contacts.json"))
	created, err := store.ImportPublicIdentity(contacts.ImportInput{
		Name:               "Bob",
		PublicIdentityJSON: mustPublicIdentityJSON(t),
		Email:              "bob@example.com",
	})
	if err != nil {
		t.Fatalf("ImportPublicIdentity: %v", err)
	}
	deleted, err := store.Delete(created.ID)
	if err != nil {
		t.Fatalf("Delete: %v", err)
	}
	if !deleted {
		t.Fatal("expected delete to report true")
	}
	if got := len(store.List()); got != 0 {
		t.Fatalf("expected empty store after delete, got %d", got)
	}
}
```

### AI Review

The test suite was approved.

Coverage included:

- missing store starts empty;
- persistence round trip;
- valid public identity import;
- malformed JSON rejection;
- private identity rejection;
- duplicate display-name rejection;
- duplicate public-identity rejection;
- deletion.

The review also noted positively that the tests used:

```go
package contacts_test
```

This tests the package through its public API rather than reaching directly into internal implementation details.

The helpers:

```go
mustPublicIdentityJSON(t)
mustPrivateIdentityJSON(t)
```

were also considered meaningful because they generate real identities and use actual export/save formats rather than manually fabricated JSON.

A minor style note was made:

```go
store, _ := contacts.Load(...)
```

silently discards a setup error in several tests. This was considered non-blocking and suitable for later cleanup rather than a reason to delay Phase 7.

---

# 10. Phase 7: Web Integration

## App Structure Changes

### Before

The `App` structure did not contain a contacts store.

### After

A contacts store was added:

```go
type App struct {
	cliApp           *cli.App
	config           Config
	configPath       string
	sentHistory      *sentHistory
	contactsStore    *contacts.Store
	mux              *http.ServeMux
	transportBuilder func() (transport.Transport, error)
}
```

The page data model gained contacts:

```go
type pageData struct {
	Title      string
	Current    string
	Error      string
	Success    string
	Messages   []cli.ReceivedMessage
	InboxErrors []cli.InboxError
	Selected   *cli.ReceivedMessage
	Sent       []SentMessage
	Config     Config
	Contacts   []contacts.Contact
}
```

The contacts store is loaded with the application:

```go
contactsStore, err := contacts.Load(filepath.Join(dataDir, "contacts.json"))
if err != nil {
	return nil, fmt.Errorf("web: load contacts: %w", err)
}
```

The application routes gained:

```go
app.mux.HandleFunc("/contacts", app.handleContacts)
app.mux.HandleFunc("/contacts/delete", app.handleContactDelete)
```

---

# 11. Phase 7: Compose Workflow Change

## Before

Compose required:

```text
Recipient routing address or identifier
Recipient public identity file
Message
```

The implementation looked like:

```go
func (a *App) send(recipient, keyPath, message string) error {
	key, err := cli.LoadSenderPublicKeyFromFile(keyPath)
	if err != nil {
		return err
	}
	// ...
}
```

## After

Compose requires:

```text
Contact
Message
```

The handler uses:

```go
contactID := strings.TrimSpace(r.FormValue("contact_id"))
message := strings.TrimSpace(r.FormValue("message"))

if contactID == "" || message == "" {
	data.Error = "contact and message are required"
} else if err := a.send(contactID, message); err != nil {
	data.Error = err.Error()
} else {
	data.Success = "Message sent successfully."
}
```

The send function becomes:

```go
func (a *App) send(contactID, message string) error {
	contact, ok := a.contactsStore.Get(contactID)
	if !ok {
		return fmt.Errorf("selected contact does not exist")
	}

	key, err := identity.PublicKeyFromBytes(contact.PublicKey)
	if err != nil {
		return fmt.Errorf("contact %q has invalid public identity: %w", contact.Name, err)
	}

	recipient, err := a.transportRecipientForContact(contact)
	if err != nil {
		return err
	}

	tr, err := a.transportBuilder()
	if err != nil {
		return err
	}
	result, err := cli.Send(tr, transport.RecipientID(recipient), key, []byte(message))
	if err != nil {
		return err
	}

	a.sentHistory.Record(SentMessage{
		Recipient: recipient,
		MessageID: string(result.MessageID),
		Timestamp: time.Now().UTC(),
		Status:    "sent",
	})
	return nil
}
```

The important architectural separation is preserved:

```text
Selected Contact
├── Public Key
│   └── Used for encryption
│
└── Transport Recipient
    ├── Email
    │   └── Used when email transport is configured
    │
    └── Local Recipient ID
        └── Used when local transport is active
```

The recipient-selection function is:

```go
func (a *App) transportRecipientForContact(contact contacts.Contact) (string, error) {
	if a.emailConfigurationPresent() {
		email := strings.TrimSpace(contact.Email)
		if email == "" {
			return "", fmt.Errorf("contact %q has no email recipient configured for email transport", contact.Name)
		}
		return email, nil
	}
	local := strings.TrimSpace(contact.LocalRecipient)
	if local == "" {
		return "", fmt.Errorf("contact %q has no local recipient ID configured for local transport", contact.Name)
	}
	return local, nil
}
```

---

# 12. Phase 7: Contacts HTTP Workflow

## Contact Import

The Contacts page handles multipart uploads.

The handler:

```go
func (a *App) handleContacts(w http.ResponseWriter, r *http.Request) {
	data := pageData{
		Title:    "Contacts",
		Current:  "contacts",
		Contacts: a.contactsStore.List(),
		Error:    r.URL.Query().Get("error"),
	}
	if r.Method == http.MethodPost {
		if err := r.ParseMultipartForm(1 << 20); err != nil {
			data.Error = fmt.Sprintf("could not read form: %v", err)
		} else {
			file, _, err := r.FormFile("public_identity_file")
			if err != nil {
				data.Error = "public identity JSON file is required"
			} else {
				defer file.Close()
				publicIdentityJSON, readErr := io.ReadAll(file)
				if readErr != nil {
					data.Error = fmt.Sprintf("could not read uploaded file: %v", readErr)
				} else {
					_, importErr := a.contactsStore.ImportPublicIdentity(contacts.ImportInput{
						Name:               r.FormValue("name"),
						PublicIdentityJSON: publicIdentityJSON,
						Email:              r.FormValue("email"),
						LocalRecipient:     r.FormValue("local_recipient"),
					})
					if importErr != nil {
						data.Error = importErr.Error()
					} else {
						data.Success = "Contact imported successfully."
					}
				}
			}
		}
		data.Contacts = a.contactsStore.List()
	}
	a.render(w, "Contacts", contactsPage, data)
}
```

---

## Contact Deletion

The deletion endpoint is:

```go
func (a *App) handleContactDelete(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Redirect(w, r, "/contacts", http.StatusSeeOther)
		return
	}
	if err := r.ParseForm(); err != nil {
		http.Redirect(w, r, "/contacts?error=Could+not+read+delete+request", http.StatusSeeOther)
		return
	}
	id := strings.TrimSpace(r.FormValue("id"))
	if id == "" {
		http.Redirect(w, r, "/contacts?error=Missing+contact+identifier", http.StatusSeeOther)
		return
	}
	deleted, err := a.contactsStore.Delete(id)
	if err != nil {
		http.Redirect(w, r, "/contacts?error=Could+not+delete+contact", http.StatusSeeOther)
		return
	}
	if !deleted {
		http.Redirect(w, r, "/contacts?error=Contact+not+found", http.StatusSeeOther)
		return
	}
	http.Redirect(w, r, "/contacts", http.StatusSeeOther)
}
```

---

# 13. Phase 7: Web Navigation and Templates

## Navigation Change

The Contacts page was added to navigation.

### Before

```html
<nav>
  <a class="{{if eq .Current "inbox"}}active{{end}}" href="/inbox">Inbox</a>
  <a class="{{if eq .Current "compose"}}active{{end}}" href="/compose">Compose</a>
  <a class="{{if eq .Current "sent"}}active{{end}}" href="/sent">Sent</a>
  <a class="{{if eq .Current "identity"}}active{{end}}" href="/identity">Public identity</a>
  <a class="{{if eq .Current "settings"}}active{{end}}" href="/settings">Settings</a>
</nav>
```

### After

```html
<nav>
  <a class="{{if eq .Current "inbox"}}active{{end}}" href="/inbox">Inbox</a>
  <a class="{{if eq .Current "compose"}}active{{end}}" href="/compose">Compose</a>
  <a class="{{if eq .Current "contacts"}}active{{end}}" href="/contacts">Contacts</a>
  <a class="{{if eq .Current "sent"}}active{{end}}" href="/sent">Sent</a>
  <a class="{{if eq .Current "identity"}}active{{end}}" href="/identity">Public identity</a>
  <a class="{{if eq .Current "settings"}}active{{end}}" href="/settings">Settings</a>
</nav>
```

---

## Compose Template

### Before

```html
{{define "page"}}
<section class="intro">
  <div>
    <h1>Compose</h1>
    <p>Write a message; QuantumMail encrypts and serializes it before delivery.</p>
  </div>
</section>

<form class="form" method="post">
  <div class="field">
    <label for="recipient">Recipient routing address or identifier</label>
    <input id="recipient" name="recipient" required>
  </div>

  <div class="field">
    <label for="public_key_file">Recipient public identity file</label>
    <input id="public_key_file" name="public_key_file" placeholder="/path/to/recipient.public.json" required>
    <div class="hint">Use the public JSON exported by the recipient.</div>
  </div>

  <div class="field">
    <label for="message">Message</label>
    <textarea id="message" name="message" required></textarea>
  </div>

  <button type="submit">Encrypt and send</button>
</form>
{{end}}
```

### After

```html
{{define "page"}}
<section class="intro">
  <div>
    <h1>Compose</h1>
    <p>Select a saved contact. QuantumMail uses that contact's stored public identity for encryption and transport recipient for delivery.</p>
  </div>
</section>

{{if .Contacts}}
<form class="form" method="post">
  <div class="field">
    <label for="contact_id">Contact</label>
    <select id="contact_id" name="contact_id" required>
      {{range .Contacts}}
      <option value="{{.ID}}">
        {{.Name}}
        {{if .Email}} | email: {{.Email}}{{end}}
        {{if .LocalRecipient}} | local: {{.LocalRecipient}}{{end}}
      </option>
      {{end}}
    </select>
  </div>

  <div class="field">
    <label for="message">Message</label>
    <textarea id="message" name="message" required></textarea>
  </div>

  <button type="submit">Encrypt and send</button>
</form>
{{else}}
<p class="empty">No contacts yet. Import a public identity on the Contacts page first.</p>
<a class="button" href="/contacts">Open Contacts</a>
{{end}}
{{end}}
```

The old filesystem-path public-key workflow was intentionally removed.

---

## Contacts Template

```html
{{define "page"}}
<section class="intro">
  <div>
    <h1>Contacts</h1>
    <p>Import and store recipients' public identities locally. Contacts contain public key material only.</p>
  </div>
</section>

<form class="form" method="post" enctype="multipart/form-data">
  <div class="field">
    <label for="name">Display name</label>
    <input id="name" name="name" required>
  </div>

  <div class="grid">
    <div class="field">
      <label for="email">Email recipient (for email transport)</label>
      <input id="email" name="email" placeholder="bob@example.com">
    </div>

    <div class="field">
      <label for="local_recipient">Local recipient ID (for local transport)</label>
      <input id="local_recipient" name="local_recipient" placeholder="local">
    </div>
  </div>

  <div class="field">
    <label for="public_identity_file">Public identity JSON file</label>
    <input id="public_identity_file" name="public_identity_file" type="file" accept="application/json" required>
    <div class="hint">Upload the JSON exported from another user's Public identity page.</div>
  </div>

  <button type="submit">Import contact</button>
</form>

{{if .Contacts}}
<div style="margin-top:24px">
  {{range .Contacts}}
  <div class="sent-row">
    <div>
      <strong>{{.Name}}</strong>
      <div class="meta">
        {{if .Email}}Email: {{.Email}} {{end}}
        {{if .LocalRecipient}}Local: {{.LocalRecipient}}{{end}}
      </div>
    </div>

    <form method="post" action="/contacts/delete">
      <input type="hidden" name="id" value="{{.ID}}">
      <button class="button secondary" type="submit">Remove</button>
    </form>
  </div>
  {{end}}
</div>
{{else}}
<p class="empty">No contacts saved yet.</p>
{{end}}
{{end}}
```

---

# 14. Phase 7: Web Tests

## Tests Added and Updated

The web tests were expanded to cover the new contact workflow.

Important helper:

```go
func importSelfContact(t *testing.T, app *App, name, email, localRecipient string) contacts.Contact {
	t.Helper()

	identityJSON, err := app.cliApp.PublicIdentityJSON()
	if err != nil {
		t.Fatalf("PublicIdentityJSON: %v", err)
	}

	contact, err := app.contactsStore.ImportPublicIdentity(contacts.ImportInput{
		Name:               name,
		PublicIdentityJSON: []byte(identityJSON),
		Email:              email,
		LocalRecipient:     localRecipient,
	})
	if err != nil {
		t.Fatalf("ImportPublicIdentity: %v", err)
	}

	return contact
}
```

Multipart request helper:

```go
func multipartContactBody(
	t *testing.T,
	name,
	email,
	localRecipient string,
	identityJSON []byte,
) (string, *bytes.Buffer) {
	t.Helper()

	body := &bytes.Buffer{}
	writer := multipart.NewWriter(body)

	_ = writer.WriteField("name", name)
	_ = writer.WriteField("email", email)
	_ = writer.WriteField("local_recipient", localRecipient)

	part, err := writer.CreateFormFile("public_identity_file", "contact.public.json")
	if err != nil {
		t.Fatalf("CreateFormFile: %v", err)
	}
	if _, err := part.Write(identityJSON); err != nil {
		t.Fatalf("Write identity file: %v", err)
	}
	if err := writer.Close(); err != nil {
		t.Fatalf("writer.Close: %v", err)
	}

	return writer.FormDataContentType(), body
}
```

---

## Route Coverage

The main route-render test changed from:

```go
[]string{"/inbox", "/compose", "/sent", "/identity", "/settings"}
```

to:

```go
[]string{"/inbox", "/compose", "/contacts", "/sent", "/identity", "/settings"}
```

---

## Contact-Based Compose Test

A local round trip became:

```go
contact := importSelfContact(t, app, "Self", "", "local")

form := url.Values{
	"contact_id": {contact.ID},
	"message":    {"hello from the web"},
}
```

instead of writing a public identity JSON to a temporary path and passing that path through Compose.

---

## Compose UI Regression Test

A test was added to ensure the old public-key path workflow does not return:

```go
func TestComposePageUsesContactsAndNoPublicIdentityPathField(t *testing.T) {
	app := newTestApp(t)

	res := httptest.NewRecorder()
	app.Handler().ServeHTTP(
		res,
		httptest.NewRequest(http.MethodGet, "/compose", nil),
	)

	if !strings.Contains(res.Body.String(), "No contacts yet") {
		t.Fatalf("expected empty contacts guidance, got: %s", res.Body.String())
	}
	if strings.Contains(res.Body.String(), "public_key_file") {
		t.Fatal("compose page still renders public identity path field")
	}

	importSelfContact(t, app, "Self", "", "local")

	res = httptest.NewRecorder()
	app.Handler().ServeHTTP(
		res,
		httptest.NewRequest(http.MethodGet, "/compose", nil),
	)

	if !strings.Contains(res.Body.String(), "name=\"contact_id\"") {
		t.Fatalf("compose page is missing contact selector: %s", res.Body.String())
	}
}
```

---

## Stored Public Identity Encryption Test

A test ensured that the selected contact's public identity is actually used for encryption.

The test creates another identity:

```go
otherIdentity, err := identity.New()
if err != nil {
	t.Fatalf("identity.New: %v", err)
}
```

Exports its public identity:

```go
pubPath := filepath.Join(t.TempDir(), "other.public.json")
if err := identity.ExportPublic(pubPath, otherIdentity); err != nil {
	t.Fatalf("ExportPublic: %v", err)
}
pubJSON, err := os.ReadFile(pubPath)
if err != nil {
	t.Fatalf("ReadFile: %v", err)
}
```

Imports it as a contact:

```go
contact, err := app.contactsStore.ImportPublicIdentity(contacts.ImportInput{
	Name:               "Other",
	PublicIdentityJSON: pubJSON,
	LocalRecipient:     "local",
})
if err != nil {
	t.Fatalf("ImportPublicIdentity: %v", err)
}
```

Sends using that contact:

```go
form := url.Values{
	"contact_id": {contact.ID},
	"message":    {"encrypted for other"},
}
```

Then verifies the local identity cannot decrypt the message.

This protects the architectural guarantee:

> Compose encrypts using the selected contact's stored public identity.

---

## Contacts Import and Delete via HTTP

The HTTP workflow was tested:

```go
func TestContactsImportAndDeleteViaHTTP(t *testing.T) {
	app := newTestApp(t)

	identityJSON, err := app.cliApp.PublicIdentityJSON()
	if err != nil {
		t.Fatalf("PublicIdentityJSON: %v", err)
	}

	contentType, body := multipartContactBody(
		t,
		"Bob",
		"bob@example.com",
		"bob-local",
		[]byte(identityJSON),
	)

	res := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodPost, "/contacts", body)
	req.Header.Set("Content-Type", contentType)
	app.Handler().ServeHTTP(res, req)

	if res.Code != http.StatusOK ||
		!strings.Contains(res.Body.String(), "Contact imported successfully") {
		t.Fatalf(
			"expected successful import, status=%d body=%s",
			res.Code,
			res.Body.String(),
		)
	}

	if len(app.contactsStore.List()) != 1 {
		t.Fatalf(
			"expected exactly one contact after import, got %d",
			len(app.contactsStore.List()),
		)
	}

	deleteForm := url.Values{
		"id": {app.contactsStore.List()[0].ID},
	}

	res = httptest.NewRecorder()
	deleteReq := httptest.NewRequest(
		http.MethodPost,
		"/contacts/delete",
		strings.NewReader(deleteForm.Encode()),
	)
	deleteReq.Header.Set(
		"Content-Type",
		"application/x-www-form-urlencoded",
	)
	app.Handler().ServeHTTP(res, deleteReq)

	if res.Code != http.StatusSeeOther {
		t.Fatalf(
			"expected redirect after delete, got status=%d",
			res.Code,
		)
	}

	if len(app.contactsStore.List()) != 0 {
		t.Fatalf(
			"expected zero contacts after delete, got %d",
			len(app.contactsStore.List()),
		)
	}
}
```

---

## Malformed and Private Identity Rejection

The HTTP layer was tested for:

- malformed JSON;
- private identity JSON.

The private identity is created with:

```go
privateID, err := identity.New()
if err != nil {
	t.Fatalf("identity.New: %v", err)
}

privatePath := filepath.Join(t.TempDir(), "private.identity.json")
if err := identity.SaveToFile(privateID, privatePath); err != nil {
	t.Fatalf("SaveToFile: %v", err)
}
```

Then uploaded through the Contacts endpoint.

The expected error contains:

```text
private identity material
```

---

## End-to-End HTTP Smoke Test

A full local flow was tested:

```text
Contacts import
    ↓
Compose
    ↓
Encrypt using saved contact public key
    ↓
Local delivery
    ↓
Inbox retrieval
    ↓
Decrypt
    ↓
Plaintext rendered
```

The test verifies the message:

```text
smoke test local
```

appears after retrieval and decryption.

---

## Transport Recipient Separation

A capture transport was introduced for tests:

```go
type captureTransport struct {
	recipients []transport.RecipientID
}

func (c *captureTransport) Deliver(
	recipient transport.RecipientID,
	payload []byte,
) (transport.MessageID, error) {
	c.recipients = append(c.recipients, recipient)
	return transport.MessageID("capture-id"), nil
}

func (c *captureTransport) Retrieve(
	recipient transport.RecipientID,
) ([]transport.DeliveredMessage, error) {
	return nil, nil
}
```

The test verifies:

```text
Local transport mode
    → contact.LocalRecipient

Email transport mode
    → contact.Email
```

Specifically:

```go
if len(localCapture.recipients) != 1 ||
	string(localCapture.recipients[0]) != "bob-local" {
	t.Fatalf(
		"expected local recipient bob-local, got %+v",
		localCapture.recipients,
	)
}
```

and:

```go
if len(emailCapture.recipients) != 1 ||
	string(emailCapture.recipients[0]) != "bob@example.com" {
	t.Fatalf(
		"expected email recipient bob@example.com, got %+v",
		emailCapture.recipients,
	)
}
```

---

# 15. Phase 7: README Changes

## Before

The local demo workflow said:

```text
1. Start QuantumMail and open the printed URL.
2. Open **Public identity** and download the public JSON.
3. Open **Compose**, enter `local` as the recipient, select the downloaded public identity file, and send a message.
4. Open **Inbox**, refresh, and select the message to read it.
```

## After

The workflow became:

```text
1. Start QuantumMail and open the printed URL.
2. Open **Public identity** and download the public JSON.
3. Open **Contacts**, import the downloaded public JSON as a contact, and set local recipient ID to `local`.
4. Open **Compose**, select the saved contact, and send a message.
5. Open **Inbox**, refresh, and select the message to read it.
```

Documentation was also added:

```text
Contacts are stored locally at `~/.quantummail/contacts.json` and contain only public identity material plus transport recipient hints (email address and/or local recipient ID).
```

---

# 16. Phase 7 Validation

## Initial Test Results

After implementation:

```text
46/46 tests passed (100%, 7 skipped)
```

After further web-test additions:

```text
61/61 tests passed (100%, 7 skipped)
```

---

## Required Validation Sequence

The following commands were run:

```bash
gofmt -w internal/contacts/contacts.go \
  internal/contacts/contacts_test.go \
  internal/identity/persistence.go \
  internal/identity/persistence_test.go \
  internal/web/app.go \
  internal/web/web_test.go

go mod tidy

go test -count=1 ./...

go test -race -count=1 ./...

go vet ./...

go build ./...

git diff --check
```

A subsequent run was performed after fixing issues:

```bash
gofmt -w internal/contacts/contacts_test.go && \
go mod tidy && \
go test -count=1 ./... && \
go test -race -count=1 ./... && \
go vet ./... && \
go build ./... && \
git diff --check
```

The implementation report stated that all required checks passed.

---

# 17. Phase 7 Final Implementation Report

## 1. WHAT CHANGED

Implemented a local contacts/public-identity system and integrated it into the web workflow so Compose no longer requires a filesystem path to a recipient public identity file.

Main changes:

- added:
  - `internal/contacts/contacts.go`;
  - `internal/contacts/contacts_test.go`;
- integrated contacts into:
  - web routing;
  - Compose flow;
- updated:
  - web tests;
  - identity public parsing;
  - README.

---

## 2. CONTACT MODEL AND PERSISTENCE

Contacts are persisted at:

```text
~/.quantummail/contacts.json
```

Persistence behavior:

- missing contacts file loads as empty store;
- store is versioned;
- loaded data is validated;
- writes use temporary file plus rename;
- contact file permissions are restricted to `0600`;
- contact directory creation uses restricted permissions.

Contact fields:

- stable local ID;
- display name;
- public key bytes;
- optional email recipient;
- optional local recipient ID;
- created timestamp;
- updated timestamp.

Duplicate policy:

- case-insensitive duplicate display name is rejected;
- duplicate public identity is rejected.

Deletion:

- removes by contact ID;
- persists the resulting store.

---

## 3. PUBLIC IDENTITY IMPORT

The Contacts page accepts uploaded public identity JSON using multipart form data.

Validation:

- valid public identity JSON succeeds;
- malformed JSON fails;
- private identity JSON explicitly fails.

Contacts persist public key material only.

---

## 4. COMPOSE WORKFLOW

New workflow:

```text
Public Identity
    ↓ download public JSON
Share through ordinary channel
    ↓
Recipient imports JSON into Contacts
    ↓
Compose selects contact
    ↓
Stored public key used for encryption
    ↓
Contact transport recipient selected
    ↓
Delivery
```

The separation remains explicit:

```text
Contact public identity
    → cryptographic recipient

Transport recipient
    → routing target
```

---

## 5. ARCHITECTURE

Package ownership:

```text
internal/contacts
    Contact model
    Persistence
    Duplicate rules
    Import orchestration

internal/identity
    Public/private identity parsing
    Cryptographic key representation

internal/web
    HTTP
    Forms
    Rendering
    Contacts/Compose orchestration

internal/securemessage
    Encryption/decryption boundaries

internal/transport
    Local transport

internal/emailtransport
    Email transport
```

Cryptographic boundaries remained unchanged.

---

## 6. TESTS ADDED OR UPDATED

Coverage included:

### Contacts

- persistence round trip;
- missing store;
- valid public import;
- malformed input rejection;
- private identity rejection;
- duplicate name rejection;
- duplicate public identity rejection;
- deletion.

### Web

- Contacts route rendering;
- contact import;
- contact deletion;
- Compose contact selection;
- absence of old public-key path field;
- missing contact/message validation;
- local Compose/Inbox round trip;
- transport recipient separation;
- selected public identity encryption behavior;
- malformed/private identity HTTP rejection;
- end-to-end HTTP smoke test.

### Identity

- `ParsePublicKey` rejects private identity material.

---

## 7. VALIDATION RESULTS

Required commands:

```bash
go mod tidy
go test -count=1 ./...
go test -race -count=1 ./...
go vet ./...
go build ./...
git diff --check
```

Result:

```text
All commands passed.
```

---

## 8. LIVE EMAIL STATUS

Deterministic/local functionality was tested.

Real SMTP/IMAP provider verification was not performed during this phase.

No claim was made that live provider delivery or retrieval had been verified.

---

## 9. SECURITY CONFIRMATION

Confirmed:

- contacts contain public identity material only;
- private identity material is rejected from contact import;
- cryptographic boundaries remain unchanged;
- transports continue receiving opaque serialized encrypted payloads;
- Public Identity secrecy tests remain intact;
- credentials are not exposed through contacts functionality.

---

## 10. KNOWN LIMITATIONS / DEFERRED WORK

Out of scope:

- global identity directory;
- accounts;
- authentication;
- OAuth;
- DNS/key servers;
- contact synchronization;
- cloud backing;
- cryptographic primitive redesign.

The current identity bootstrap model remains:

```text
Export public identity JSON
    ↓
Share file through ordinary communication
    ↓
Recipient imports file locally
```

---

# 18. Discussion: How Users Share Public Identity JSON

## User Prompt

The user asked:

> The contact page works. I selected the file from the directory once, the question is how will user share these json?

### AI Implementation / Engineering Decision

The proposed simple workflow was accepted.

The user explicitly preferred:

- no sharing links;
- no global public directory;
- no unnecessary identity-discovery infrastructure.

The intended model is simply:

```text
User A
Public Identity page
    ↓
Download public identity JSON
    ↓
Send/share the JSON file through any ordinary channel
    ↓
User B
Contacts page
    ↓
Select/import JSON file
    ↓
Saved local contact
```

The engineering decision was:

> Downloading the public identity JSON and sending it through an existing communication channel is sufficient for the current project scope.

This keeps QuantumMail simpler and avoids prematurely introducing infrastructure such as:

- global directories;
- public identity servers;
- sharing URLs;
- discovery services.

---

# 19. Discussion: Where Contacts Are Saved

## User Prompt

The user asked where contacts are stored after selecting/importing a public identity JSON through the UI.

### AI Implementation

Contacts are persisted locally at:

```text
~/.quantummail/contacts.json
```

More generally, the web application loads the store from:

```go
filepath.Join(dataDir, "contacts.json")
```

In the standard application-data configuration, this resolves to the QuantumMail data directory under the user's home directory.

The imported JSON itself is not retained as an arbitrary uploaded file. Instead, the application:

1. reads the uploaded JSON;
2. validates it as a public identity;
3. extracts the public key bytes;
4. stores the contact metadata and public key in `contacts.json`.

---

# 20. Phase 7 Pre-Commit Verification

## User Prompt

Before moving to Phase 8, the user asked whether Phase 7 should be committed and whether additional verification was required.

### AI Implementation

The answer was yes: Phase 7 should be committed after verification.

The recommended checks were:

```bash
go test -count=1 ./...
go test -race -count=1 ./...
go vet ./...
go build ./...
git diff --check
```

The user provided successful output:

```text
?       quantummail/cmd/demo    [no test files]
?       quantummail/cmd/quantummail     [no test files]
ok      quantummail/internal/cli        0.006s
ok      quantummail/internal/contacts   0.004s
ok      quantummail/internal/emailtransport     0.006s
ok      quantummail/internal/identity   0.009s
ok      quantummail/internal/securemessage      0.007s
ok      quantummail/internal/transport  0.008s
ok      quantummail/internal/web        0.020s
?       quantummail/cmd/demo    [no test files]
?       quantummail/cmd/quantummail     [no test files]
ok      quantummail/internal/cli        1.024s
ok      quantummail/internal/contacts   1.024s
ok      quantummail/internal/emailtransport     1.031s
ok      quantummail/internal/identity   1.032s
ok      quantummail/internal/securemessage      1.031s
ok      quantummail/internal/transport  1.021s
ok      quantummail/internal/web        1.107s
```

Module tidiness was also checked:

```bash
go mod tidy
git diff --exit-code go.mod go.sum
```

Result:

```text
NO OUTPUT
```

This indicated that `go mod tidy` did not introduce uncommitted dependency changes.

---

# 21. Repository Inspection Using `--no-pager`

## User Prompt

The user requested the commands in `--no-pager` form.

### AI Implementation

The repository inspection sequence became:

```bash
git --no-pager status --short
git --no-pager diff --stat
git --no-pager diff --check

git --no-pager diff -- README.md
git --no-pager diff -- internal/identity/persistence.go
git --no-pager diff -- internal/identity/persistence_test.go
git --no-pager diff -- internal/web/app.go
git --no-pager diff -- internal/web/web_test.go
```

The output showed:

```text
 M README.md
 M internal/identity/persistence.go
 M internal/identity/persistence_test.go
 M internal/web/app.go
 M internal/web/web_test.go
?? internal/contacts/
 README.md                             |   7 +-
 internal/identity/persistence.go      |  25 ++++++-
 internal/identity/persistence_test.go |  18 +++++
 internal/web/app.go                   | 122 ++++++++++++++++++++++++++----
 internal/web/web_test.go              | 300 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++-----------
 5 files changed, 410 insertions(+), 62 deletions(-)
```

The untracked contacts directory was inspected separately using:

```bash
git --no-pager diff --no-index /dev/null internal/contacts/contacts.go
git --no-pager diff --no-index /dev/null internal/contacts/contacts_test.go
```

---

# 22. Phase 7 Staging and Commit Workflow

## AI Recommendation

After inspecting all changed files, the staging sequence was:

```bash
git add README.md \
  internal/identity/persistence.go \
  internal/identity/persistence_test.go \
  internal/web/app.go \
  internal/web/web_test.go \
  internal/contacts/contacts.go \
  internal/contacts/contacts_test.go
```

Then inspect exactly what was staged:

```bash
git --no-pager status --short
git --no-pager diff --cached --stat
git --no-pager diff --cached --check
```

Optionally inspect the complete staged patch:

```bash
git --no-pager diff --cached
```

Then commit:

```bash
git commit -m "Add persistent contact management"
```

And push:

```bash
git push origin main
```

Finally verify a clean working tree:

```bash
git --no-pager status --short
```

---

## Staging State Explanation

The user ran the staged inspection commands and got:

```text
 M README.md
 M internal/identity/persistence.go
 M internal/identity/persistence_test.go
 M internal/web/app.go
 M internal/web/web_test.go
?? internal/contacts/
```

The explanation was:

```text
 M
```

means modified but unstaged.

```text
??
```

means untracked and unstaged.

Therefore, no staged diff existed yet.

The user was instructed to run:

```bash
git add README.md \
  internal/identity/persistence.go \
  internal/identity/persistence_test.go \
  internal/web/app.go \
  internal/web/web_test.go \
  internal/contacts/contacts.go \
  internal/contacts/contacts_test.go
```

Then rerun:

```bash
git --no-pager status --short
git --no-pager diff --cached --stat
git --no-pager diff --cached --check
```

Expected staged state:

```text
M  README.md
M  internal/identity/persistence.go
M  internal/identity/persistence_test.go
M  internal/web/app.go
M  internal/web/web_test.go
A  internal/contacts/contacts.go
A  internal/contacts/contacts_test.go
```

---

# 23. Phase 7 Commit

## User Prompt

The user stated they were going to commit.

### AI Implementation

The recommended commands were:

```bash
git commit -m "Add persistent contact management"
git push origin main
```

Then:

```bash
git --no-pager status --short
```

An empty result indicates the working tree is clean after the commit.

The Phase 7 commit represents completion of:

```text
Persistent Contact Management
+
Contact-Based Compose
+
Public Identity Import Validation
```

---

# 24. Repository Check After Commit

## User Prompt

The user requested a repository check:

```text
https://github.com/yorodeb/QuantumMail
```

### AI Implementation

A repository-side inspection was attempted.

The retrieved public repository view appeared stale relative to the Phase 7 code discussed locally, with an older README status still describing:

```text
Current status: Phase 4 - Real Email Transport and Provider Integration.
```

The engineering conclusion was that the public README needed attention during the upcoming polish phase.

A local confirmation workflow was suggested:

```bash
git log -1 --oneline
git status --short
git branch -vv
```

Expected latest commit form:

```text
<hash> Add persistent contact management
```

This led directly to Phase 8 including a documentation-accuracy pass.

---

# 25. Phase 8 Planning

## Engineering Direction

Phase 8 was defined as a **polish and hardening phase**, not a major feature expansion.

The project already contains:

- ML-KEM-based recipient identities;
- encrypted secure messages;
- serialization/deserialization;
- local filesystem transport;
- SMTP/IMAP email transport;
- CLI/application orchestration;
- web UI;
- Inbox;
- Compose;
- Sent history;
- Settings;
- Public Identity export/download;
- persistent local contacts;
- contact-based recipient selection.

The central Phase 8 goal is:

> Make the existing application coherent, intentional, accurate, and robust without expanding into unrelated infrastructure.

---

# 26. Phase 8 Implementation Contract

## User Request

The user requested the Phase 8 implementation prompt in the previously established contract style.

### AI Implementation

```text
You are implementing Phase 8 of QuantumMail.

Your job is to polish and harden the existing application without expanding its scope into new major features.

Before changing anything, inspect the current repository and understand the existing architecture. Do not assume the repository matches an earlier design or phase description.

Repository:
https://github.com/yorodeb/QuantumMail

CURRENT PROJECT STATE

QuantumMail currently has:

- ML-KEM-based recipient identities
- encrypted secure messages
- serialization/deserialization
- local filesystem transport
- SMTP/IMAP email transport
- CLI/application orchestration
- web UI
- Inbox
- Compose
- Sent history
- Settings
- Public Identity export/download
- persistent local contacts
- contact-based recipient selection

Contacts are stored locally and contain:

- a local contact ID
- display name
- recipient public key material only
- optional email recipient
- optional local recipient ID
- timestamps

The current contact workflow is intentionally manual:

1. A user downloads their public identity JSON from the Public Identity page.
2. They share that JSON file with another person through any ordinary communication channel.
3. The recipient imports the JSON file through Contacts.
4. Compose selects a saved contact instead of asking for a public identity filesystem path.

Do NOT add:

- a global public identity directory
- key discovery infrastructure
- accounts
- authentication
- OAuth
- cloud contact synchronization
- contact sharing links
- cryptographic primitive redesign
- new transport protocols

This phase is about making the existing application feel coherent, intentional, and finished.

==================================================
PHASE 8 GOALS
==================================================

Implement a focused polish and hardening pass covering:

1. README and project documentation accuracy
2. Web UI/UX consistency and polish
3. Error handling and user-facing messages
4. Persistence robustness where appropriate
5. Small correctness improvements discovered during inspection
6. Test cleanup and regression coverage
7. Final repository quality

Do not rewrite working subsystems merely for stylistic reasons.

Prefer small, well-justified changes that improve the existing project.

==================================================
1. FIRST: INSPECT THE CURRENT CODEBASE
==================================================

Before implementing anything:

1. Inspect:
   - README.md
   - go.mod
   - cmd/
   - internal/contacts/
   - internal/identity/
   - internal/securemessage/
   - internal/transport/
   - internal/emailtransport/
   - internal/cli/
   - internal/web/

2. Inspect the current test suite.

3. Run the deterministic baseline:

   go test -count=1 ./...

4. Do not begin modifying code until you understand:

   - how identities are created and persisted
   - how public identities are exported
   - how contacts are imported and persisted
   - how Compose chooses a contact
   - the distinction between cryptographic identity and transport recipient
   - how local transport works
   - how email transport is selected/configured
   - how Inbox retrieves and decrypts messages
   - how sent history is persisted
   - how web configuration is persisted

Report the baseline result before implementation.

==================================================
2. README AND DOCUMENTATION
==================================================

Review README.md carefully.

The README must accurately describe the CURRENT project rather than an earlier phase.

Update it where necessary to reflect the actual application, including:

- the current overall status of QuantumMail
- the actual architecture
- the web application workflow
- local and email transport modes
- Public Identity export
- Contacts
- the contact import workflow
- Compose selecting a saved contact
- Inbox and Sent behavior
- the distinction between public identity and transport routing information

The README should make the manual identity-sharing model clear:

A recipient's public identity JSON can simply be downloaded and shared through an ordinary channel, then imported into Contacts.

Do not imply that QuantumMail currently has:

- automatic identity discovery
- a global directory
- authenticated identity verification
- cloud synchronization

Do not document future features as if they already exist.

Keep the README concise and useful. Do not turn it into a massive design document.

If existing development or validation commands are documented, ensure they remain accurate.

==================================================
3. WEB UI AND UX POLISH
==================================================

Review the existing web interface as a complete application.

Improve obvious inconsistencies or rough edges while preserving the existing visual direction.

Inspect all pages together:

- Inbox
- Compose
- Contacts
- Sent
- Public Identity
- Settings

Look specifically for:

- inconsistent wording
- confusing labels
- unclear instructions
- awkward empty states
- inconsistent success/error presentation
- navigation inconsistencies
- unnecessarily technical user-facing language
- missing guidance where a user could reasonably become stuck

Important workflow checks:

PUBLIC IDENTITY
- The page must clearly communicate that this is public information.
- Private identity material must never be displayed.
- Download behavior must remain correct.

CONTACTS
- The import workflow should be understandable.
- The user should understand what the JSON file is.
- The distinction between:
  - public identity
  - email recipient
  - local recipient ID
  should be understandable.

COMPOSE
- The user should understand that selecting a contact determines:
  - which public identity is used for encryption
  - which transport recipient is used for delivery
- The UI should not reintroduce filesystem-path-based public identity selection.

EMPTY STATES
Review every major empty state and make sure it gives the user a useful next action where appropriate.

Do not add JavaScript frameworks or unnecessary frontend complexity.

Keep the application server-rendered and simple.

==================================================
4. ERROR HANDLING
==================================================

Review user-facing error paths, especially around:

- contact import
- malformed public identity files
- private identity file rejection
- duplicate contacts
- missing transport recipient information
- invalid selected contacts
- transport failures
- inbox retrieval/decryption failures
- configuration failures

Improve error messages where they are:

- unclear
- unnecessarily internal
- misleading
- inconsistent with the rest of the UI

Do not expose:

- private keys
- seeds
- shared secrets
- credentials
- SMTP passwords
- unnecessary internal cryptographic details

Errors should be useful without leaking sensitive information.

Preserve existing tests that enforce secrecy guarantees.

==================================================
5. PERSISTENCE ROBUSTNESS REVIEW
==================================================

Review the persistence implementations for:

- contacts
- identity
- configuration
- sent history
- local transport storage

Do not rewrite all persistence code.

Look for concrete correctness issues where an in-memory state change can diverge from persisted state after an error.

For example, inspect operations that mutate memory before persistence succeeds.

If such a concrete issue exists, fix it minimally and safely.

For the contacts store specifically, review:

- Import behavior if persistence fails
- Delete behavior if persistence fails
- atomic write behavior
- temporary-file cleanup
- file permissions
- validation of loaded data

Preserve the existing design unless a specific bug or robustness issue justifies changing it.

Any persistence change must have regression coverage.

==================================================
6. CODE QUALITY
==================================================

Perform a restrained code-quality pass.

Improve:

- misleading names
- duplicated logic where consolidation is clearly beneficial
- stale comments
- comments describing old workflows
- unnecessary complexity introduced during previous phases

Do NOT:

- redesign package boundaries without a concrete reason
- introduce abstractions solely for abstraction's sake
- perform a repository-wide stylistic rewrite
- rename large portions of the project unnecessarily

The goal is clarity and maintainability, not churn.

Run gofmt on all modified Go files.

==================================================
7. TESTS
==================================================

Update tests for every behavior intentionally changed.

Add regression tests for bugs or robustness issues discovered during this phase.

At minimum, preserve coverage for:

IDENTITY
- public identity export does not expose private material
- private identity material is rejected where public identity is expected

CONTACTS
- valid public identity import
- malformed import rejection
- private identity rejection
- duplicate behavior
- persistence
- deletion
- persistence failure behavior if changed during this phase

WEB
- all main routes render
- contact-based Compose workflow remains intact
- no public identity filesystem-path input returns
- empty states remain useful
- transport recipient selection remains separate from encryption identity
- transport failures are not falsely recorded as successful sends
- secrets and credentials are not rendered

LOCAL FLOW
- import/contact
- compose
- encrypt
- deliver
- retrieve
- decrypt

Do not weaken existing tests just to make changes pass.

==================================================
8. SECURITY INVARIANTS
==================================================

The following are non-negotiable:

- Private identity material must never be rendered on the Public Identity page.
- Contacts must store public identity material only.
- Private identity JSON must not be accepted as a contact public identity.
- Public identity remains separate from transport routing information.
- Encryption must use the selected contact's stored public key.
- Transports must continue receiving opaque serialized encrypted payloads.
- Credentials must not appear in rendered pages, logs, or user-facing errors.
- No cryptographic primitive changes.
- No weakening of encryption/decryption boundaries.

Do not claim additional security properties that the implementation does not actually provide.

==================================================
9. SCOPE DISCIPLINE
==================================================

This is a polish phase.

When you encounter something that could become a large new feature, do NOT implement it.

Examples explicitly out of scope:

- contact editing UI, unless a very small existing correctness issue makes it necessary
- global identity directories
- key servers
- public key discovery
- QR-code identity exchange
- accounts
- authentication
- OAuth
- cloud synchronization
- multi-device sync
- provider-specific Sent folder synchronization
- message threading
- attachments
- rich text messages
- cryptographic redesign

Prefer documenting deferred work over silently expanding the phase.

==================================================
10. IMPLEMENTATION PROCESS
==================================================

Work in coherent steps.

For each meaningful step:

1. Inspect the relevant existing code.
2. Explain briefly what you found.
3. Make the smallest change that solves the identified problem.
4. Run focused tests when appropriate.
5. Continue only after the focused change is sound.

Do not make speculative changes.

Do not fabricate missing requirements.

Do not report success until validation has actually been run.

==================================================
11. REQUIRED FINAL VALIDATION
==================================================

Before declaring Phase 8 complete, run:

gofmt -w <all modified Go files>

go mod tidy

git diff --exit-code go.mod go.sum

go test -count=1 ./...

go test -race -count=1 ./...

go vet ./...

go build ./...

git diff --check

Also inspect:

git status --short

git diff --stat

If practical, review the final changed files before completion.

Do not automatically commit or push.

==================================================
12. FINAL REPORT
==================================================

When implementation is complete, provide exactly these sections:

1. WHAT CHANGED
2. README / DOCUMENTATION
3. UI / UX POLISH
4. ERROR HANDLING
5. PERSISTENCE / ROBUSTNESS
6. CODE QUALITY
7. TESTS ADDED OR UPDATED
8. VALIDATION RESULTS
9. SECURITY CONFIRMATION
10. KNOWN LIMITATIONS / DEFERRED WORK

Be precise.

Distinguish between:

- deterministic tests that actually passed
- behavior manually verified
- functionality not tested in this phase

Do not claim live SMTP/IMAP provider verification unless real provider credentials/accounts were actually used during this phase.

The final result should be a cleaner, more coherent, better-documented QuantumMail application—not a larger project with unnecessary new features.
```

---

# 27. Final Project State at End of Archived Conversation

## Completed Before Phase 8

### Phase 1: Secure Message Engine

- hybrid encryption engine;
- Go standard library cryptography;
- ML-KEM-768;
- HKDF-SHA256;
- AES-256-GCM;
- fixed key-derivation information string;
- encrypted-message representation.

### Phase 2: Identity Persistence and Message Serialization

- identity save/load;
- public identity export;
- encrypted message serialization.

### Phase 3: Local Transport and Mailbox Delivery

- filesystem mailbox transport;
- opaque encrypted payload delivery;
- retrieve/deserialize/decrypt flow.

### Phase 4: Real Email Transport and Provider Integration

- SMTP/IMAP transport capability;
- provider-oriented configuration;
- existing transport abstraction preserved.

### Later Web/Application Work

- server-rendered web application;
- Inbox;
- Compose;
- Sent history;
- Settings;
- Public Identity page and download;
- local configuration and history persistence.

### Phase 7: Persistent Contact Management

- local `contacts.json`;
- public identity import;
- explicit private identity rejection;
- duplicate protection;
- contact deletion;
- contact-based Compose;
- separate cryptographic identity and transport routing fields;
- HTTP workflow tests;
- local end-to-end smoke coverage.

---

# 28. Current Architectural Principles

```text
QuantumMail
│
├── internal/identity
│   ├── Identity generation
│   ├── Private identity persistence
│   ├── Public identity export
│   └── Public key parsing
│
├── internal/securemessage
│   ├── Encrypt
│   └── Decrypt
│
├── internal/contacts
│   ├── Persistent local contacts
│   ├── Public key storage
│   └── Transport routing hints
│
├── internal/transport
│   └── Local filesystem delivery
│
├── internal/emailtransport
│   └── SMTP/IMAP delivery and retrieval
│
├── internal/cli
│   └── Application orchestration
│
└── internal/web
    ├── HTTP routes
    ├── Templates
    ├── Contacts workflow
    ├── Compose
    ├── Inbox
    ├── Sent
    ├── Public Identity
    └── Settings
```

Core security/data flow:

```text
Recipient Contact
    │
    ├── Public Key
    │      │
    │      ▼
    │   Encryption
    │
    └── Transport Recipient
           │
           ▼
        Routing
           │
           ▼
    Opaque encrypted payload
           │
           ▼
       Transport
           │
           ▼
        Retrieval
           │
           ▼
      Decryption
```

The intended manual identity-sharing model remains:

```text
User A:
Public Identity
    ↓
Download public JSON
    ↓
Share file through ordinary communication

User B:
Contacts
    ↓
Import public JSON
    ↓
Saved contact
    ↓
Compose
    ↓
Encrypt using stored public key
    ↓
Route using configured transport recipient
```

---

# 29. Next Step

The next implementation phase is **Phase 8: Polish and Hardening**.

Primary targets:

```text
README accuracy
+
UI/UX consistency
+
Clearer user-facing errors
+
Concrete persistence robustness fixes
+
Restrained code cleanup
+
Regression coverage
+
Final validation
```

Explicitly not part of Phase 8:

```text
Global identity directory
Key discovery
Key servers
Accounts
Authentication
OAuth
Cloud sync
QR identity exchange
New transports
Cryptographic redesign
Major feature expansion
```

The intended result is:

> A cleaner, more coherent, better-documented QuantumMail application built by polishing and hardening the architecture already implemented.
