# Sample Design Output

This example demonstrates a completed design document for a hypothetical real-time chat feature, following all 5 principles.

---

# Real-Time Chat — v0

## Goal

Deliver 1:1 and group text messaging with real-time delivery for a small team (< 50 users).

## Tech Stack

- **Server**: Node.js + Express — because existing backend is Express-based
- **Real-time**: WebSocket (ws library) — because user decision: low-latency bidirectional communication needed
- **Database**: PostgreSQL — because already in use for user data; adding chat tables avoids a new dependency
- **Auth**: Existing JWT middleware — because reusing current auth avoids scope creep

## Architectural Decisions

- **Connection model**: One persistent WebSocket connection per authenticated user — because polling adds unnecessary latency for < 50 users
- **Message persistence**: All messages stored in DB before broadcasting — because message history is required and write-first prevents data loss on disconnect
- **Room model**: Each conversation is a "room" with a participant list — because this abstracts 1:1 and group chat into a single model
- **Delivery guarantee**: At-most-once delivery for v0 — because retry/ack adds complexity; acceptable tradeoff for small team where missed messages can be re-fetched on reconnect

## Constraints

- Must: Messages must be persisted before delivery (no fire-and-forget)
- Must: Only authenticated users can connect via WebSocket
- Must not: No file attachments in v0 (text only)
- Must not: No end-to-end encryption in v0

## Scope

**In scope**: 1:1 messaging, group rooms (create/join/leave), message history, real-time delivery, read status

**Out of scope**: File sharing, message editing/deletion, push notifications, message search

## v0 이후 검토 방향 (확정 아님 — v0 사용 경험 후 결정)

- Offline sync (reconnection message catch-up)
- Push notifications for mobile
- Message search with full-text index
- File attachment support
