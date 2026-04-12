# Sample Review Output

This example demonstrates a review of a hypothetical chat application design document.

---

## Design Review

**Grade: C** | **Score: 67**

채팅 기능 설계에 핵심 결정은 잘 잡혀있으나, 의사코드 포함과 v0에 불필요한 오프라인 동기화 설계가 문제.

### Axis Scores

| Axis | Grade | Points |
|------|-------|--------|
| Decision Purity | FAIL | 0 |
| Rationale Presence | PASS | 2 |
| Decision Maturity | WARN | 1 |
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

#### Decision Maturity: WARN

> ## 오프라인 동기화
> 클라이언트가 재접속 시 마지막 수신 메시지 이후의 모든 메시지를 동기화한다 — because 네트워크 불안정 시 메시지 유실 방지.

**Problem**: 오프라인 동기화는 아직 경험하지 않은 미래 가정에 기반한 후보 항목인데 "because" 근거가 달려 확정 결정처럼 보임.
**Fix**: "v0 이후 검토 방향" 섹션으로 이동하고 근거 제거: "오프라인 동기화"

#### CLAUDE.md Alignment: WARN

**Problem**: CLAUDE.md에 설계 문서 링크가 없음. 설계 결정의 참조 경로가 불명확.
**Fix**: CLAUDE.md에 설계 문서 테이블 추가 (문서명 + 참조 시점).

### Action Items
1. sendMessage 의사코드 삭제 → 결정 문장으로 대체
2. 오프라인 동기화를 "v0 이후 검토 방향"으로 이동, 근거 제거
3. CLAUDE.md에 설계 문서 링크 테이블 추가
