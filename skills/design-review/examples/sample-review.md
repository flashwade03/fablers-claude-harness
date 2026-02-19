# Sample Review Output

This example demonstrates a review of a hypothetical chat application design document.

---

## Design Review

**Grade: C** | **Score: 58**

채팅 기능 설계에 핵심 결정은 잘 잡혀있으나, 의사코드 포함과 v0에 불필요한 오프라인 동기화 설계가 문제.

### Axis Scores

| Axis | Grade | Points |
|------|-------|--------|
| Decision Purity | FAIL | 0 |
| Rationale Presence | PASS | 2 |
| Milestone Scope | WARN | 1 |
| Context Budget | PASS | 2 |
| Constraint Quality | PASS | 2 |
| CLAUDE.md Alignment | WARN | 1 |

### Feedback

#### Decision Purity: FAIL

> ```typescript
> async function sendMessage(userId: string, roomId: string, content: string) {
>   const message = await db.createMessage({ userId, roomId, content });
>   broadcastToRoom(roomId, { type: 'new_message', payload: message });
> }
> ```

**Problem**: 함수 시그니처와 구현 코드가 설계 문서에 포함. Decisions Only 원칙 위반.
**Fix**: 이 코드 블록 전체를 삭제하고 다음으로 대체: "메시지 전송 시 DB 저장 후 해당 채팅방에 실시간 전파한다 — because 모든 참여자가 즉시 확인해야 하므로"

#### Milestone Scope: WARN

> ## 오프라인 동기화
> 클라이언트가 재접속 시 마지막 수신 메시지 이후의 모든 메시지를 동기화한다.

**Problem**: v0 설계 문서에 오프라인 동기화가 포함. 이는 v1 이후의 안정성 기능.
**Fix**: "Out of scope" 섹션으로 이동: "오프라인 동기화 — v1에서 결정"

#### CLAUDE.md Alignment: WARN

**Problem**: 설계에서 "실시간 통신은 WebSocket 기반"으로 결정했으나 CLAUDE.md 기술 스택에 WebSocket 언급 없음.
**Fix**: CLAUDE.md 기술 스택 섹션에 "실시간: WebSocket" 한 줄 추가.

### Action Items
1. sendMessage 의사코드 삭제 → 결정 문장으로 대체
2. 오프라인 동기화 섹션을 Out of scope로 이동
3. CLAUDE.md 기술 스택에 WebSocket 반영
