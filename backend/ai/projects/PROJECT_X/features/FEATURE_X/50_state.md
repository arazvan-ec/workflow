# Feature State: FEATURE_X

**Feature ID**: FEATURE_X
**Feature Name**: [Nombre del feature]
**Workflow**: default.yaml
**Created**: 2026-01-15
**Last Updated**: 2026-01-15 10:00:00 UTC

---

## 📊 Overall Status

**Current Stage**: planning
**Overall Progress**: 0% (0/4 roles completed)

---

## 👤 Planner

**Status**: PENDING
**Last Updated**: 2026-01-15 10:00:00 UTC
**Updated By**: [Claude instance ID or human]

### Current Task
- Define feature
- Create contracts
- Breakdown tasks

### Completed Tasks
- (none)

### Blocked By
- (none)

### Next Steps
1. Read all rules (global, DDD, project-specific)
2. Create FEATURE_X.md
3. Create 30_tasks.md
4. Update status to COMPLETED

### Notes
- Waiting to start

---

## 💻 Backend

**Status**: PENDING
**Last Updated**: 2026-01-15 10:00:00 UTC
**Updated By**: [Claude instance ID or human]

### Current Task
- Waiting for planning to complete

### Completed Tasks
- (none)

### Blocked By
- Planning not completed yet

### Next Steps
1. Wait for planner status: COMPLETED
2. Read FEATURE_X.md and 30_tasks.md
3. Implement backend according to DDD
4. Write tests
5. Update status to COMPLETED

### Technical Notes
- (none)

### Files Modified
- (none)

---

## 🎨 Frontend

**Status**: PENDING
**Last Updated**: 2026-01-15 10:00:00 UTC
**Updated By**: [Claude instance ID or human]

### Current Task
- Waiting for planning to complete

### Completed Tasks
- (none)

### Blocked By
- Planning not completed yet

### Dependencies
- Backend API: NOT_READY (will mock if needed)

### Next Steps
1. Wait for planner status: COMPLETED
2. Read FEATURE_X.md and 30_tasks.md
3. Check backend status
4. If backend not ready: mock API and set status to WAITING_API
5. Implement UI
6. Write tests
7. Update status to COMPLETED

### Technical Notes
- (none)

### Files Modified
- (none)

---

## 🧪 QA

**Status**: PENDING
**Last Updated**: 2026-01-15 10:00:00 UTC
**Updated By**: [Claude instance ID or human]

### Current Task
- Waiting for backend and frontend to complete

### Completed Tasks
- (none)

### Blocked By
- Backend not completed
- Frontend not completed

### Next Steps
1. Wait for backend status: COMPLETED
2. Wait for frontend status: COMPLETED
3. Review all code
4. Execute tests
5. Validate acceptance criteria
6. Create QA report
7. Set status to APPROVED or REJECTED

### Review Checklist
- [ ] Backend code reviewed
- [ ] Frontend code reviewed
- [ ] All tests executed
- [ ] Acceptance criteria validated
- [ ] No critical issues found

### Issues Found
- (none yet)

---

## 📝 Decision Log

### [YYYY-MM-DD] Decision Title

**Context**: Why this decision was needed

**Decision**: What was decided

**Impact**: What this affects

**Made By**: Planner

---

## 🔄 Status History

| Date | Role | From | To | Reason |
|------|------|------|-----|--------|
| 2026-01-15 10:00 | (all) | - | PENDING | Feature initialized |

---

## 📌 Notes and Communication

### General Notes
- Feature initialized, waiting for planning to start

### Inter-role Communication
(Use this section for messages between roles)

---

**How to Update This File**:

1. Find your role section above
2. Update your status (PENDING, IN_PROGRESS, BLOCKED, WAITING_API, COMPLETED, APPROVED, REJECTED)
3. Update "Last Updated" timestamp
4. Update "Current Task" with what you're doing now
5. Add completed tasks to "Completed Tasks"
6. Document any blocks in "Blocked By"
7. Add technical notes or decisions
8. Add entry to "Status History" table
9. Commit and push

**Status Values**:
- `PENDING`: Not started yet
- `IN_PROGRESS`: Currently working on it
- `BLOCKED`: Stuck, need help or clarification
- `WAITING_API`: (Frontend only) Waiting for backend API, using mocks
- `COMPLETED`: Done and ready for next stage
- `APPROVED`: (QA only) Feature approved, ready for production
- `REJECTED`: (QA only) Feature has issues, needs fixes
