# Project-Specific Rules (Template)

**Project**: [Your Project Name]
**Last Updated**: [Date]

---

## Purpose

This file contains rules specific to YOUR project. Copy this template and customize it for each project where you install the multi-agent-workflow plugin.

---

## Tech Stack

### Backend
- **Framework**: [e.g., Symfony 6.4, Laravel 10, Express.js]
- **Language**: [e.g., PHP 8.2, TypeScript 5, Python 3.11]
- **Database**: [e.g., PostgreSQL 15, MySQL 8, MongoDB]
- **Cache**: [e.g., Redis, Memcached]
- **Queue**: [e.g., RabbitMQ, Redis, SQS]

### Frontend
- **Framework**: [e.g., React 18, Vue 3, Angular 17]
- **Language**: [e.g., TypeScript 5, JavaScript ES2022]
- **State Management**: [e.g., Redux, Zustand, Pinia]
- **UI Library**: [e.g., Material-UI, Chakra UI, Tailwind CSS]
- **Testing**: [e.g., Jest, Vitest, Cypress]

### Infrastructure
- **Hosting**: [e.g., AWS, GCP, Azure, Vercel]
- **CI/CD**: [e.g., GitHub Actions, GitLab CI, Jenkins]
- **Containers**: [e.g., Docker, Kubernetes]

---

## Architecture Patterns

### Backend Architecture
```
[Describe your backend architecture]

Example for DDD:
src/
├── Domain/           # Business logic, entities, value objects
├── Application/      # Use cases, DTOs, application services
└── Infrastructure/   # Controllers, repositories, external services
```

### Frontend Architecture
```
[Describe your frontend architecture]

Example:
src/
├── components/       # Reusable UI components
├── features/         # Feature-specific modules
├── hooks/           # Custom React hooks
├── services/        # API clients
└── utils/           # Helper functions
```

---

## Code Conventions

### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Files (Backend) | PascalCase | `UserRepository.php` |
| Files (Frontend) | PascalCase | `UserCard.tsx` |
| Classes | PascalCase | `CreateUserUseCase` |
| Functions | camelCase | `validateEmail()` |
| Variables | camelCase | `$userRepository` |
| Constants | UPPER_SNAKE | `MAX_LOGIN_ATTEMPTS` |
| Database Tables | snake_case | `user_sessions` |
| API Endpoints | kebab-case | `/api/user-profiles` |

### File Structure Rules

- One class per file
- File name matches class name
- Tests in parallel structure (`src/` → `tests/`)
- Maximum file length: 300 lines (consider splitting)

---

## API Conventions

### URL Structure
```
/api/v1/{resource}          # Collection
/api/v1/{resource}/{id}     # Single resource
/api/v1/{resource}/{id}/{sub-resource}  # Nested resource
```

### HTTP Methods
- `GET` - Read (no side effects)
- `POST` - Create new resource
- `PUT` - Full update
- `PATCH` - Partial update
- `DELETE` - Remove resource

### Response Format
```json
{
  "data": { ... },
  "meta": {
    "pagination": { ... }
  }
}
```

### Error Format
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Human-readable message",
    "details": [ ... ]
  }
}
```

---

## Testing Requirements

### Backend
- Unit test coverage: > 80%
- Integration test coverage: > 60%
- All Use Cases must have tests
- All Domain entities must have tests

### Frontend
- Component test coverage: > 70%
- Critical paths must have E2E tests
- All forms must have validation tests
- Responsive testing at 375px, 768px, 1024px

---

## Security Requirements

### Authentication
- [e.g., JWT with refresh tokens]
- [e.g., OAuth2 for third-party]
- [e.g., Session-based for admin]

### Authorization
- [e.g., Role-based (RBAC)]
- [e.g., Attribute-based (ABAC)]
- [e.g., Resource-based permissions]

### Data Protection
- [e.g., Encrypt PII at rest]
- [e.g., HTTPS required]
- [e.g., Rate limiting on auth endpoints]

---

## Performance Requirements

### Backend
- API response time: < 200ms (p95)
- Database queries: < 50ms (p95)
- No N+1 queries

### Frontend
- First Contentful Paint: < 1.5s
- Lighthouse Performance: > 90
- Bundle size: < 500KB (gzipped)

---

## Reference Code

### Backend Patterns to Follow
| Pattern | Location | Description |
|---------|----------|-------------|
| Entity | `src/Domain/User/Entity/User.php` | How to create entities |
| Value Object | `src/Domain/User/ValueObject/Email.php` | How to create VOs |
| Repository | `src/Infrastructure/Repository/UserRepository.php` | Repository pattern |
| Use Case | `src/Application/UseCase/CreateUserUseCase.php` | Use case structure |
| Controller | `src/Infrastructure/HTTP/Controller/UserController.php` | Thin controllers |

### Frontend Patterns to Follow
| Pattern | Location | Description |
|---------|----------|-------------|
| Component | `src/components/UserCard.tsx` | Component structure |
| Form | `src/components/LoginForm.tsx` | Form with validation |
| API Service | `src/services/userService.ts` | API client pattern |
| Custom Hook | `src/hooks/useAuth.ts` | Hook pattern |

---

## Deployment

### Environments
- **Development**: `dev.example.com`
- **Staging**: `staging.example.com`
- **Production**: `example.com`

### Deployment Process
1. [Describe your deployment process]
2. [e.g., Create PR → Code Review → Merge → Auto-deploy to staging]
3. [e.g., Manual approval for production]

---

## Contact

### Tech Lead
[Name and contact for technical decisions]

### Product Owner
[Name and contact for product decisions]

---

**Note**: This file should be customized for each project. Delete this note and the placeholders when configuring for your project.
