# Example Feature: TODO API

**Status**: Template/Example
**Complexity**: Simple
**Estimated Time**: 1-2 hours for complete workflow

## Overview

A simple REST API for managing TODO items. This serves as an example to demonstrate the Claude Code parallel workflow system.

## Objectives

- Create a functional REST API with CRUD operations
- Demonstrate the workflow from Planning → Implementation → Review
- Show how roles communicate via files
- Provide a working example for learning the system

## API Specification

### Endpoints

#### GET /todos
- **Description**: List all TODO items
- **Response**: Array of Todo objects
- **Status Codes**: 200 OK

#### GET /todos/:id
- **Description**: Get a single TODO item by ID
- **Parameters**: `id` (integer)
- **Response**: Todo object
- **Status Codes**: 200 OK, 404 Not Found

#### POST /todos
- **Description**: Create a new TODO item
- **Request Body**:
  ```json
  {
    "title": "string (required)",
    "description": "string (optional)"
  }
  ```
- **Response**: Created Todo object
- **Status Codes**: 201 Created, 400 Bad Request

#### PUT /todos/:id
- **Description**: Update an existing TODO item
- **Parameters**: `id` (integer)
- **Request Body**:
  ```json
  {
    "title": "string (optional)",
    "description": "string (optional)",
    "completed": "boolean (optional)"
  }
  ```
- **Response**: Updated Todo object
- **Status Codes**: 200 OK, 404 Not Found, 400 Bad Request

#### DELETE /todos/:id
- **Description**: Delete a TODO item
- **Parameters**: `id` (integer)
- **Response**: 204 No Content
- **Status Codes**: 204 No Content, 404 Not Found

### Data Model

**Todo**
```typescript
{
  id: number,           // Auto-incremented, unique
  title: string,        // Required, max 200 chars
  description: string,  // Optional, max 1000 chars
  completed: boolean,   // Default: false
  createdAt: Date,      // Timestamp of creation
  updatedAt: Date       // Timestamp of last update
}
```

## Requirements

### Functional
- ✅ All 5 CRUD endpoints must be implemented
- ✅ Data validation on POST and PUT
- ✅ Proper HTTP status codes
- ✅ JSON request/response format
- ✅ In-memory storage (no database needed for example)

### Non-Functional
- **Performance**: Response time < 100ms for in-memory operations
- **Code Quality**: Clean, readable code with comments where necessary
- **Error Handling**: Graceful error responses with meaningful messages
- **Maintainability**: Modular code structure

## Acceptance Criteria

- [ ] GET /todos returns array of all todos
- [ ] GET /todos/:id returns single todo or 404
- [ ] POST /todos creates new todo with auto-generated ID
- [ ] POST /todos validates required fields (title)
- [ ] PUT /todos/:id updates existing todo
- [ ] PUT /todos/:id returns 404 if todo doesn't exist
- [ ] DELETE /todos/:id removes todo
- [ ] DELETE /todos/:id returns 404 if todo doesn't exist
- [ ] All endpoints return proper Content-Type: application/json
- [ ] Error responses include meaningful error messages

## Technical Considerations

### Architecture
- Simple REST API (no framework required, can use Express, Fastify, etc.)
- In-memory storage (JavaScript array)
- Single file is acceptable for this example

### Storage
```javascript
// In-memory storage example
let todos = [];
let nextId = 1;
```

### Error Handling
- 400 Bad Request: Invalid input data
- 404 Not Found: Todo ID doesn't exist
- 500 Internal Server Error: Unexpected errors

## Out of Scope

This example explicitly does NOT include:
- Database persistence (use in-memory array)
- Authentication/Authorization
- Rate limiting
- CORS configuration
- Unit tests (though you can add them if you want)
- Docker/deployment configuration
- Frontend UI

## Notes for Learners

This feature is intentionally simple to focus on **learning the workflow system**, not the complexity of the feature itself.

**What you'll learn:**
1. How Planner defines a feature
2. How Backend Developer reads the definition and implements
3. How QA reviews the implementation
4. How roles communicate via files
5. How state synchronization works with Git

**Estimated timeline:**
- Planning: 10-15 minutes
- Implementation: 30-45 minutes
- Review: 15-20 minutes

**Total**: 1-1.5 hours for complete workflow cycle
