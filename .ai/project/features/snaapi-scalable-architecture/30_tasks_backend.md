# Backend Tasks - SNAAPI Scalable Architecture

## Phase 1: Foundation (Domain Layer)

### Task 1.1: Create Gateway Interfaces
**Priority**: P0
**Effort**: Low
**Dependencies**: None

Create port interfaces for all external microservices:

```
src/Domain/Port/Gateway/
├── EditorialGatewayInterface.php
├── MultimediaGatewayInterface.php
├── SectionGatewayInterface.php
├── TagGatewayInterface.php
├── JournalistGatewayInterface.php
└── MembershipGatewayInterface.php
```

**Acceptance Criteria**:
- [ ] Each interface defines sync and async methods
- [ ] Use Value Objects for IDs (EditorialId, etc.)
- [ ] PHPStan Level 9 passes
- [ ] Documented with PHPDoc

---

### Task 1.2: Migrate Enums to Domain
**Priority**: P0
**Effort**: Low
**Dependencies**: None

Move enums from Infrastructure to Domain:

```
src/Domain/Enum/
├── EditorialType.php      # From Infrastructure/Enum/EditorialTypesEnum
├── MultimediaType.php     # New
├── Site.php               # From Infrastructure/Enum/SitesEnum
└── ClosingMode.php        # From Infrastructure/Enum/ClossingModeEnum
```

**Acceptance Criteria**:
- [ ] PHP 8.1+ enum syntax
- [ ] Backward compatible (same values)
- [ ] Update all usages
- [ ] Tests pass

---

### Task 1.3: Create Domain Exceptions
**Priority**: P0
**Effort**: Low
**Dependencies**: None

```
src/Domain/Exception/
├── EditorialNotFoundException.php
├── EditorialNotPublishedException.php
├── MultimediaNotFoundException.php
└── ServiceUnavailableException.php
```

**Acceptance Criteria**:
- [ ] Extend base exception
- [ ] Include context (ID, service name)
- [ ] HTTP status code mapping

---

## Phase 2: Infrastructure Gateways

### Task 2.1: Implement EditorialHttpGateway
**Priority**: P0
**Effort**: Medium
**Dependencies**: Task 1.1

Wrap existing `QueryEditorialClient` in new Gateway interface:

```php
// src/Infrastructure/Gateway/Http/EditorialHttpGateway.php
final readonly class EditorialHttpGateway implements EditorialGatewayInterface
{
    public function __construct(
        private QueryEditorialClient $client,
    ) {}

    public function findById(EditorialId $id): ?Editorial
    {
        return $this->client->findEditorialById($id->value());
    }

    public function findByIdAsync(EditorialId $id): PromiseInterface
    {
        return $this->client->findEditorialById($id->value(), true);
    }
}
```

**Acceptance Criteria**:
- [ ] Implements EditorialGatewayInterface
- [ ] Wraps existing client (no breaking changes)
- [ ] Unit tests with mocked client
- [ ] Integration test with real client (optional)

---

### Task 2.2: Implement MultimediaHttpGateway
**Priority**: P0
**Effort**: Medium
**Dependencies**: Task 1.1

Same pattern as Editorial gateway.

---

### Task 2.3: Implement SectionHttpGateway
**Priority**: P1
**Effort**: Low
**Dependencies**: Task 1.1

---

### Task 2.4: Implement TagHttpGateway
**Priority**: P1
**Effort**: Low
**Dependencies**: Task 1.1

---

### Task 2.5: Implement JournalistHttpGateway
**Priority**: P1
**Effort**: Low
**Dependencies**: Task 1.1

---

### Task 2.6: Implement MembershipHttpGateway
**Priority**: P1
**Effort**: Low
**Dependencies**: Task 1.1

---

## Phase 3: Gateway Decorators

### Task 3.1: Create CircuitBreakerDecorator
**Priority**: P1
**Effort**: Medium
**Dependencies**: Task 2.1

```php
// src/Infrastructure/Gateway/Decorator/CircuitBreakerDecorator.php
final class CircuitBreakerDecorator implements EditorialGatewayInterface
{
    private const FAILURE_THRESHOLD = 5;
    private const RECOVERY_TIMEOUT = 30;

    public function __construct(
        private readonly EditorialGatewayInterface $inner,
        private readonly CircuitBreakerService $circuitBreaker,
        private readonly string $serviceName,
    ) {}

    public function findById(EditorialId $id): ?Editorial
    {
        return $this->circuitBreaker->execute(
            serviceName: $this->serviceName,
            operation: fn() => $this->inner->findById($id),
            fallback: fn() => null,
        );
    }
}
```

**Acceptance Criteria**:
- [ ] Generic decorator (works with any gateway)
- [ ] Configurable thresholds
- [ ] State tracking (open/closed/half-open)
- [ ] Unit tests for all states

---

### Task 3.2: Create CachedGatewayDecorator
**Priority**: P2
**Effort**: Medium
**Dependencies**: Task 2.1

```php
// src/Infrastructure/Gateway/Decorator/CachedGatewayDecorator.php
final class CachedGatewayDecorator implements EditorialGatewayInterface
{
    public function __construct(
        private readonly EditorialGatewayInterface $inner,
        private readonly CacheInterface $cache,
        private readonly int $ttl = 300,
    ) {}

    public function findById(EditorialId $id): ?Editorial
    {
        $key = sprintf('editorial:%s', $id->value());

        return $this->cache->get($key, fn() => $this->inner->findById($id), $this->ttl);
    }
}
```

**Acceptance Criteria**:
- [ ] Configurable TTL per gateway
- [ ] Cache key generation
- [ ] Bypass for async calls (or cache promises)
- [ ] Unit tests

---

## Phase 4: Application Layer

### Task 4.1: Create EditorialAggregator
**Priority**: P0
**Effort**: Medium
**Dependencies**: Phase 2 complete

```php
// src/Application/Aggregator/EditorialAggregator.php
final readonly class EditorialAggregator
{
    public function __construct(
        private EditorialGatewayInterface $editorialGateway,
        private MultimediaGatewayInterface $multimediaGateway,
        private SectionGatewayInterface $sectionGateway,
        private TagGatewayInterface $tagGateway,
        private JournalistGatewayInterface $journalistGateway,
        private MembershipGatewayInterface $membershipGateway,
    ) {}

    public function aggregate(EditorialId $id): ?AggregatedEditorial
    {
        // Implementation
    }
}
```

**Acceptance Criteria**:
- [ ] Parallel fetching with promises
- [ ] Graceful handling of failed promises
- [ ] Returns AggregatedEditorial value object
- [ ] Unit tests with mocked gateways

---

### Task 4.2: Create GetEditorialByIdQuery Handler
**Priority**: P0
**Effort**: Medium
**Dependencies**: Task 4.1

```
src/Application/Query/GetEditorialById/
├── GetEditorialByIdQuery.php
├── GetEditorialByIdHandler.php
└── GetEditorialByIdResponse.php
```

**Acceptance Criteria**:
- [ ] Query is immutable DTO
- [ ] Handler orchestrates aggregator + transformer
- [ ] Response matches current API structure
- [ ] Unit tests

---

### Task 4.3: Migrate BodyDataTransformer
**Priority**: P0
**Effort**: High
**Dependencies**: Task 4.2

Migrate existing transformers to new structure:

```
src/Application/Transformer/Editorial/
├── EditorialResponseTransformer.php
├── BodyTransformerChain.php
└── Element/
    ├── ElementTransformerInterface.php
    ├── ParagraphTransformer.php
    ├── SubHeadTransformer.php
    ├── PictureTransformer.php
    ├── VideoYoutubeTransformer.php
    └── ... (all 18 transformers)
```

**Acceptance Criteria**:
- [ ] Same output as current transformers
- [ ] Chain of Responsibility pattern
- [ ] Service tags for auto-registration
- [ ] Unit tests for each transformer

---

### Task 4.4: Migrate MediaDataTransformer
**Priority**: P1
**Effort**: Medium
**Dependencies**: Task 4.3

```
src/Application/Transformer/Multimedia/
├── MultimediaTransformerChain.php
└── Type/
    ├── PhotoTransformer.php
    ├── VideoTransformer.php
    └── WidgetTransformer.php
```

---

### Task 4.5: Create Response DTOs
**Priority**: P0
**Effort**: Low
**Dependencies**: None

```
src/Application/DTO/Response/
├── EditorialResponse.php
├── BodyResponse.php
├── BodyElementResponse.php
├── MultimediaResponse.php
├── SectionResponse.php
├── TagResponse.php
└── SignatureResponse.php
```

**Acceptance Criteria**:
- [ ] Readonly classes
- [ ] JSON serializable
- [ ] Match current API structure exactly

---

## Phase 5: Controller Migration

### Task 5.1: Update EditorialController
**Priority**: P0
**Effort**: Low
**Dependencies**: Task 4.2

```php
// src/Infrastructure/Controller/V1/EditorialController.php
#[Route('/v1/editorials')]
final class EditorialController
{
    public function __construct(
        private readonly GetEditorialByIdHandler $handler,
    ) {}

    #[Route('/{id}', methods: ['GET'])]
    public function getById(string $id): JsonResponse
    {
        $query = new GetEditorialByIdQuery(new EditorialId($id));
        $response = ($this->handler)($query);

        return new JsonResponse($response);
    }
}
```

**Acceptance Criteria**:
- [ ] Uses Query Handler directly (simple app, no bus needed)
- [ ] Same route, same response
- [ ] Thin controller
- [ ] Functional test passes

---

### Task 5.2: Create Comparison Tests
**Priority**: P0
**Effort**: Medium
**Dependencies**: Task 5.1

Create tests that compare old vs new implementation output:

```php
public function testResponseMatchesLegacy(): void
{
    $legacyResponse = $this->legacyOrchestrator->execute($request);
    $newResponse = $this->newHandler->__invoke($query);

    $this->assertEquals(
        json_encode($legacyResponse),
        json_encode($newResponse)
    );
}
```

**Acceptance Criteria**:
- [ ] Compare JSON output byte-by-byte
- [ ] Test with multiple editorial types
- [ ] Test edge cases (no multimedia, no tags, etc.)

---

## Phase 6: Cleanup

### Task 6.1: Deprecate Old Orchestrators
**Priority**: P2
**Effort**: Low
**Dependencies**: Phase 5 complete

Add `@deprecated` annotations to old classes.

---

### Task 6.2: Remove Old Code
**Priority**: P3
**Effort**: Medium
**Dependencies**: Task 6.1 + QA approval

Remove deprecated orchestrators and old transformers after validation.

---

### Task 6.3: Update Documentation
**Priority**: P2
**Effort**: Low
**Dependencies**: Phase 5 complete

Update CLAUDE.md with new architecture.

---

## Summary

| Phase | Tasks | Priority | Total Effort |
|-------|-------|----------|--------------|
| 1. Foundation | 3 | P0 | Low |
| 2. Gateways | 6 | P0-P1 | Medium |
| 3. Decorators | 2 | P1-P2 | Medium |
| 4. Application | 5 | P0-P1 | High |
| 5. Migration | 2 | P0 | Medium |
| 6. Cleanup | 3 | P2-P3 | Low |

**Total Tasks**: 21
**Critical Path**: 1.1 → 2.1 → 4.1 → 4.2 → 4.3 → 5.1 → 5.2
