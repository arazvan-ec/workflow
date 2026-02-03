# Task Breakdown: SOLID Refactor

## Legend

- **Status**: PENDING | IN_PROGRESS | BLOCKED | COMPLETED
- **Parallel Group**: Tasks in same group can run simultaneously
- **Priority**: P0 (blocker) | P1 (critical) | P2 (high) | P3 (medium)

---

## Phase 1: Foundations (Sequential)

### TASK-001: Create BodyElement Creator Interface
**Status**: PENDING
**Priority**: P0
**Parallel Group**: -
**Estimated**: 15 min

**Description**: Create the interface that all body element creators will implement.

**File**: `src/Application/Factory/Response/Creator/BodyElement/BodyElementResponseCreatorInterface.php`

**Implementation**:
```php
<?php

declare(strict_types=1);

namespace App\Application\Factory\Response\Creator\BodyElement;

use App\Application\DTO\Response\BodyElementResponse;
use Ec\Editorial\Domain\Model\Body\BodyElement;

interface BodyElementResponseCreatorInterface
{
    public function supports(BodyElement $element): bool;

    /**
     * @param array<string, mixed> $resolveData
     */
    public function create(BodyElement $element, array $resolveData = []): BodyElementResponse;
}
```

**Definition of Done**:
- [ ] Interface created
- [ ] PHPStan passes
- [ ] No other files modified

---

### TASK-002: Create Multimedia Creator Interface
**Status**: PENDING
**Priority**: P0
**Parallel Group**: -
**Estimated**: 15 min

**File**: `src/Application/Factory/Response/Creator/Multimedia/MultimediaResponseCreatorInterface.php`

**Implementation**:
```php
<?php

declare(strict_types=1);

namespace App\Application\Factory\Response\Creator\Multimedia;

use App\Application\DTO\Response\MultimediaResponse;
use Ec\Multimedia\Domain\Model\Multimedia\Multimedia;

interface MultimediaResponseCreatorInterface
{
    public function supports(Multimedia $multimedia): bool;

    public function create(Multimedia $multimedia): MultimediaResponse;
}
```

**Definition of Done**:
- [ ] Interface created
- [ ] PHPStan passes

---

### TASK-003: Configure Symfony Tagged Services
**Status**: PENDING
**Priority**: P0
**Parallel Group**: -
**Depends On**: TASK-001, TASK-002

**File**: `config/services.yaml`

**Implementation**:
```yaml
services:
    _instanceof:
        App\Application\Factory\Response\Creator\BodyElement\BodyElementResponseCreatorInterface:
            tags: ['app.body_element_response_creator']

        App\Application\Factory\Response\Creator\Multimedia\MultimediaResponseCreatorInterface:
            tags: ['app.multimedia_response_creator']

    App\Application\Factory\Response\Creator\:
        resource: '../src/Application/Factory/Response/Creator/'
        autoconfigure: true

    App\Application\Factory\Response\BodyElementResponseFactory:
        arguments:
            $creators: !tagged_iterator app.body_element_response_creator

    App\Application\Factory\Response\MultimediaResponseFactory:
        arguments:
            $creators: !tagged_iterator app.multimedia_response_creator
```

**Definition of Done**:
- [ ] Services configured
- [ ] Container compiles without errors

---

## Phase 2A: BodyElement Creators (Parallel Group A)

### TASK-010: Create ParagraphResponseCreator
**Status**: PENDING
**Priority**: P1
**Parallel Group**: A
**Depends On**: TASK-001

**File**: `src/Application/Factory/Response/Creator/BodyElement/ParagraphResponseCreator.php`

**Reference**: `BodyElementResponseFactory.php:55-61`

**Tests**:
```php
public function test_supports_paragraph(): void
public function test_does_not_support_other_types(): void
public function test_creates_paragraph_response(): void
```

**Definition of Done**:
- [ ] Creator implemented
- [ ] 3 unit tests pass
- [ ] PHPStan passes

---

### TASK-011: Create SubHeadResponseCreator
**Status**: PENDING
**Priority**: P1
**Parallel Group**: A
**Depends On**: TASK-001

**File**: `src/Application/Factory/Response/Creator/BodyElement/SubHeadResponseCreator.php`

**Reference**: `BodyElementResponseFactory.php:63-70`

**Definition of Done**:
- [ ] Creator implemented
- [ ] 3 unit tests pass

---

### TASK-012: Create PictureResponseCreator
**Status**: PENDING
**Priority**: P1
**Parallel Group**: A
**Depends On**: TASK-001

**File**: `src/Application/Factory/Response/Creator/BodyElement/PictureResponseCreator.php`

**Reference**: `BodyElementResponseFactory.php:75-89`

**Note**: Uses `$resolveData['photoFromBodyTags']`

**Definition of Done**:
- [ ] Creator implemented
- [ ] Tests cover resolveData usage
- [ ] PHPStan passes

---

### TASK-013: Create PictureMembershipResponseCreator
**Status**: PENDING
**Priority**: P1
**Parallel Group**: A
**Depends On**: TASK-001

**File**: `src/Application/Factory/Response/Creator/BodyElement/PictureMembershipResponseCreator.php`

**Reference**: `BodyElementResponseFactory.php:94-105`

---

### TASK-014: Create VideoYoutubeResponseCreator
**Status**: PENDING
**Priority**: P1
**Parallel Group**: A
**Depends On**: TASK-001

**File**: `src/Application/Factory/Response/Creator/BodyElement/VideoYoutubeResponseCreator.php`

**Reference**: `BodyElementResponseFactory.php:107-113`

---

### TASK-015: Create VideoResponseCreator
**Status**: PENDING
**Priority**: P1
**Parallel Group**: A
**Depends On**: TASK-001

**File**: `src/Application/Factory/Response/Creator/BodyElement/VideoResponseCreator.php`

**Reference**: `BodyElementResponseFactory.php:115-121`

---

### TASK-016: Create HtmlResponseCreator
**Status**: PENDING
**Priority**: P1
**Parallel Group**: A
**Depends On**: TASK-001

**File**: `src/Application/Factory/Response/Creator/BodyElement/HtmlResponseCreator.php`

**Reference**: `BodyElementResponseFactory.php:123-129`

---

### TASK-017: Create SummaryResponseCreator
**Status**: PENDING
**Priority**: P1
**Parallel Group**: A
**Depends On**: TASK-001

**File**: `src/Application/Factory/Response/Creator/BodyElement/SummaryResponseCreator.php`

**Reference**: `BodyElementResponseFactory.php:131-137`

---

### TASK-018: Create ExplanatorySummaryResponseCreator
**Status**: PENDING
**Priority**: P1
**Parallel Group**: A
**Depends On**: TASK-001

**File**: `src/Application/Factory/Response/Creator/BodyElement/ExplanatorySummaryResponseCreator.php`

**Reference**: `BodyElementResponseFactory.php:139-148`

---

### TASK-019: Create InsertedNewsResponseCreator
**Status**: PENDING
**Priority**: P1
**Parallel Group**: A
**Depends On**: TASK-001

**File**: `src/Application/Factory/Response/Creator/BodyElement/InsertedNewsResponseCreator.php`

**Reference**: `BodyElementResponseFactory.php:153-165`

**Note**: Uses `$resolveData['insertedNews']`

---

### TASK-020: Create MembershipCardResponseCreator
**Status**: PENDING
**Priority**: P1
**Parallel Group**: A
**Depends On**: TASK-001

**File**: `src/Application/Factory/Response/Creator/BodyElement/MembershipCardResponseCreator.php`

**Reference**: `BodyElementResponseFactory.php:170-181`

**Note**: Uses `$resolveData['membershipLinkCombine']`

---

### TASK-021: Create LinkResponseCreator
**Status**: PENDING
**Priority**: P1
**Parallel Group**: A
**Depends On**: TASK-001

**File**: `src/Application/Factory/Response/Creator/BodyElement/LinkResponseCreator.php`

**Reference**: `BodyElementResponseFactory.php:183-192`

---

### TASK-022: Create UnorderedListResponseCreator
**Status**: PENDING
**Priority**: P1
**Parallel Group**: A
**Depends On**: TASK-001

**File**: `src/Application/Factory/Response/Creator/BodyElement/UnorderedListResponseCreator.php`

**Reference**: `BodyElementResponseFactory.php:194-200`

---

### TASK-023: Create NumberedListResponseCreator
**Status**: PENDING
**Priority**: P1
**Parallel Group**: A
**Depends On**: TASK-001

**File**: `src/Application/Factory/Response/Creator/BodyElement/NumberedListResponseCreator.php`

**Reference**: `BodyElementResponseFactory.php:202-208`

---

### TASK-024: Create GenericListResponseCreator
**Status**: PENDING
**Priority**: P1
**Parallel Group**: A
**Depends On**: TASK-001

**File**: `src/Application/Factory/Response/Creator/BodyElement/GenericListResponseCreator.php`

**Reference**: `BodyElementResponseFactory.php:210-216`

---

### TASK-025: Create FallbackBodyElementResponseCreator
**Status**: PENDING
**Priority**: P1
**Parallel Group**: A
**Depends On**: TASK-001

**File**: `src/Application/Factory/Response/Creator/BodyElement/FallbackBodyElementResponseCreator.php`

**Reference**: `BodyElementResponseFactory.php:218-226`

**Note**: This creator always returns true for `supports()` but should be registered last (use priority tag).

---

## Phase 2B: Multimedia Creators (Parallel Group B)

### TASK-030: Create PhotoResponseCreator
**Status**: PENDING
**Priority**: P1
**Parallel Group**: B
**Depends On**: TASK-002

**File**: `src/Application/Factory/Response/Creator/Multimedia/PhotoResponseCreator.php`

**Reference**: `MultimediaResponseFactory.php:25-34`

---

### TASK-031: Create EmbedVideoResponseCreator
**Status**: PENDING
**Priority**: P1
**Parallel Group**: B
**Depends On**: TASK-002

**File**: `src/Application/Factory/Response/Creator/Multimedia/EmbedVideoResponseCreator.php`

**Reference**: `MultimediaResponseFactory.php:36-44`

---

### TASK-032: Create WidgetResponseCreator
**Status**: PENDING
**Priority**: P1
**Parallel Group**: B
**Depends On**: TASK-002

**File**: `src/Application/Factory/Response/Creator/Multimedia/WidgetResponseCreator.php`

**Reference**: `MultimediaResponseFactory.php:46-55`

---

### TASK-033: Create FallbackMultimediaResponseCreator
**Status**: PENDING
**Priority**: P1
**Parallel Group**: B
**Depends On**: TASK-002

**File**: `src/Application/Factory/Response/Creator/Multimedia/FallbackMultimediaResponseCreator.php`

**Reference**: `MultimediaResponseFactory.php:57-63`

---

## Phase 3: Refactor Factories (Sequential, after Phase 2)

### TASK-040: Refactor BodyElementResponseFactory
**Status**: PENDING
**Priority**: P0
**Parallel Group**: -
**Depends On**: TASK-010 to TASK-025, TASK-003

**File**: `src/Application/Factory/Response/BodyElementResponseFactory.php`

**Before**: 227 lines, 15+ instanceof checks
**After**: ~25 lines, iterates over creators

**Implementation**:
```php
<?php

declare(strict_types=1);

namespace App\Application\Factory\Response;

use App\Application\DTO\Response\BodyElementResponse;
use App\Application\Factory\Response\Creator\BodyElement\BodyElementResponseCreatorInterface;
use Ec\Editorial\Domain\Model\Body\BodyElement;

final readonly class BodyElementResponseFactory
{
    /** @param iterable<BodyElementResponseCreatorInterface> $creators */
    public function __construct(
        private iterable $creators,
    ) {
    }

    /** @param array<string, mixed> $resolveData */
    public function create(BodyElement $element, array $resolveData = []): BodyElementResponse
    {
        foreach ($this->creators as $creator) {
            if ($creator->supports($element)) {
                return $creator->create($element, $resolveData);
            }
        }

        return new BodyElementResponse(type: 'unknown', extra: ['class' => $element::class]);
    }
}
```

**Definition of Done**:
- [ ] Factory refactored
- [ ] All existing tests pass
- [ ] No imports of concrete BodyElement types
- [ ] < 30 lines

---

### TASK-041: Refactor MultimediaResponseFactory
**Status**: PENDING
**Priority**: P0
**Parallel Group**: -
**Depends On**: TASK-030 to TASK-033, TASK-003

**File**: `src/Application/Factory/Response/MultimediaResponseFactory.php`

**Definition of Done**:
- [ ] Factory refactored
- [ ] All existing tests pass
- [ ] < 30 lines

---

## Phase 4: Handler Refactoring (Parallel Group C)

### TASK-050: Refactor BodyElementDataTransformerHandler
**Status**: PENDING
**Priority**: P2
**Parallel Group**: C
**Depends On**: TASK-040

**File**: `src/Application/DataTransformer/BodyElementDataTransformerHandler.php`

**Problem**: Uses `get_class()` to find transformers

**Solution**: Same pattern as factories - interface with `supports()`

---

### TASK-051: Refactor MediaDataTransformerHandler
**Status**: PENDING
**Priority**: P2
**Parallel Group**: C
**Depends On**: TASK-041

**File**: `src/Application/DataTransformer/Apps/Media/MediaDataTransformerHandler.php`

**Problem**: Same as TASK-050

---

## Phase 5: MultimediaTrait Elimination (Sequential)

### TASK-060: Create ImageSizeConfiguration
**Status**: PENDING
**Priority**: P2
**Parallel Group**: -
**Depends On**: -

**Files**:
- `src/Infrastructure/Configuration/ImageSizeConfiguration.php`
- `config/packages/image_sizes.yaml`

**Purpose**: Extract hardcoded sizes from MultimediaTrait to configuration

---

### TASK-061: Create MultimediaUrlGenerator Service
**Status**: PENDING
**Priority**: P2
**Parallel Group**: -
**Depends On**: TASK-060

**File**: `src/Infrastructure/Service/MultimediaUrlGenerator.php`

**Purpose**: Replace trait methods with injectable service

---

### TASK-062: Migrate MultimediaTrait Consumers
**Status**: PENDING
**Priority**: P2
**Parallel Group**: -
**Depends On**: TASK-061

**Files to modify** (7):
- BodyTagInsertedNewsDataTransformer
- DetailsAppsDataTransformer
- DetailsMultimediaDataTransformer
- JournalistsDataTransformer
- RecommendedEditorialsDataTransformer
- DetailsMultimediaPhotoDataTransformer
- EditorialOrchestrator

---

### TASK-063: Delete MultimediaTrait
**Status**: PENDING
**Priority**: P3
**Parallel Group**: -
**Depends On**: TASK-062

**File**: DELETE `src/Infrastructure/Trait/MultimediaTrait.php`

---

## Phase 6: Final Cleanup

### TASK-070: Update PHPStan Configuration
**Status**: PENDING
**Priority**: P3
**Depends On**: All previous

---

### TASK-071: Run Full Test Suite
**Status**: PENDING
**Priority**: P0
**Depends On**: All previous

**Command**: `./vendor/bin/phpunit`

---

### TASK-072: Update Documentation
**Status**: PENDING
**Priority**: P3
**Depends On**: TASK-071

---

## Summary

| Phase | Tasks | Parallelizable | Dependencies |
|-------|-------|----------------|--------------|
| 1 | 3 | No | - |
| 2A | 16 | Yes (all) | Phase 1 |
| 2B | 4 | Yes (all) | Phase 1 |
| 3 | 2 | No | Phase 2 |
| 4 | 2 | Yes | Phase 3 |
| 5 | 4 | No | - |
| 6 | 3 | No | All |

**Total Tasks**: 34
**Parallelizable**: 22 (65%)
