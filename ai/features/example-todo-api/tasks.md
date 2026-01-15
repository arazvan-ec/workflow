# Tasks: TODO API Feature

**Feature**: example-todo-api
**Status**: Template/Example

## Implementation Tasks

### Phase 1: Setup & Data Model
- [ ] Create Todo type/interface
  - Properties: id, title, description, completed, createdAt, updatedAt
- [ ] Setup in-memory storage (array)
- [ ] Create ID generator (auto-increment)

### Phase 2: CRUD Endpoints

#### GET /todos
- [ ] Implement endpoint handler
- [ ] Return array of all todos
- [ ] Return 200 OK

#### GET /todos/:id
- [ ] Implement endpoint handler
- [ ] Parse ID parameter
- [ ] Find todo by ID
- [ ] Return 200 OK if found
- [ ] Return 404 Not Found if not found

#### POST /todos
- [ ] Implement endpoint handler
- [ ] Parse request body
- [ ] Validate required fields (title)
- [ ] Create new todo with generated ID
- [ ] Add to storage
- [ ] Return 201 Created with created todo
- [ ] Return 400 Bad Request if validation fails

#### PUT /todos/:id
- [ ] Implement endpoint handler
- [ ] Parse ID parameter
- [ ] Find todo by ID
- [ ] Parse request body (partial update)
- [ ] Update todo fields
- [ ] Update `updatedAt` timestamp
- [ ] Return 200 OK with updated todo
- [ ] Return 404 Not Found if todo doesn't exist
- [ ] Return 400 Bad Request if validation fails

#### DELETE /todos/:id
- [ ] Implement endpoint handler
- [ ] Parse ID parameter
- [ ] Find and remove todo by ID
- [ ] Return 204 No Content
- [ ] Return 404 Not Found if todo doesn't exist

### Phase 3: Error Handling
- [ ] Implement 400 Bad Request responses
- [ ] Implement 404 Not Found responses
- [ ] Implement 500 Internal Server Error fallback
- [ ] Ensure all errors return JSON with error message

### Phase 4: Testing (Optional)
- [ ] Manual testing with curl/Postman
- [ ] Test all endpoints
- [ ] Test error cases

## Technical Notes

**Framework**: Choose any (Express, Fastify, native Node.js, etc.)

**Storage**: In-memory array is sufficient for this example
```javascript
let todos = [];
let nextId = 1;
```

**Error format**:
```json
{
  "error": "Error message here"
}
```

**Success responses**: Always JSON format

## Acceptance Criteria

- [ ] All 5 endpoints implemented (GET all, GET one, POST, PUT, DELETE)
- [ ] Proper HTTP status codes (200, 201, 204, 400, 404)
- [ ] Request/response bodies are JSON
- [ ] Input validation works (required fields checked)
- [ ] Error responses include meaningful messages
- [ ] Code is clean and commented where needed

## Estimated Time

- Setup & Data Model: 10 minutes
- CRUD Endpoints: 30 minutes
- Error Handling: 10 minutes
- Testing: 10 minutes

**Total**: ~1 hour
