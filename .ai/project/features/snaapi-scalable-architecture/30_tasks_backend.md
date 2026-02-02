# Backend Tasks - SNAAPI Pipeline + Normalizers Architecture

> **Architecture**: Pipeline (enrichment) + Symfony Normalizers (transformation)
> **Decision Record**: See `05_architecture_decision.md`

---

## Phase 1: Foundation (Interfaces & Context)

### Task 1.1: Create Gateway Interfaces
**Priority**: P0 | **Effort**: Low | **Files**: 6 new

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

```php
interface EditorialGatewayInterface
{
    public function findById(string $id): ?Editorial;
    public function findByIdAsync(string $id): PromiseInterface;
}
```

**Acceptance Criteria**:
- [ ] Each interface has sync and async methods
- [ ] PHPStan Level 9 passes
- [ ] No implementation yet (just interfaces)

---

### Task 1.2: Create EditorialContext (Pipeline DTO)
**Priority**: P0 | **Effort**: Low | **Files**: 1 new

The mutable DTO that travels through the pipeline:

```php
// src/Application/Pipeline/EditorialContext.php
final class EditorialContext
{
    private array $data = [];

    public function __construct(
        private readonly string $editorialId,
    ) {}

    public function editorialId(): string { return $this->editorialId; }

    public function set(string $key, mixed $value): void
    {
        $this->data[$key] = $value;
    }

    public function get(string $key, mixed $default = null): mixed
    {
        return $this->data[$key] ?? $default;
    }

    public function has(string $key): bool
    {
        return isset($this->data[$key]);
    }

    public function editorial(): ?Editorial { return $this->get('editorial'); }
    public function multimedia(): ?Multimedia { return $this->get('multimedia'); }
    public function section(): ?Section { return $this->get('section'); }
    public function tags(): array { return $this->get('tags', []); }
    public function journalists(): array { return $this->get('journalists', []); }
}
```

**Acceptance Criteria**:
- [ ] Immutable editorialId, mutable data
- [ ] Type-safe getters for common data
- [ ] Unit tests

---

### Task 1.3: Create EnricherInterface
**Priority**: P0 | **Effort**: Low | **Files**: 1 new

```php
// src/Application/Pipeline/EnricherInterface.php
interface EnricherInterface
{
    /**
     * Priority determines execution order (higher = earlier)
     */
    public function priority(): int;

    /**
     * Whether this enricher should run for this context
     */
    public function supports(EditorialContext $context): bool;

    /**
     * Enrich the context with data (mutates context)
     */
    public function enrich(EditorialContext $context): void;
}
```

**Acceptance Criteria**:
- [ ] Simple interface with 3 methods
- [ ] Priority for ordering
- [ ] supports() for conditional execution

---

### Task 1.4: Create EnrichmentPipeline
**Priority**: P0 | **Effort**: Medium | **Files**: 1 new

```php
// src/Application/Pipeline/EnrichmentPipeline.php
final class EnrichmentPipeline
{
    /** @var EnricherInterface[] */
    private array $enrichers = [];

    public function __construct(iterable $enrichers)
    {
        $this->enrichers = iterator_to_array($enrichers);
        usort($this->enrichers, fn($a, $b) => $b->priority() <=> $a->priority());
    }

    public function process(EditorialContext $context): EditorialContext
    {
        foreach ($this->enrichers as $enricher) {
            if ($enricher->supports($context)) {
                try {
                    $enricher->enrich($context);
                } catch (Throwable $e) {
                    // Log and continue - graceful degradation
                    $context->set('errors.' . get_class($enricher), $e->getMessage());
                }
            }
        }
        return $context;
    }
}
```

**Acceptance Criteria**:
- [ ] Enrichers injected via tagged iterator
- [ ] Ordered by priority
- [ ] Graceful error handling (continue on failure)
- [ ] Unit tests with mocked enrichers

---

## Phase 2: Gateway Implementations

### Task 2.1: Implement EditorialHttpGateway
**Priority**: P0 | **Effort**: Low | **Files**: 1 new

```php
// src/Infrastructure/Gateway/Http/EditorialHttpGateway.php
final readonly class EditorialHttpGateway implements EditorialGatewayInterface
{
    public function __construct(
        private QueryEditorialClient $client,  // Existing client
    ) {}

    public function findById(string $id): ?Editorial
    {
        return $this->client->findEditorialById($id);
    }

    public function findByIdAsync(string $id): PromiseInterface
    {
        return $this->client->findEditorialById($id, true);
    }
}
```

**Acceptance Criteria**:
- [ ] Wraps existing `QueryEditorialClient`
- [ ] No logic changes, just adapter
- [ ] Unit test with mocked client

---

### Task 2.2-2.6: Implement Other Gateways
**Priority**: P1 | **Effort**: Low each | **Files**: 5 new

Same pattern for:
- `MultimediaHttpGateway`
- `SectionHttpGateway`
- `TagHttpGateway`
- `JournalistHttpGateway`
- `MembershipHttpGateway`

---

## Phase 3: Enrichers (Pipeline Steps)

### Task 3.1: Create EditorialEnricher
**Priority**: P0 | **Effort**: Low | **Files**: 1 new

```php
// src/Application/Pipeline/Enricher/EditorialEnricher.php
final readonly class EditorialEnricher implements EnricherInterface
{
    public function __construct(
        private EditorialGatewayInterface $gateway,
    ) {}

    public function priority(): int { return 100; } // First

    public function supports(EditorialContext $context): bool
    {
        return true; // Always runs
    }

    public function enrich(EditorialContext $context): void
    {
        $editorial = $this->gateway->findById($context->editorialId());

        if ($editorial === null || !$editorial->isVisible()) {
            throw new EditorialNotFoundException($context->editorialId());
        }

        $context->set('editorial', $editorial);
    }
}
```

**Acceptance Criteria**:
- [ ] Highest priority (runs first)
- [ ] Throws if not found/not visible
- [ ] Unit test with mocked gateway

---

### Task 3.2: Create MultimediaEnricher
**Priority**: P0 | **Effort**: Low | **Files**: 1 new

```php
// src/Application/Pipeline/Enricher/MultimediaEnricher.php
final readonly class MultimediaEnricher implements EnricherInterface
{
    public function __construct(
        private MultimediaGatewayInterface $gateway,
    ) {}

    public function priority(): int { return 90; }

    public function supports(EditorialContext $context): bool
    {
        return $context->editorial()?->hasMultimedia() ?? false;
    }

    public function enrich(EditorialContext $context): void
    {
        $editorial = $context->editorial();
        $multimedia = $this->gateway->findById($editorial->multimediaId());
        $context->set('multimedia', $multimedia);
    }
}
```

---

### Task 3.3: Create SectionEnricher
**Priority**: P1 | **Effort**: Low | **Files**: 1 new

---

### Task 3.4: Create TagsEnricher
**Priority**: P1 | **Effort**: Low | **Files**: 1 new

---

### Task 3.5: Create JournalistsEnricher
**Priority**: P1 | **Effort**: Low | **Files**: 1 new

---

### Task 3.6: Create MembershipEnricher
**Priority**: P1 | **Effort**: Low | **Files**: 1 new

---

### Task 3.7: Create AsyncBatchEnricher (Optimization)
**Priority**: P2 | **Effort**: Medium | **Files**: 1 new

Optional: Batch async calls for performance:

```php
// src/Application/Pipeline/Enricher/AsyncBatchEnricher.php
final class AsyncBatchEnricher implements EnricherInterface
{
    public function priority(): int { return 80; } // After editorial

    public function enrich(EditorialContext $context): void
    {
        $editorial = $context->editorial();

        $promises = [
            'multimedia' => $this->multimediaGateway->findByIdAsync($editorial->multimediaId()),
            'section' => $this->sectionGateway->findByIdAsync($editorial->sectionId()),
            'tags' => $this->tagGateway->findByIdsAsync($editorial->tagIds()),
            'journalists' => $this->journalistGateway->findByIdsAsync($editorial->journalistIds()),
        ];

        $results = Utils::settle($promises)->wait();

        foreach ($results as $key => $result) {
            if ($result['state'] === 'fulfilled') {
                $context->set($key, $result['value']);
            }
        }
    }
}
```

---

## Phase 4: Symfony Normalizers

### Task 4.1: Create EditorialNormalizer
**Priority**: P0 | **Effort**: Medium | **Files**: 1 new

```php
// src/Infrastructure/Serializer/Normalizer/EditorialNormalizer.php
final class EditorialNormalizer implements NormalizerInterface, NormalizerAwareInterface
{
    use NormalizerAwareTrait;

    public function supportsNormalization(mixed $data, ?string $format = null): bool
    {
        return $data instanceof EditorialContext;
    }

    public function normalize(mixed $object, ?string $format = null, array $context = []): array
    {
        /** @var EditorialContext $object */
        $editorial = $object->editorial();

        return [
            'id' => $editorial->id(),
            'url' => $editorial->url(),
            'titles' => $this->normalizer->normalize($editorial->titles(), $format, $context),
            'lead' => $editorial->lead(),
            'publicationDate' => $editorial->publicationDate()->format('c'),
            'body' => $this->normalizer->normalize($editorial->body(), $format, $context),
            'multimedia' => $this->normalizer->normalize($object->multimedia(), $format, $context),
            'signatures' => $this->normalizer->normalize($object->journalists(), $format, $context),
            'section' => $this->normalizer->normalize($object->section(), $format, $context),
            'tags' => $this->normalizer->normalize($object->tags(), $format, $context),
        ];
    }
}
```

**Acceptance Criteria**:
- [ ] Delegates to child normalizers
- [ ] Same JSON structure as current API
- [ ] Unit test comparing output

---

### Task 4.2: Create BodyNormalizer
**Priority**: P0 | **Effort**: Low | **Files**: 1 new

```php
// src/Infrastructure/Serializer/Normalizer/BodyNormalizer.php
final class BodyNormalizer implements NormalizerInterface, NormalizerAwareInterface
{
    use NormalizerAwareTrait;

    public function supportsNormalization(mixed $data, ?string $format = null): bool
    {
        return $data instanceof Body;
    }

    public function normalize(mixed $object, ?string $format = null, array $context = []): array
    {
        /** @var Body $object */
        return [
            'type' => $object->type(),
            'elements' => array_map(
                fn($el) => $this->normalizer->normalize($el, $format, $context),
                $object->elements()
            ),
        ];
    }
}
```

---

### Task 4.3: Create Body Element Normalizers
**Priority**: P0 | **Effort**: Medium | **Files**: ~18 new

One normalizer per body element type:

```
src/Infrastructure/Serializer/Normalizer/BodyElement/
├── ParagraphNormalizer.php
├── SubHeadNormalizer.php
├── PictureNormalizer.php
├── VideoYoutubeNormalizer.php
├── VideoEmbedNormalizer.php
├── BlockquoteNormalizer.php
├── ListNormalizer.php
├── TableNormalizer.php
├── WidgetNormalizer.php
└── ... (all 18 types)
```

Example:

```php
// src/Infrastructure/Serializer/Normalizer/BodyElement/ParagraphNormalizer.php
final class ParagraphNormalizer implements NormalizerInterface
{
    public function supportsNormalization(mixed $data, ?string $format = null): bool
    {
        return $data instanceof Paragraph;
    }

    public function normalize(mixed $object, ?string $format = null, array $context = []): array
    {
        /** @var Paragraph $object */
        return [
            'type' => 'paragraph',
            'content' => $object->content(),
        ];
    }
}
```

**Acceptance Criteria**:
- [ ] One normalizer per BodyElement subclass
- [ ] Auto-discovered via autoconfigure
- [ ] Unit test for each
- [ ] Output matches current transformers

---

### Task 4.4: Create MultimediaNormalizer
**Priority**: P1 | **Effort**: Medium | **Files**: 1 new + subtypes

---

### Task 4.5: Create SectionNormalizer
**Priority**: P1 | **Effort**: Low | **Files**: 1 new

---

### Task 4.6: Create TagNormalizer
**Priority**: P1 | **Effort**: Low | **Files**: 1 new

---

### Task 4.7: Create SignatureNormalizer
**Priority**: P1 | **Effort**: Low | **Files**: 1 new

---

## Phase 5: Integration

### Task 5.1: Create GetEditorialHandler
**Priority**: P0 | **Effort**: Low | **Files**: 1 new

```php
// src/Application/Handler/GetEditorialHandler.php
final readonly class GetEditorialHandler
{
    public function __construct(
        private EnrichmentPipeline $pipeline,
        private SerializerInterface $serializer,
    ) {}

    public function __invoke(string $editorialId): array
    {
        $context = new EditorialContext($editorialId);
        $enrichedContext = $this->pipeline->process($context);

        return $this->serializer->normalize($enrichedContext, 'json');
    }
}
```

---

### Task 5.2: Update EditorialController
**Priority**: P0 | **Effort**: Low | **Files**: 1 modified

```php
// src/Controller/V1/EditorialController.php
#[Route('/v1/editorials')]
final class EditorialController
{
    public function __construct(
        private readonly GetEditorialHandler $handler,
    ) {}

    #[Route('/{id}', methods: ['GET'])]
    public function getById(string $id): JsonResponse
    {
        $data = ($this->handler)($id);
        return new JsonResponse($data);
    }
}
```

---

### Task 5.3: Configure Services
**Priority**: P0 | **Effort**: Low | **Files**: 1-2 modified

```yaml
# config/services.yaml
services:
    # Auto-tag enrichers
    _instanceof:
        App\Application\Pipeline\EnricherInterface:
            tags: ['app.enricher']

    # Pipeline with tagged enrichers
    App\Application\Pipeline\EnrichmentPipeline:
        arguments:
            $enrichers: !tagged_iterator app.enricher

    # Gateways (bind interfaces to implementations)
    App\Domain\Port\Gateway\EditorialGatewayInterface:
        alias: App\Infrastructure\Gateway\Http\EditorialHttpGateway
```

---

### Task 5.4: Create Comparison Tests
**Priority**: P0 | **Effort**: High | **Files**: 1 new

```php
// tests/Integration/BackwardCompatibilityTest.php
final class BackwardCompatibilityTest extends KernelTestCase
{
    /**
     * @dataProvider editorialIdsProvider
     */
    public function testNewOutputMatchesLegacy(string $id): void
    {
        // Old way
        $legacyResponse = $this->legacyOrchestrator->execute($id);

        // New way
        $newResponse = $this->newHandler->__invoke($id);

        $this->assertEquals(
            json_encode($legacyResponse),
            json_encode($newResponse),
            "Output mismatch for editorial $id"
        );
    }
}
```

---

## Phase 6: Decorators (Optional Enhancements)

### Task 6.1: Create CachedGatewayDecorator
**Priority**: P2 | **Effort**: Medium | **Files**: 1 new

---

### Task 6.2: Create CircuitBreakerDecorator
**Priority**: P2 | **Effort**: Medium | **Files**: 1 new

---

## Phase 7: Cleanup

### Task 7.1: Deprecate Old Orchestrators
**Priority**: P3 | **Effort**: Low | **Files**: Modified

Add `@deprecated` to old classes.

---

### Task 7.2: Remove Deprecated Code
**Priority**: P3 | **Effort**: Medium | **Files**: Deleted

After QA approval, remove old orchestrators and transformers.

---

### Task 7.3: Update CLAUDE.md
**Priority**: P2 | **Effort**: Low | **Files**: 1 modified

Document new architecture.

---

## Summary

| Phase | Tasks | New Files | Key Deliverable |
|-------|-------|-----------|-----------------|
| 1. Foundation | 4 | 4 | Pipeline infrastructure |
| 2. Gateways | 6 | 6 | HTTP adapters |
| 3. Enrichers | 7 | 7 | Pipeline steps |
| 4. Normalizers | 7 | ~25 | Serialization |
| 5. Integration | 4 | 2 | Wire everything |
| 6. Decorators | 2 | 2 | Cache + Circuit Breaker |
| 7. Cleanup | 3 | 0 | Remove old code |

**Total**: 33 tasks, ~46 new files

### Critical Path
```
1.1 (Interfaces) → 1.2 (Context) → 1.3 (EnricherInterface) → 1.4 (Pipeline)
                                                                    ↓
2.1 (EditorialGateway) ─────────────────────────────────────→ 3.1 (EditorialEnricher)
                                                                    ↓
4.1 (EditorialNormalizer) → 4.2 (BodyNormalizer) → 4.3 (Elements)
                                                                    ↓
5.1 (Handler) → 5.2 (Controller) → 5.4 (Comparison Tests)
```

### Validation: Add New Field Test

After implementation, verify architecture with this test:

**"Add `commentsCount` to JSON response"**

Expected: Create 1 file (`CommentsEnricher.php`), modify 0 files.

```php
// src/Application/Pipeline/Enricher/CommentsEnricher.php
final readonly class CommentsEnricher implements EnricherInterface
{
    public function __construct(private CommentsGatewayInterface $gateway) {}

    public function priority(): int { return 50; }
    public function supports(EditorialContext $context): bool { return true; }

    public function enrich(EditorialContext $context): void
    {
        $count = $this->gateway->getCount($context->editorialId());
        $context->set('commentsCount', $count);
    }
}
// Done! JSON now includes commentsCount (via EditorialNormalizer)
```
