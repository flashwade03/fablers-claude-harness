# Domain Checklist: Web Service

Decision prompts for web service / API / real-time application projects. Each item asks "have you decided?" — not "what should you decide."

## Usage

Walk through each section relevant to the current milestone. Check items that have been decided. Skip sections marked for later milestones.

---

## v0 Decisions (Basic End-to-End Flow)

### Communication
- [ ] Client-server communication method? (request-response / real-time streaming / hybrid)
- [ ] If real-time: what triggers updates? (server push / client poll / event-driven)

### Data
- [ ] Data persistence needed? (in-memory only / file system / database)
- [ ] If database: embedded or external? (SQLite / PostgreSQL / etc.)

### Execution
- [ ] Where does heavy work happen? (in-process / subprocess / external service)
- [ ] Sync or async execution model?

### Tech Stack
- [ ] Server runtime and framework?
- [ ] Frontend framework (if applicable)?
- [ ] Language for each component?

### Constraints
- [ ] What must the system NOT do? (list prohibited approaches)
- [ ] What external dependencies are assumed to exist?

---

## v1 Decisions (Multi-User / Multi-Project)

Skip these until v0 is working.

### Isolation
- [ ] How are users/projects isolated? (directory / database / process)
- [ ] Resource allocation strategy? (static / dynamic / pooled)

### State Management
- [ ] What states can a project/session be in?
- [ ] What triggers state transitions?

### Concurrency
- [ ] Can multiple operations run simultaneously?
- [ ] If yes: per-user, per-project, or global concurrency?

---

## v2 Decisions (Production Stability)

Skip these until v1 is working.

### Failure Handling
- [ ] What happens when a subprocess crashes?
- [ ] What happens when the server restarts?

### Resource Lifecycle
- [ ] How are idle resources cleaned up?
- [ ] What is the shutdown sequence?

### Observability
- [ ] How to detect stuck/zombie processes?
- [ ] What health signals matter?
