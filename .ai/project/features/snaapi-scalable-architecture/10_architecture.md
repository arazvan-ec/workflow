# Architecture Specification

## Architecture Style: Hexagonal + CQRS (Query Side)

### Why This Architecture?

| Requirement | Solution |
|-------------|----------|
| Múltiples microservicios | Gateway Pattern (Ports & Adapters) |
| Read-only API | CQRS Query Side (sin Commands) |
| Extensibilidad | Chain of Responsibility + Service Tags |
| Resiliencia | Circuit Breaker + Fallbacks |
| Performance | Async Aggregation + Caching Decorators |
| Testabilidad | Interfaces pequeñas, inyección de dependencias |

## Layer Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              HTTP REQUEST                                    │
│                         GET /v1/editorials/{id}                             │
└───────────────────────────────────┬─────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                         INFRASTRUCTURE LAYER                                 │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    EditorialController (Adapter)                      │   │
│  │  - Thin controller, only HTTP concerns                               │   │
│  │  - Validates request, calls Query Handler, returns JsonResponse       │   │
│  └───────────────────────────────────┬─────────────────────────────────┘   │
└──────────────────────────────────────┼──────────────────────────────────────┘
                                       │ GetEditorialByIdQuery
                                       ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                          APPLICATION LAYER                                   │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │              GetEditorialByIdHandler (Query Handler)                  │   │
│  │  - Orchestrates the use case                                         │   │
│  │  - Calls Aggregator to fetch all data                                │   │
│  │  - Calls Transformer to build response                               │   │
│  └───────────────────────────────────┬─────────────────────────────────┘   │
│                                      │                                      │
│  ┌───────────────────────────────────▼─────────────────────────────────┐   │
│  │                    EditorialAggregator                                │   │
│  │  ┌─────────────────────────────────────────────────────────────┐    │   │
│  │  │  Parallel Gateway Calls (via Promises)                       │    │   │
│  │  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐       │    │   │
│  │  │  │Editorial │ │Multimedia│ │ Section  │ │   Tags   │       │    │   │
│  │  │  │ Gateway  │ │ Gateway  │ │ Gateway  │ │ Gateway  │       │    │   │
│  │  │  └──────────┘ └──────────┘ └──────────┘ └──────────┘       │    │   │
│  │  │  ┌──────────┐ ┌──────────┐                                  │    │   │
│  │  │  │Journalist│ │Membership│                                  │    │   │
│  │  │  │ Gateway  │ │ Gateway  │                                  │    │   │
│  │  │  └──────────┘ └──────────┘                                  │    │   │
│  │  └─────────────────────────────────────────────────────────────┘    │   │
│  └───────────────────────────────────┬─────────────────────────────────┘   │
│                                      │ AggregatedEditorial                  │
│  ┌───────────────────────────────────▼─────────────────────────────────┐   │
│  │              EditorialResponseTransformer                             │   │
│  │  ┌─────────────────────────────────────────────────────────────┐    │   │
│  │  │  Chain of Transformers                                       │    │   │
│  │  │  BodyTransformerChain → MediaTransformerChain → etc.        │    │   │
│  │  └─────────────────────────────────────────────────────────────┘    │   │
│  └───────────────────────────────────┬─────────────────────────────────┘   │
└──────────────────────────────────────┼──────────────────────────────────────┘
                                       │ EditorialResponse (DTO)
                                       ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                           DOMAIN LAYER                                       │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐             │
│  │   ReadModels    │  │   Exceptions    │  │     Enums       │             │
│  │                 │  │                 │  │                 │             │
│  │ - Editorial     │  │ - NotFound      │  │ - EditorialType │             │
│  │ - Multimedia    │  │ - NotPublished  │  │ - MultimediaType│             │
│  │ - Section       │  │ - Unavailable   │  │ - Site          │             │
│  │ - Tag           │  │                 │  │                 │             │
│  │ - Journalist    │  │                 │  │                 │             │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘             │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                         PORTS (Interfaces)                           │   │
│  │  EditorialGatewayInterface    MultimediaGatewayInterface            │   │
│  │  SectionGatewayInterface      TagGatewayInterface                   │   │
│  │  JournalistGatewayInterface   MembershipGatewayInterface            │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
                                       │
                                       │ Implements
                                       ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                    INFRASTRUCTURE LAYER (Adapters)                           │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    HTTP Gateway Implementations                       │   │
│  │                                                                       │   │
│  │  EditorialHttpGateway ──────────────────────▶ Editorial Microservice │   │
│  │  MultimediaHttpGateway ─────────────────────▶ Multimedia Microservice│   │
│  │  SectionHttpGateway ────────────────────────▶ Section Microservice   │   │
│  │  TagHttpGateway ────────────────────────────▶ Tag Microservice       │   │
│  │  JournalistHttpGateway ─────────────────────▶ Journalist Microservice│   │
│  │  MembershipHttpGateway ─────────────────────▶ Membership Microservice│   │
│  │                                                                       │   │
│  │  ┌─────────────────────────────────────────────────────────────┐    │   │
│  │  │              Decorators (Cross-cutting concerns)             │    │   │
│  │  │  CachedGateway ← CircuitBreakerGateway ← HttpGateway        │    │   │
│  │  └─────────────────────────────────────────────────────────────┘    │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Directory Structure (Proposed)

```
src/
├── Application/
│   ├── Query/
│   │   ├── GetEditorialById/
│   │   │   ├── GetEditorialByIdQuery.php          # Query DTO
│   │   │   ├── GetEditorialByIdHandler.php        # Use Case
│   │   │   └── GetEditorialByIdResponse.php       # Response DTO
│   │   ├── GetEditorialList/
│   │   │   └── ...
│   │   └── QueryBus.php                           # Simple query bus
│   │
│   ├── Aggregator/
│   │   ├── EditorialAggregator.php                # Main aggregator
│   │   ├── MultimediaAggregator.php               # Multimedia specific
│   │   ├── AggregatorInterface.php
│   │   └── AggregatedEditorial.php                # Aggregated result
│   │
│   ├── Transformer/
│   │   ├── Editorial/
│   │   │   ├── EditorialResponseTransformer.php   # Main transformer
│   │   │   ├── BodyTransformerChain.php           # Chain handler
│   │   │   └── Element/                           # Body element transformers
│   │   │       ├── ParagraphTransformer.php
│   │   │       ├── SubHeadTransformer.php
│   │   │       ├── PictureTransformer.php
│   │   │       ├── VideoTransformer.php
│   │   │       └── ElementTransformerInterface.php
│   │   ├── Multimedia/
│   │   │   ├── MultimediaTransformerChain.php
│   │   │   └── Type/
│   │   │       ├── PhotoTransformer.php
│   │   │       ├── VideoTransformer.php
│   │   │       └── WidgetTransformer.php
│   │   └── TransformerInterface.php
│   │
│   └── DTO/
│       ├── Request/
│       │   └── GetEditorialRequest.php
│       └── Response/
│           ├── EditorialResponse.php              # Final API response
│           ├── BodyResponse.php
│           ├── MultimediaResponse.php
│           ├── SectionResponse.php
│           └── SignatureResponse.php
│
├── Domain/
│   ├── ReadModel/                                 # Value Objects (from external packages)
│   │   ├── Editorial.php                          # Wrapper/Adapter if needed
│   │   ├── Multimedia.php
│   │   ├── Section.php
│   │   ├── Tag.php
│   │   └── Journalist.php
│   │
│   ├── Exception/
│   │   ├── EditorialNotFoundException.php
│   │   ├── EditorialNotPublishedException.php
│   │   └── ServiceUnavailableException.php
│   │
│   ├── Enum/
│   │   ├── EditorialType.php                      # Migrate from Infrastructure
│   │   ├── MultimediaType.php
│   │   └── Site.php
│   │
│   └── Port/
│       └── Gateway/
│           ├── EditorialGatewayInterface.php
│           ├── MultimediaGatewayInterface.php
│           ├── SectionGatewayInterface.php
│           ├── TagGatewayInterface.php
│           ├── JournalistGatewayInterface.php
│           └── MembershipGatewayInterface.php
│
├── Infrastructure/
│   ├── Controller/
│   │   └── V1/
│   │       ├── EditorialController.php            # Thin, uses QueryBus
│   │       └── HealthController.php
│   │
│   ├── Gateway/
│   │   ├── Http/
│   │   │   ├── EditorialHttpGateway.php           # Implements interface
│   │   │   ├── MultimediaHttpGateway.php
│   │   │   ├── SectionHttpGateway.php
│   │   │   ├── TagHttpGateway.php
│   │   │   ├── JournalistHttpGateway.php
│   │   │   └── MembershipHttpGateway.php
│   │   ├── Decorator/
│   │   │   ├── CachedGatewayDecorator.php         # Caching layer
│   │   │   └── CircuitBreakerDecorator.php        # Resilience
│   │   └── Factory/
│   │       └── GatewayFactory.php                 # Creates decorated gateways
│   │
│   ├── Service/
│   │   ├── Thumbor/
│   │   │   └── ThumborService.php
│   │   ├── CircuitBreaker/
│   │   │   ├── CircuitBreakerService.php
│   │   │   └── CircuitState.php
│   │   └── Image/
│   │       └── ResponsiveImageGenerator.php
│   │
│   ├── Cache/
│   │   └── RedisCacheAdapter.php
│   │
│   ├── EventSubscriber/
│   │   ├── ExceptionSubscriber.php
│   │   └── CacheControlSubscriber.php
│   │
│   └── DependencyInjection/
│       └── Compiler/
│           ├── GatewayCompilerPass.php
│           ├── TransformerCompilerPass.php
│           └── AggregatorCompilerPass.php
│
└── Kernel.php
```

## Key Interfaces

### Gateway Interface Example

```php
<?php

declare(strict_types=1);

namespace App\Domain\Port\Gateway;

use App\Domain\ReadModel\Editorial;
use App\Domain\ValueObject\EditorialId;
use GuzzleHttp\Promise\PromiseInterface;

interface EditorialGatewayInterface
{
    /**
     * Find editorial by ID (sync)
     */
    public function findById(EditorialId $id): ?Editorial;

    /**
     * Find editorial by ID (async)
     */
    public function findByIdAsync(EditorialId $id): PromiseInterface;

    /**
     * Check if editorial is visible/published
     */
    public function isVisible(EditorialId $id): bool;
}
```

### Query Handler Example

```php
<?php

declare(strict_types=1);

namespace App\Application\Query\GetEditorialById;

use App\Application\Aggregator\EditorialAggregator;
use App\Application\Transformer\Editorial\EditorialResponseTransformer;
use App\Domain\Exception\EditorialNotFoundException;

final readonly class GetEditorialByIdHandler
{
    public function __construct(
        private EditorialAggregator $aggregator,
        private EditorialResponseTransformer $transformer,
    ) {}

    public function __invoke(GetEditorialByIdQuery $query): GetEditorialByIdResponse
    {
        $aggregated = $this->aggregator->aggregate($query->id);

        if ($aggregated === null) {
            throw new EditorialNotFoundException($query->id);
        }

        return $this->transformer->transform($aggregated);
    }
}
```

### Aggregator Example

```php
<?php

declare(strict_types=1);

namespace App\Application\Aggregator;

use App\Domain\Port\Gateway\EditorialGatewayInterface;
use App\Domain\Port\Gateway\MultimediaGatewayInterface;
use App\Domain\Port\Gateway\SectionGatewayInterface;
use App\Domain\Port\Gateway\TagGatewayInterface;
use App\Domain\Port\Gateway\JournalistGatewayInterface;
use GuzzleHttp\Promise\Utils;

final readonly class EditorialAggregator
{
    public function __construct(
        private EditorialGatewayInterface $editorialGateway,
        private MultimediaGatewayInterface $multimediaGateway,
        private SectionGatewayInterface $sectionGateway,
        private TagGatewayInterface $tagGateway,
        private JournalistGatewayInterface $journalistGateway,
    ) {}

    public function aggregate(EditorialId $id): ?AggregatedEditorial
    {
        // 1. Fetch base editorial (sync - need it first)
        $editorial = $this->editorialGateway->findById($id);

        if ($editorial === null || !$editorial->isVisible()) {
            return null;
        }

        // 2. Prepare async promises for related data
        $promises = [
            'multimedia' => $this->multimediaGateway->findByIdAsync($editorial->multimediaId()),
            'section' => $this->sectionGateway->findByIdAsync($editorial->sectionId()),
            'tags' => $this->tagGateway->findByIdsAsync($editorial->tagIds()),
            'journalists' => $this->journalistGateway->findByIdsAsync($editorial->journalistIds()),
        ];

        // 3. Wait for all promises (parallel execution)
        $results = Utils::settle($promises)->wait();

        // 4. Build aggregated result
        return new AggregatedEditorial(
            editorial: $editorial,
            multimedia: $this->extractFulfilled($results, 'multimedia'),
            section: $this->extractFulfilled($results, 'section'),
            tags: $this->extractFulfilled($results, 'tags') ?? [],
            journalists: $this->extractFulfilled($results, 'journalists') ?? [],
        );
    }

    private function extractFulfilled(array $results, string $key): mixed
    {
        return $results[$key]['state'] === 'fulfilled'
            ? $results[$key]['value']
            : null;
    }
}
```

## Decorator Chain for Gateways

```
Request
   │
   ▼
┌─────────────────────────┐
│  CachedGatewayDecorator │ ← Check cache first
│  (implements Interface) │
└───────────┬─────────────┘
            │ cache miss
            ▼
┌─────────────────────────┐
│ CircuitBreakerDecorator │ ← Check circuit state
│  (implements Interface) │
└───────────┬─────────────┘
            │ circuit closed
            ▼
┌─────────────────────────┐
│   EditorialHttpGateway  │ ← Actual HTTP call
│  (implements Interface) │
└─────────────────────────┘
```

## Service Configuration (services.yaml)

```yaml
services:
    # Gateway interfaces → implementations
    App\Domain\Port\Gateway\EditorialGatewayInterface:
        class: App\Infrastructure\Gateway\Decorator\CachedGatewayDecorator
        arguments:
            $inner: '@App\Infrastructure\Gateway\Decorator\CircuitBreakerDecorator.editorial'
            $cache: '@cache.app'
            $ttl: 300

    App\Infrastructure\Gateway\Decorator\CircuitBreakerDecorator.editorial:
        class: App\Infrastructure\Gateway\Decorator\CircuitBreakerDecorator
        arguments:
            $inner: '@App\Infrastructure\Gateway\Http\EditorialHttpGateway'
            $circuitBreaker: '@App\Infrastructure\Service\CircuitBreaker\CircuitBreakerService'
            $serviceName: 'editorial'

    # Transformers with tags
    App\Application\Transformer\Editorial\Element\:
        resource: '../src/Application/Transformer/Editorial/Element/*'
        tags: ['app.body_element_transformer']

    # Compiler pass registration
    App\Application\Transformer\Editorial\BodyTransformerChain:
        arguments:
            $transformers: !tagged_iterator app.body_element_transformer
```

## Migration Strategy

### Phase 1: Create Structure (No Breaking Changes)
1. Create new directories under `src/`
2. Create interfaces in `Domain/Port/`
3. Create empty implementations

### Phase 2: Implement Gateways
1. Create HTTP Gateway implementations wrapping existing clients
2. Add tests for each gateway
3. No changes to existing code yet

### Phase 3: Create Query Handlers
1. Create Query DTOs
2. Implement handlers using new gateways
3. Add aggregators

### Phase 4: Migrate Controllers
1. Update controllers to use QueryBus
2. Deprecate old orchestrators
3. Run comparison tests

### Phase 5: Cleanup
1. Remove deprecated orchestrators
2. Remove old transformers
3. Update documentation
