---
name: workflows:discover
description: "Deep project analysis to build comprehensive knowledge. Scans codebase, detects patterns, and creates project profile."
argument_hint: [--full | --refresh | --report | --setup]
---

# /workflows:discover - Descubrimiento Profundo del Proyecto

**Version**: 1.0.0
**Category**: Setup & Analysis
**Priority**: Run once after installation, then periodically

---

## Purpose

Analiza el proyecto en profundidad para construir un conocimiento completo que permita al plugin trabajar de manera más efectiva. Genera un perfil del proyecto con toda la información relevante.

## When to Use

| Situación | Recomendación |
|-----------|---------------|
| **First time using the plugin** | **`/workflows:discover --setup`** |
| **New project from requirements (greenfield)** | **`/workflows:discover --seed`** |
| Primera instalación del plugin | `/workflows:discover --full` |
| Después de cambios mayores (nueva librería, refactor) | `/workflows:discover --refresh` |
| Ver resumen del conocimiento actual | `/workflows:discover --report` |
| Antes de planificar feature compleja | Automático en `/workflows:plan` |
| Update specs after domain model changes | `/workflows:discover --specs-only` |
| Deep analysis of business rules | `/workflows:discover --specs-only --specs-depth=deep` |
| Generate API documentation baseline | `/workflows:discover --specs-only` then review `api-contracts/` |

## Invocation

```bash
# Análisis completo (primera vez)
/workflows:discover --full

# Refrescar conocimiento existente
/workflows:discover --refresh

# Solo mostrar reporte del conocimiento actual
/workflows:discover --report

# Por defecto: análisis inteligente (detecta qué necesita actualizar)
/workflows:discover

# First-time setup (interactive onboarding + discovery)
/workflows:discover --setup
/workflows:discover --setup --reset  # Force reconfiguration

# Project Seed — generate compound-equivalent knowledge from requirements (greenfield)
/workflows:discover --seed
/workflows:discover --seed --stack=symfony  # Specify stack explicitly

# Spec extraction examples
/workflows:discover --specs-only           # Only extract specs, skip profile
/workflows:discover --no-extract-specs     # Full discovery without spec extraction
/workflows:discover --specs-depth=deep     # Deep spec extraction (includes invariants, lifecycle)
/workflows:discover --full --specs-only    # Force re-extract all specs from scratch
```

## Execution Protocol

### Step 1: Create Project Intelligence Directory

```bash
mkdir -p .ai/project/intelligence
mkdir -p openspec/specs/entities
mkdir -p openspec/specs/api-contracts
mkdir -p openspec/specs/business-rules
mkdir -p openspec/specs/architectural-constraints
mkdir -p openspec/specs/api-consumers
```

### Step 2: Detect Project Type and Stack

Scan for configuration files and detect:

```markdown
## Detección de Stack

Escaneando archivos de configuración...

### Backend Detection
| Archivo | Framework/Lenguaje |
|---------|-------------------|
| `package.json` → Node.js, dependencias |
| `composer.json` → PHP, Symfony/Laravel |
| `requirements.txt` / `pyproject.toml` → Python |
| `go.mod` → Go |
| `Cargo.toml` → Rust |
| `pom.xml` / `build.gradle` → Java |
| `.csproj` → .NET |

### Frontend Detection
| Archivo | Framework |
|---------|-----------|
| `package.json` → React/Vue/Angular/Svelte |
| `tsconfig.json` → TypeScript |
| `vite.config.*` → Vite |
| `next.config.*` → Next.js |
| `nuxt.config.*` → Nuxt |

### Infrastructure Detection
| Archivo | Tecnología |
|---------|------------|
| `docker-compose.yml` → Docker |
| `Dockerfile` → Containerization |
| `.github/workflows/` → GitHub Actions |
| `terraform/` → Infrastructure as Code |
| `k8s/` / `kubernetes/` → Kubernetes |
```

### Step 3: Analyze Project Structure

```markdown
## Análisis de Estructura

### Directory Map
```
[Generar árbol de directorios hasta 3 niveles]
```

### Architecture Pattern Detection

| Patrón | Indicadores | Detectado |
|--------|-------------|-----------|
| **DDD (Domain-Driven Design)** | `domain/`, `application/`, `infrastructure/` | ✓/✗ |
| **Clean Architecture** | `entities/`, `usecases/`, `adapters/` | ✓/✗ |
| **MVC** | `models/`, `views/`, `controllers/` | ✓/✗ |
| **Hexagonal** | `ports/`, `adapters/` | ✓/✗ |
| **Atomic Design** | `atoms/`, `molecules/`, `organisms/` | ✓/✗ |
| **Feature-based** | Feature folders with all concerns | ✓/✗ |

### Layer Analysis (if DDD/Clean detected)
- Domain Layer: [path and health]
- Application Layer: [path and health]
- Infrastructure Layer: [path and health]
- Presentation Layer: [path and health]
```

### Step 4: Generate Architecture Profile

> **Agent**: `codebase-analyzer` | **Mode**: Architecture Profiling

Consolidate the stack, architecture, patterns, and conventions detected in Steps 2-3 into a structured architecture profile. Much of this information has already been gathered; this step formats and persists it.

#### What to Detect and Record

| Section | Fields |
|---------|--------|
| **Stack** | `language`, `framework`, `paradigm`, `type_system` |
| **Architecture** | `pattern` (hexagonal, mvc, layered, clean, etc.), `layers` with paths and dependencies, `separation_enforced` |
| **Patterns Detected** | `data_access`, `dependency_management`, `error_handling`, `async_pattern`, `testing_approach`, `http_client_pattern`, `external_api_integration`, `serialization_strategy`, `multi_platform_output`, `data_aggregation_pattern` |
| **External APIs** | `external_apis_consumed` (name, sdk, adapter, port, acl_compliant per consumed API) |
| **SOLID Relevance** | For each principle (SRP, OCP, LSP, ISP, DIP): `relevance` (high/medium/low), `metric`, `when_violated`, `reference_good` |
| **Conventions** | `naming` (classes, methods, files), `structure` (project-specific paths), `reference_files` (example files per archetype) |
| **Quality Thresholds** | `max_class_loc`, `max_public_methods`, `max_constructor_deps`, `max_interface_methods`, `max_files_per_simple_change` |

#### Output

Write the architecture profile to `openspec/specs/architecture-profile.yaml` using the template from `core/templates/architecture-profile-template.yaml`.

```bash
# Ensure the target directory exists
mkdir -p openspec/specs
```

```yaml
# openspec/specs/architecture-profile.yaml
# Generated by /workflows:discover on [DATE]
# Template: core/templates/architecture-profile-template.yaml

stack:
  language: "[detected from Step 2]"
  framework: "[detected from Step 2]"
  paradigm: "[oop|functional|mixed - inferred from codebase]"
  type_system: "[strong-static|strong-dynamic|weak-dynamic]"

architecture:
  pattern: "[detected from Step 3]"
  layers: [...]   # From Step 3 Layer Analysis
  separation_enforced: true|false

patterns_detected:
  data_access: "[repository|active-record|query-builder|...]"
  dependency_management: "[constructor-injection|container-autowire|...]"
  error_handling: "[exceptions|result-types|error-codes|mixed]"
  async_pattern: "[promises|async-await|callbacks|...]"
  testing_approach: "[tdd|test-after|minimal|none]"

solid_relevance:
  srp:
    relevance: "[high|medium|low]"
    metric: "[e.g., classes ≤200 LOC, ≤7 public methods]"
    when_violated: "[e.g., Extract Class, then compose]"
    reference_good: "[path to good SRP example in project]"
  ocp:
    relevance: "[high|medium|low]"
    metric: "[e.g., no switch/if-else chains by type]"
    when_violated: "[e.g., Strategy pattern]"
    reference_good: "[path]"
  lsp:
    relevance: "[high|medium|low]"
    metric: "[e.g., overrides respect parent contract]"
    when_violated: "[e.g., Composition over Inheritance]"
  isp:
    relevance: "[high|medium|low]"
    metric: "[e.g., interfaces ≤5 methods]"
    when_violated: "[action]"
    reference_good: "[path]"
  dip:
    relevance: "[high|medium|low]"
    metric: "[e.g., Domain/ imports zero from Infrastructure/]"
    when_violated: "[e.g., Port interface in Domain, Adapter in Infrastructure]"
    reference_good: "[path]"

conventions:
  naming:
    classes: "[PascalCase|camelCase|snake_case]"
    methods: "[camelCase|snake_case]"
    files: "[match-class-name|kebab-case|snake_case]"
  structure: {}    # Project-specific paths
  reference_files: {}   # Example files per archetype

quality_thresholds:
  max_class_loc: 200
  max_public_methods: 7
  max_constructor_deps: 7
  max_interface_methods: 5
  max_files_per_simple_change: 5
```

> **Note**: This profile is later enriched by `/workflows:compound` (Step 3c) with `learned_patterns` and `learned_antipatterns` as the project evolves.

### Step 5: Entity Specification Extraction

> **Agent**: `codebase-analyzer` | **Mode**: Entity Analysis

Extract domain entities and their specifications from the codebase:

```markdown
## Entity Specification Extraction

Scanning for domain entities and models...

### Detected Entities
| Entity | Location | Type | Attributes | Relations |
|--------|----------|------|------------|-----------|
| [EntityName] | `src/domain/entities/` | Aggregate/Entity/VO | X attrs | X relations |

### Entity Specification Format
For each entity, generate `openspec/specs/entities/[entity-name].yaml`:

```yaml
entity:
  name: "[EntityName]"
  type: "[aggregate|entity|value-object]"
  description: "[Purpose and business meaning]"

  attributes:
    - name: "[attr_name]"
      type: "[type]"
      required: true|false
      validation: "[rules]"
      description: "[meaning]"

  relations:
    - target: "[RelatedEntity]"
      type: "[one-to-one|one-to-many|many-to-many]"
      cardinality: "[0..1|1|0..*|1..*]"
      description: "[relationship meaning]"

  invariants:
    - "[Business rule that must always hold]"

  lifecycle:
    states: ["created", "active", "archived"]
    transitions:
      - from: "created"
        to: "active"
        trigger: "[event/action]"

  source_files:
    - "[path/to/entity.ts]"

  extracted_at: "[timestamp]"
```

### Extraction Depth
- **Surface**: Class/interface names and basic types
- **Standard**: Attributes, relations, basic validations
- **Deep**: Invariants, lifecycle, business rules embedded in code
```

### Step 6: API Contract Extraction

> **Agent**: `codebase-analyzer` | **Mode**: API Analysis

Extract API contracts and endpoint specifications:

```markdown
## API Contract Extraction

Scanning for API definitions...

### Sources Analyzed
| Source | Type | Endpoints Found |
|--------|------|-----------------|
| `routes/` | Express/Fastify routes | X |
| `controllers/` | Controller methods | X |
| `openapi.yaml` | OpenAPI spec | X |
| `*.graphql` | GraphQL schemas | X |

### Contract Specification Format
For each API group, generate `openspec/specs/api-contracts/[api-name].yaml`:

```yaml
api_contract:
  name: "[API Group Name]"
  version: "[detected version]"
  base_path: "/api/v1/[resource]"
  description: "[Purpose]"

  endpoints:
    - method: "GET|POST|PUT|PATCH|DELETE"
      path: "/[path]"
      description: "[what it does]"

      parameters:
        - name: "[param]"
          in: "path|query|header|body"
          type: "[type]"
          required: true|false
          validation: "[rules]"

      request:
        content_type: "application/json"
        schema:
          $ref: "#/schemas/[RequestDTO]"

      responses:
        - status: 200
          description: "Success"
          schema:
            $ref: "#/schemas/[ResponseDTO]"
        - status: 400
          description: "Validation error"
        - status: 401
          description: "Unauthorized"

      authentication: "[jwt|api-key|none]"
      rate_limit: "[if detected]"

  schemas:
    [SchemaName]:
      type: object
      properties:
        [field]: { type: "[type]" }

  source_files:
    - "[path/to/controller.ts]"
    - "[path/to/routes.ts]"

  extracted_at: "[timestamp]"
```

### Detection Methods
- Route decorator parsing (@Get, @Post, etc.)
- OpenAPI/Swagger file parsing
- GraphQL schema introspection
- Express/Fastify route analysis
- Controller method signature analysis
```

### Step 6b: External API Consumer Detection

> **Agent**: `codebase-analyzer` | **Mode**: API Consumer Analysis

Detect external APIs that the project CONSUMES (outgoing HTTP calls), as opposed to APIs it EXPOSES (incoming HTTP endpoints covered in Step 6).

```markdown
## External API Consumer Detection

Scanning for outgoing HTTP client usage and vendor SDK integrations...

### HTTP Client Detection
| Vendor/Library | Detected | Location | Usage Count |
|---------------|----------|----------|-------------|
| Symfony HttpClient | ✓/✗ | [files] | X calls |
| GuzzleHttp | ✓/✗ | [files] | X calls |
| curl (direct) | ✓/✗ | [files] | X calls |
| axios | ✓/✗ | [files] | X calls |
| fetch API | ✓/✗ | [files] | X calls |
| net/http (Go) | ✓/✗ | [files] | X calls |
| requests (Python) | ✓/✗ | [files] | X calls |

### Integration Pattern Analysis
| External API | SDK Used | Adapter Exists | Port/Interface Exists | ACL Compliant |
|-------------|----------|----------------|----------------------|---------------|
| [API Name] | [SDK] | ✓/✗ [path] | ✓/✗ [path] | ✓/✗ |

### Vendor SDK Isolation Check
| Layer | Vendor SDK Imports Found | Violation |
|-------|-------------------------|-----------|
| Domain/ | [list or "None"] | ✓/✗ |
| Application/ | [list or "None"] | ✓/✗ |
| Infrastructure/ | [list — expected here] | N/A |

### Async HTTP Pattern Detection
| Pattern | Detected | Location | Description |
|---------|----------|----------|-------------|
| Sequential calls | ✓/✗ | [files] | Multiple `->request()` in sequence |
| Promise/async batching | ✓/✗ | [files] | `Pool`, `Promise::all`, `stream()` |
| No concurrent calls | ✓/✗ | — | Single HTTP calls only |

### Serialization Pattern Detection
| Pattern | Detected | Location |
|---------|----------|----------|
| Symfony Serializer with @Groups | ✓/✗ | [files] |
| JMS Serializer | ✓/✗ | [files] |
| Manual toArray()/toJson() | ✓/✗ | [files] |
| Platform-specific DTOs | ✓/✗ | [files] |
| Transformer/Normalizer classes | ✓/✗ | [files] |

### Multi-Platform Output Detection
| Consumer | Response Format | Detected Via |
|----------|----------------|--------------|
| [Mobile app] | [Custom JSON] | [annotation/route/header] |
| [Web app] | [Full JSON] | [annotation/route/header] |
| [Single format] | [Standard] | [no platform differentiation] |
```

#### Detection Commands (stack-adapted)

```bash
# === HTTP Client Detection ===

# PHP
grep -rl "HttpClientInterface\|HttpClient::\|GuzzleHttp\|Client()" src/ 2>/dev/null | head -20
composer show 2>/dev/null | grep -i "http\|guzzle\|client"

# TypeScript/JavaScript
grep -rl "axios\|fetch(\|got(\|node-fetch\|superagent\|undici" src/ app/ lib/ 2>/dev/null | head -20

# Go
grep -rl "http.NewRequest\|http.Get\|http.Post\|http.Client" . --include="*.go" 2>/dev/null | head -20

# Python
grep -rl "requests.get\|requests.post\|httpx\|aiohttp\|urllib" . --include="*.py" 2>/dev/null | head -20

# === Adapter/Port Detection ===
find . -path "*/External/*" -name "*.php" -o -path "*/External/*" -name "*.ts" -o -path "*/External/*" -name "*.go" 2>/dev/null | head -20
grep -rl "ProviderInterface\|ClientInterface\|Gateway\|ApiAdapter" src/ 2>/dev/null | head -20

# === Serialization Detection ===
# PHP (Symfony)
grep -rl "@Groups\|@SerializedName\|NormalizerInterface\|SerializerInterface" src/ 2>/dev/null | head -20
grep -rl "JMS\\Serializer\|@Serializer\\" src/ 2>/dev/null | head -20

# TypeScript
grep -rl "class-transformer\|@Expose\|@Exclude\|plainToInstance" src/ 2>/dev/null | head -20

# === Multi-Platform Detection ===
grep -rl "platform\|X-Platform\|mobile\|web.*json\|app.*json" src/ 2>/dev/null | head -10
find . -name "*Mobile*DTO*" -o -name "*Web*DTO*" -o -name "*Mobile*Response*" -o -name "*Web*Response*" 2>/dev/null | head -10

# === Async HTTP Detection ===
# PHP
grep -rl "stream(\|Promise\|Pool::\|async\|concurrent\|amphp" src/ 2>/dev/null | head -10
# JS/TS
grep -rl "Promise.all\|Promise.allSettled\|Promise.race" src/ 2>/dev/null | head -10
# Go
grep -rl "sync.WaitGroup\|errgroup\|go func" . --include="*.go" 2>/dev/null | head -10
# Python
grep -rl "asyncio.gather\|concurrent.futures\|ThreadPoolExecutor" . --include="*.py" 2>/dev/null | head -10
```

#### Output Enrichment

Step 6b results are recorded in:
1. `openspec/specs/architecture-profile.yaml` under the new fields: `http_client_pattern`, `external_api_integration`, `serialization_strategy`, `multi_platform_output`, `data_aggregation_pattern`, and `external_apis_consumed`
2. A new spec file `openspec/specs/api-consumers/[api-name].yaml` for each detected external API

#### API Consumer Spec Format

For each detected external API, generate `openspec/specs/api-consumers/[api-name].yaml`:

```yaml
api_consumer:
  name: "[External API Name]"
  description: "[What this external API provides]"
  sdk: "[vendor/package-name]"

  integration:
    adapter: "[path/to/adapter]"
    port_interface: "[path/to/interface]"   # empty if missing (DIP violation)
    response_mapper: "[path/to/mapper]"     # empty if missing
    acl_compliant: true|false

  calls:
    - method: "GET|POST|PUT|DELETE"
      url_pattern: "[base_url/endpoint]"
      purpose: "[what this call retrieves/sends]"
      used_by: "[path/to/consuming/service]"

  async_grouping:
    grouped: true|false
    mechanism: "[Promise.all|Pool|stream|sequential]"

  response_mapping:
    vendor_types_leaked: true|false
    domain_dto: "[path/to/domain/dto]"

  source_files:
    - "[path/to/files]"

  extracted_at: "[timestamp]"
```

### Step 6c: Classify API Architecture Dimensions

> **Agent**: `codebase-analyzer` | **Mode**: Dimensional Classification
> **Template**: `core/templates/api-architecture-diagnostic.yaml`

This step does NOT detect anything new and does NOT generate constraints. It **classifies** the results already detected in Steps 2-6b into 6 architectural dimension values with supporting evidence. Constraint reasoning happens later in PLAN (Step 3.1b).

```markdown
## API Architecture Dimensional Profile

Classifying detected evidence into architectural dimensions...

### Dimensional Classification

Using results from Steps 2-6b, classify each dimension:

| Dimension | Value | Evidence Source |
|-----------|-------|----------------|
| **Data Flow** | [classified] | Step 2-3 (controllers = egress), Step 6b (HTTP clients = ingress) |
| **Data Source Topology** | [classified] | Step 6b (external API count + DB detection from Step 2) |
| **Consumer Diversity** | [classified] | Step 6b (serialization/multi-platform detection) |
| **Dependency Isolation** | [classified] | Step 6b (port + adapter + mapper per external API) |
| **Concurrency Model** | [classified] | Step 6b (async HTTP pattern detection) |
| **Response Customization** | [classified] | Step 6b (serialization pattern + platform-specific DTOs) |
```

#### Classification Rules

```
DIMENSION CLASSIFICATION (from Steps 2-6b evidence):

data_flow.primary:
  - HTTP client libs detected AND controllers detected → "bidirectional"
  - HTTP client libs detected, minimal controllers → "ingress"
  - Controllers detected, no HTTP clients → "egress"
  - 3+ external sources combined into single response → "aggregation"
  - Proxy routes, gateway patterns, minimal logic → "passthrough"
  - Mapper/transformer classes as primary pattern → "transformation"

data_source_topology.value:
  - No external APIs, one DB detected → "single_db"
  - No external APIs, multiple DBs → "multi_db"
  - 1 external API, no DB → "single_external"
  - 2+ external APIs, no DB → "multi_external"
  - External APIs + DB(s) → "mixed_db_external"
  - Message queues/event streams as primary → "event_driven"
  - Mix of DBs, APIs, and events → "hybrid"

consumer_diversity.value:
  - No platform differentiation detected → "single_consumer"
  - Platform-specific DTOs/serialization groups → "multi_platform"
  - Service-to-service contracts detected → "inter_service"
  - Public API docs/versioning detected → "public_api"
  - Combination of above → "mixed"

dependency_isolation.value:
  - No external APIs → "no_externals"
  - All externals have port + adapter + mapper → "fully_isolated"
  - Some adapters exist but ports/mappers missing → "partially_wrapped"
  - External SDKs used directly in Application/Domain → "direct_coupling"

concurrency_model.value:
  - No async patterns, sequential calls only → "synchronous"
  - Framework supports async but not used → "async_capable"
  - Async/concurrent patterns actively used → "fully_concurrent"
  - Single external call or no external calls → "not_applicable"

response_customization.value:
  - Same response for all consumers → "uniform"
  - Field filtering (e.g., ?fields=id,name) → "parameterized"
  - Different DTOs/transformers per consumer → "per_consumer_shaped"
  - Response varies by auth/role/feature flags → "context_dependent"
```

#### Output

Write the dimensional profile to `openspec/specs/api-architecture-diagnostic.yaml` using the template:

```bash
# Copy template and populate with classified values
cp plugins/workflow/core/templates/api-architecture-diagnostic.yaml openspec/specs/api-architecture-diagnostic.yaml

# Fill in:
# - diagnostic_version, generated_at, generated_by
# - Each dimension's value and evidence[]
# - For data_source_topology: external_sources[] detail
# - For consumer_diversity: consumers[] detail
# - For dependency_isolation: violations[] detail
# - For concurrency_model: sequential_bottlenecks[], framework_async_support
# - extracted_from[], extraction_method, last_validated
```

> **Important**: This file is a DETECTION artifact — it describes what IS, not what should be. No constraints, no prescriptions. Constraint reasoning is the responsibility of PLAN (Step 3.1b), which reads these dimensions and generates per-feature constraints.

> **Skip condition**: If Step 6b found no external APIs AND no multi-platform output AND no multi-source aggregation, skip this step (the project has no API architecture complexity to classify).

### Step 7: Business Rule Extraction

> **Agent**: `codebase-analyzer` | **Mode**: Business Rule Analysis

Extract business rules and domain logic:

```markdown
## Business Rule Extraction

Analyzing domain logic for business rules...

### Rule Sources
| Source | Location | Rules Found |
|--------|----------|-------------|
| Domain Services | `src/domain/services/` | X |
| Entity Methods | `src/domain/entities/` | X |
| Validators | `src/domain/validators/` | X |
| Specifications | `src/domain/specifications/` | X |
| Policy Classes | `src/domain/policies/` | X |

### Business Rule Specification Format
Generate `openspec/specs/business-rules/[domain-area].yaml`:

```yaml
business_rules:
  domain_area: "[Area Name]"
  description: "[What this area covers]"

  rules:
    - id: "BR-[AREA]-001"
      name: "[Human-readable name]"
      description: "[What the rule enforces]"

      type: "[validation|calculation|authorization|workflow|constraint]"

      condition:
        when: "[trigger condition]"
        given: "[preconditions]"
        then: "[expected outcome]"

      implementation:
        location: "[file path]"
        method: "[method name]"
        pattern: "[specification|policy|validator|guard]"

      exceptions:
        - "[when rule doesn't apply]"

      related_entities:
        - "[Entity1]"
        - "[Entity2]"

      test_coverage:
        unit_tests: "[path to tests]"
        scenarios_tested: X

      priority: "[critical|high|medium|low]"

  cross_cutting_rules:
    - id: "BR-CROSS-001"
      name: "[Rule spanning multiple areas]"
      affected_areas: ["Area1", "Area2"]
      description: "[rule description]"

  source_files:
    - "[path/to/service.ts]"

  extracted_at: "[timestamp]"
```

### Rule Detection Heuristics
- Guard clauses and validation logic
- if/throw patterns with business messages
- Specification pattern implementations
- Policy class decisions
- Domain event triggers
```

### Step 8: Architectural Constraint Extraction

> **Agent**: `codebase-analyzer` | **Mode**: Constraint Analysis

Extract architectural constraints and design decisions:

```markdown
## Architectural Constraint Extraction

Analyzing codebase for architectural constraints...

### Constraint Categories
| Category | Source | Constraints Found |
|----------|--------|-------------------|
| Layer Dependencies | Import analysis | X |
| Module Boundaries | Package structure | X |
| Design Patterns | Code patterns | X |
| Security Constraints | Auth/Authz code | X |
| Performance Constraints | Caching/optimization | X |

### Constraint Specification Format
Generate `openspec/specs/architectural-constraints/[category].yaml`:

```yaml
architectural_constraints:
  category: "[Category Name]"
  description: "[What these constraints govern]"

  layer_constraints:
    - name: "Domain Layer Purity"
      description: "Domain layer has no external dependencies"
      rule: "src/domain/** cannot import from src/infrastructure/**"
      enforcement: "[eslint-rule|architect-review|ci-check]"
      violations_found: X

    - name: "Dependency Direction"
      description: "Dependencies point inward"
      layers:
        - { name: "presentation", can_depend_on: ["application"] }
        - { name: "application", can_depend_on: ["domain"] }
        - { name: "domain", can_depend_on: [] }

  module_constraints:
    - name: "[Module Boundary]"
      description: "[What the boundary enforces]"
      modules:
        - name: "[ModuleName]"
          public_api: "[exposed interface]"
          internal: "[hidden implementation]"
          dependencies: ["[allowed modules]"]

  pattern_constraints:
    - name: "Repository Pattern"
      description: "All data access through repositories"
      applies_to: "src/domain/**"
      pattern: "Repository"
      anti_patterns: ["Direct DB calls in domain"]

    - name: "[Pattern Name]"
      applies_to: "[scope]"
      required: true|false

  security_constraints:
    - name: "[Security Constraint]"
      description: "[What it protects]"
      enforcement: "[how enforced]"
      scope: "[affected areas]"

  performance_constraints:
    - name: "[Performance Constraint]"
      description: "[What it optimizes]"
      threshold: "[metric]"
      implementation: "[how achieved]"

  technology_constraints:
    - name: "[Tech Constraint]"
      description: "[Why this constraint exists]"
      allowed: ["[tech1]", "[tech2]"]
      forbidden: ["[tech3]"]
      reason: "[rationale]"

  source_evidence:
    - "[path/to/architectural/decision]"

  extracted_at: "[timestamp]"
```

### Detection Methods
- Import/dependency graph analysis
- Package.json/tsconfig path mappings
- ESLint/architecture rules
- ADR (Architecture Decision Records) parsing
- Code pattern recognition
```

### Step 9: Generate Spec Manifest

Create `openspec/specs/spec-manifest.yaml` to index all extracted specs:

```yaml
# Auto-generated spec manifest
# Updated by /workflows:discover on [DATE]

manifest:
  version: "1.0"
  generated_at: "[timestamp]"
  project: "[project-name]"

  statistics:
    entities: X
    api_contracts: X
    business_rules: X
    architectural_constraints: X
    api_consumers: X
    total_specs: X

  entities:
    - name: "[Entity1]"
      file: "entities/entity1.yaml"
      type: "aggregate"
      last_updated: "[timestamp]"

  api_contracts:
    - name: "[API1]"
      file: "api-contracts/api1.yaml"
      endpoints: X
      last_updated: "[timestamp]"

  business_rules:
    - domain_area: "[Area1]"
      file: "business-rules/area1.yaml"
      rules_count: X
      critical_rules: X
      last_updated: "[timestamp]"

  architectural_constraints:
    - category: "[Category1]"
      file: "architectural-constraints/category1.yaml"
      constraints_count: X
      last_updated: "[timestamp]"

  api_consumers:
    - name: "[ExternalAPI1]"
      file: "api-consumers/external-api1.yaml"
      acl_compliant: true|false
      last_updated: "[timestamp]"

  api_architecture_diagnostic:
    file: "api-architecture-diagnostic.yaml"
    dimensions_classified: X
    constraints_must: X
    constraints_should: X
    last_updated: "[timestamp]"

  extraction_config:
    extract_specs: true
    depth: "standard"
    include_tests: false

  next_recommended_update: "[timestamp + 7 days]"
```

### Step 10: Scan Code Patterns (Skip if --specs-only)

```markdown
## Patrones de Código Detectados

### Naming Conventions
| Tipo | Patrón Detectado | Ejemplo |
|------|------------------|---------|
| Archivos | kebab-case / PascalCase / camelCase | `user-service.ts` |
| Clases | PascalCase | `UserService` |
| Funciones | camelCase | `getUserById` |
| Variables | camelCase | `userId` |
| Constantes | UPPER_SNAKE | `MAX_RETRIES` |
| Interfaces | I-prefix / no-prefix | `IUserRepository` |

### Code Style
- Indentation: [tabs/spaces, size]
- Quotes: [single/double]
- Semicolons: [yes/no]
- Line length: [detected max]
- Import style: [absolute/relative]

### Testing Patterns
| Tipo | Framework | Ubicación | Cobertura Estimada |
|------|-----------|-----------|-------------------|
| Unit | Jest/PHPUnit/pytest | `__tests__/`, `tests/` | X% |
| Integration | Supertest/etc | `tests/integration/` | X% |
| E2E | Playwright/Cypress | `e2e/`, `tests/e2e/` | X% |
```

### Step 11: Analyze Dependencies (Skip if --specs-only)

```markdown
## Análisis de Dependencias

### Core Dependencies
| Paquete | Versión | Propósito |
|---------|---------|-----------|
| [framework] | vX.X | Core framework |
| [orm] | vX.X | Database |
| [auth] | vX.X | Authentication |

### Dev Dependencies Relevantes
| Paquete | Propósito |
|---------|-----------|
| [test-framework] | Testing |
| [linter] | Code quality |
| [formatter] | Formatting |

### Potential Security Concerns
[Ejecutar audit si disponible]

### Dependency Graph Highlights
- Total dependencies: X
- Direct: X
- Transitive: X
- Outdated: X
```

### Step 12: Git History Analysis (Skip if --specs-only)

```markdown
## Análisis de Historia Git

### Repository Stats
| Métrica | Valor |
|---------|-------|
| Total commits | X |
| Contributors | X |
| First commit | YYYY-MM-DD |
| Last commit | YYYY-MM-DD |
| Active branches | X |

### Commit Patterns
| Patrón | Uso |
|--------|-----|
| Conventional Commits | ✓/✗ |
| Prefix style | feat:/fix:/etc |
| Typical commit size | X files, X lines |

### Hotspots (most changed files)
| Archivo | Cambios | Riesgo |
|---------|---------|--------|
| [file1] | X commits | Alto/Medio/Bajo |
| [file2] | X commits | Alto/Medio/Bajo |

### Recent Activity
[Últimos 10 commits relevantes]
```

### Step 13: Detect Existing Documentation (Skip if --specs-only)

```markdown
## Documentación Existente

| Archivo | Tipo | Estado |
|---------|------|--------|
| `README.md` | General | ✓/✗ |
| `CONTRIBUTING.md` | Contribution | ✓/✗ |
| `docs/` | Documentation folder | ✓/✗ |
| `API.md` | API docs | ✓/✗ |
| `CHANGELOG.md` | Change history | ✓/✗ |
| `.ai/` | AI context | ✓/✗ |

### Code Documentation
- JSDoc/TSDoc/PHPDoc coverage: X%
- README in key directories: X/Y
```

### Step 14: Generate Project Profile (Skip if --specs-only)

Create `.ai/project/intelligence/project-profile.md`:

```markdown
# Project Profile: [Project Name]

> Auto-generated by /workflows:discover on [DATE]
> Last updated: [TIMESTAMP]

---

## Quick Facts

| Attribute | Value |
|-----------|-------|
| **Type** | [Web App / API / Library / CLI / Monorepo] |
| **Primary Language** | [TypeScript / PHP / Python / etc] |
| **Framework** | [React + Node / Symfony / Django / etc] |
| **Architecture** | [DDD / MVC / Clean / Monolith / Microservices] |
| **Database** | [PostgreSQL / MySQL / MongoDB / etc] |
| **Complexity** | [Low / Medium / High / Very High] |
| **Test Coverage** | [X%] |
| **Team Size** | [Solo / Small / Medium / Large] (inferred from git) |

---

## Tech Stack

### Backend
- **Runtime**: [Node.js 20 / PHP 8.3 / Python 3.12]
- **Framework**: [Express / NestJS / Symfony / FastAPI]
- **ORM**: [Prisma / TypeORM / Doctrine / SQLAlchemy]
- **Auth**: [JWT / Session / OAuth]

### Frontend
- **Framework**: [React 18 / Vue 3 / Angular 17]
- **State**: [Redux / Zustand / Pinia]
- **Styling**: [Tailwind / CSS Modules / Styled Components]
- **Build**: [Vite / Webpack / Turbopack]

### Infrastructure
- **Container**: [Docker / Podman]
- **CI/CD**: [GitHub Actions / GitLab CI / Jenkins]
- **Cloud**: [AWS / GCP / Azure / Vercel]
- **Monitoring**: [DataDog / Sentry / etc]

---

## Architecture Overview

### Structure
```
[Simplified directory tree with annotations]
```

### Patterns in Use
- [Pattern 1]: Used in [location], purpose: [why]
- [Pattern 2]: Used in [location], purpose: [why]

### Key Abstractions
| Abstraction | Location | Purpose |
|-------------|----------|---------|
| Repository | `src/infrastructure/repositories/` | Data access |
| Service | `src/application/services/` | Business logic |
| Controller | `src/presentation/controllers/` | HTTP handling |

### Companion: Architecture Profile
> Detailed architecture analysis (stack, SOLID relevance, patterns, quality thresholds) is maintained in
> `openspec/specs/architecture-profile.yaml` (generated by Step 4). The project profile provides a
> human-readable overview; the architecture profile provides machine-readable detail for the solid-analyzer
> and other automated skills.

---

## Code Conventions

### Naming
```typescript
// Files: kebab-case
user-service.ts

// Classes: PascalCase
class UserService {}

// Functions: camelCase
function getUserById() {}

// Interfaces: PascalCase (no I-prefix)
interface UserRepository {}
```

### Style Rules
- Indent: 2 spaces
- Quotes: single
- Semicolons: no
- Max line: 100 chars
- Imports: absolute paths from `src/`

### Testing Convention
- Unit tests: `*.test.ts` next to source
- Integration: `tests/integration/`
- E2E: `e2e/`
- Coverage target: 80%

---

## Reference Implementations

When implementing new features, use these as templates:

### Entity Example
→ `src/domain/entities/User.ts`

### Repository Example
→ `src/infrastructure/repositories/UserRepository.ts`

### Service Example
→ `src/application/services/AuthService.ts`

### Controller Example
→ `src/presentation/controllers/UserController.ts`

### Component Example
→ `src/components/UserProfile/UserProfile.tsx`

### Test Example
→ `src/domain/entities/User.test.ts`

---

## Known Patterns & Anti-Patterns

### Patterns to Follow
1. **[Pattern Name]**: [Description and when to use]
2. **[Pattern Name]**: [Description and when to use]

### Anti-Patterns to Avoid
1. **[Anti-Pattern]**: [Why and what to do instead]
2. **[Anti-Pattern]**: [Why and what to do instead]

---

## Project Health

### Strengths
- ✅ [Strength 1]
- ✅ [Strength 2]

### Areas for Improvement
- ⚠️ [Area 1]: [Recommendation]
- ⚠️ [Area 2]: [Recommendation]

### Technical Debt
| Item | Severity | Location |
|------|----------|----------|
| [Debt item] | High/Med/Low | [File/area] |

---

## Workflow Recommendations

Based on this project's characteristics:

| Task Type | Recommended Workflow | Why |
|-----------|---------------------|-----|
| New Feature | `/workflows:plan` (full) | Complex architecture needs planning |
| Bug Fix | `/workflows:route` → work | Direct fix with review |
| Refactor | `/workflows:plan` + `/workflows:work` | SOLID analysis in plan phase |
| Performance | Performance Review Agent | Specialized analysis |

### Trust Level by Area
| Area | Trust | Approach |
|------|-------|----------|
| Domain layer | High | Established patterns |
| New modules | Medium | Verify with reviewer |
| External integrations | Low | Extra review needed |

---

## Quick Commands for This Project

```bash
# Run tests
[detected test command]

# Start dev server
[detected dev command]

# Build
[detected build command]

# Lint
[detected lint command]

# Type check
[detected type check command]
```

---

*Profile regenerated automatically. Manual edits will be preserved in sections marked `<!-- CUSTOM -->`*
```

### Step 15: Generate Config if Missing (Skip if --specs-only)

If `.ai/project/config.yaml` doesn't exist, create it:

```yaml
# Auto-generated by /workflows:discover
# Manual edits are preserved on refresh

project:
  name: "[detected]"
  type: "[web-app|api|library|cli|monorepo]"
  description: "[from README or package.json]"

backend:
  framework: "[detected]"
  language: "[detected]"
  path: "[detected]"

frontend:
  framework: "[detected]"
  language: "[detected]"
  path: "[detected]"

database:
  type: "[detected]"
  orm: "[detected]"

architecture:
  pattern: "[ddd|mvc|clean|hexagonal|feature-based]"
  layers:
    - name: domain
      path: src/domain
    - name: application
      path: src/application
    - name: infrastructure
      path: src/infrastructure

testing:
  framework: "[detected]"
  coverage_target: 80
  locations:
    unit: "**/*.test.ts"
    integration: "tests/integration/"
    e2e: "e2e/"

conventions:
  commits: conventional
  branches: "[detected pattern]"
  file_naming: kebab-case

ai_analysis:
  last_scan: "[timestamp]"
  complexity: "[low|medium|high|very-high]"
  detected_patterns: []
  reference_files: {}

workflow:
  default: standard
  auto_refresh: true
  session_max_messages: 50
```

### Step 16: Display Summary

```markdown
╔══════════════════════════════════════════════════════════════════════╗
║                    Discovery Completado                              ║
╚══════════════════════════════════════════════════════════════════════╝

## Resumen del Proyecto

| Aspecto | Detectado |
|---------|-----------|
| **Nombre** | [project-name] |
| **Tipo** | [type] |
| **Stack** | [backend] + [frontend] |
| **Arquitectura** | [pattern] |
| **Complejidad** | [level] |

## Archivos Generados

✅ `.ai/project/intelligence/project-profile.md` - Perfil completo
✅ `.ai/project/config.yaml` - Configuración del proyecto
✅ `.ai/project/context.md` - Contexto para agentes
✅ `openspec/specs/architecture-profile.yaml` - Architecture profile (stack, SOLID, patterns, thresholds)

### Spec Files (if --extract-specs enabled)

✅ `openspec/specs/entities/*.yaml` - Entity specifications
✅ `openspec/specs/api-contracts/*.yaml` - API contract definitions
✅ `openspec/specs/business-rules/*.yaml` - Business rule documentation
✅ `openspec/specs/architectural-constraints/*.yaml` - Architecture constraints
✅ `openspec/specs/spec-manifest.yaml` - Spec index and metadata

## Conocimiento Capturado

- 📁 Estructura: [X] directorios mapeados
- 🔧 Patrones: [X] patrones detectados
- 📦 Dependencias: [X] analizadas
- 📝 Commits: [X] analizados
- 🎯 Referencias: [X] archivos template identificados

## Specs Extracted (if --extract-specs enabled)

| Spec Type | Count | Files Generated |
|-----------|-------|-----------------|
| **Entities** | [X] | `openspec/specs/entities/` |
| **API Contracts** | [X] | `openspec/specs/api-contracts/` |
| **Business Rules** | [X] | `openspec/specs/business-rules/` |
| **Architectural Constraints** | [X] | `openspec/specs/architectural-constraints/` |
| **API Consumers** | [X] | `openspec/specs/api-consumers/` |
| **API Architecture Diagnostic** | [1 if generated] | `openspec/specs/api-architecture-diagnostic.yaml` |
| **Total Specs** | [X] | See `spec-manifest.yaml` |

> Specs extracted by `codebase-analyzer` agent. Run `/workflows:discover --specs-only` to update specs without full discovery.

## Próximos Pasos

1. **Revisar el perfil**: `cat .ai/project/intelligence/project-profile.md`
2. **Ajustar si necesario**: Edita `config.yaml` para correcciones
3. **Empezar a trabajar**: `/workflows:plan tu-feature`

> El plugin ahora tiene conocimiento profundo de tu proyecto.
> Este conocimiento se usa automáticamente en planning y reviews.
```

## Flags

| Flag | Description |
|------|-------------|
| `--full` | Análisis completo desde cero (sobrescribe) |
| `--refresh` | Actualiza solo lo que cambió |
| `--report` | Solo muestra el perfil actual sin re-escanear |
| `--setup` | Interactive onboarding: auto-detect stack + configure plugin |
| `--seed` | Project Seed: generate compound-equivalent knowledge from requirements (greenfield) |
| `--seed --stack=X` | Specify stack explicitly for seed (e.g., symfony, laravel, nextjs) |
| `--reset` | Force reconfiguration (with --setup) |
| `--quiet` | Menos output, solo errores |
| `--extract-specs` | Enable spec extraction (default: true) |
| `--no-extract-specs` | Disable spec extraction |
| `--specs-only` | Only extract specs, skip profile generation |
| `--specs-depth=[surface\|standard\|deep]` | Depth of spec extraction (default: standard) |

## Integration with Other Commands

- **`/workflows:plan`**: Lee el project-profile para informar planificación
- **`/workflows:work`**: Usa convenciones detectadas para código consistente
- **`/workflows:review`**: Valida contra patrones documentados
- **`/workflows:compound`**: Actualiza perfil con nuevos aprendizajes

### Spec Extraction Agent

The `codebase-analyzer` agent is responsible for all specification extraction:

| Mode | Purpose | Output |
|------|---------|--------|
| Entity Analysis | Extract domain entities and models | `specs/entities/*.yaml` |
| API Analysis | Extract API contracts and endpoints | `specs/api-contracts/*.yaml` |
| Business Rule Analysis | Extract business rules and domain logic | `specs/business-rules/*.yaml` |
| Constraint Analysis | Extract architectural constraints | `specs/architectural-constraints/*.yaml` |

The agent uses static analysis, pattern recognition, and AST parsing to extract specifications from the codebase without requiring runtime execution.

## Auto-Discovery Triggers

El discovery se ejecuta automáticamente cuando:
1. Se detecta que no existe `.ai/project/config.yaml`
2. Han pasado más de 7 días desde el último scan
3. Se detectan cambios significativos en `package.json` o equivalente

---

## Setup Mode (`--setup`)

Interactive onboarding that auto-detects your project stack and configures the plugin. Replaces the former `/workflows:quickstart` command.

### When to Use

- **First time** using the plugin in a project
- After `--reset` to reconfigure from scratch
- When onboarding a new team member to an existing project

### Setup Protocol

#### Setup Step 0: Check if Already Configured

```
if .ai/project/ directory exists AND --reset flag NOT provided:
  OUTPUT: "This project is already configured."
  SHOW: Current configuration summary
  ASK: "Do you want to reconfigure? (use --reset to force)"
  EXIT
```

#### Setup Step 1: Auto-Detect Project Stack

Runs the standard discovery Steps 2-3 (detect stack + analyze structure), then presents:

```markdown
## Detected Stack

| Component       | Detected           | Source              |
|----------------|-------------------|---------------------|
| Backend        | [detected]         | [source file]       |
| Frontend       | [detected]         | [source file]       |
| Architecture   | [detected]         | [evidence]          |
| Database       | [detected]         | [source file]       |
| Testing        | [detected]         | [source file]       |
| Containerized  | Yes/No             | [source file]       |

> Correct? If not, I'll adjust. Otherwise, let's continue.
```

#### Setup Step 2: Ask Only What Cannot Be Detected (2-3 questions max)

**Question 1: Execution Mode**

```
How do you want to work with the AI agents?

  [1] Agent Executes (Recommended)
      → AI writes code, runs tests, auto-corrects. You review at checkpoints.

  [2] Hybrid
      → AI writes code but pauses before each checkpoint for your approval.

  [3] Human Guided
      → AI plans and instructs. You write the code. AI verifies.
```

**Question 2: Review Intensity**

```
How strict should code reviews be?

  [1] Strict (Recommended for teams / production code)
      → All review agents run. Full SOLID compliance verification required.

  [2] Balanced
      → Core review agents (security, architecture, code). SOLID compliance verified.

  [3] Light (Good for prototypes / MVPs)
      → Only security review + basic code quality. SOLID informational only.
```

**Question 3: Team Context** (only if not detectable)

```
Is this a solo project or a team project?

  [1] Solo developer
  [2] Small team (2-5)
  [3] Larger team (5+)
```

#### Setup Step 3: Generate Project Configuration

Based on detection + answers, generate the `.ai/` directory structure:

```bash
.ai/
├── project/
│   ├── specs/
│   │   ├── entities/
│   │   ├── api-contracts/
│   │   ├── business-rules/
│   │   └── spec-manifest.yaml
│   ├── features/
│   ├── compound_log.md
│   ├── compound-memory.md
│   ├── validation-learning-log.md
│   └── analysis/
└── extensions/
```

Generate `providers-override.yaml` and initialize `compound-memory.md` and `validation-learning-log.md` with project profile and default calibration.

#### Setup Step 4: Show "The Flow" and Next Step

```markdown
## You're Ready!

Here's how the workflow works:

  ROUTE → SHAPE → PLAN → WORK → REVIEW → COMPOUND

### Your Next Step

Run this command to start your first feature:

  /workflows:route <describe your feature>

### Quick Reference

| Command             | What it does                    |
|--------------------|--------------------------------|
| /workflows:route   | Classify and route your request |
| /workflows:plan    | Create implementation plan      |
| /workflows:work    | Execute the plan                |
| /workflows:review  | Quality review                  |
| /workflows:compound| Capture learnings               |
| /workflows:help    | Full reference                  |
```

---

---

## Project Seed Mode (`--seed`)

**Purpose**: For greenfield projects, generate the equivalent of compound learnings BEFORE any feature is implemented. This gives the first feature's plan the same quality advantage that the 5th feature normally has.

### The Problem It Solves

```
WITHOUT seed:
  Feature 1: Plans from scratch → slow, many mistakes
  Feature 2: Some learnings from Feature 1
  Feature 3: Better, but still discovering patterns
  Feature 5: Finally fast — compound knowledge is rich

WITH seed:
  /workflows:discover --seed (10 minutes)
  Feature 1: Plans with compound-equivalent knowledge → fast, fewer mistakes
  Feature 2: Even better — real compound + seed compound
```

### When to Use

- **New project**: You have requirements but no code yet
- **Existing project, first time using plugin**: You have code but no compound history
- **Stack migration**: You're rebuilding in a new stack and want to front-load knowledge

### Seed Protocol

#### Seed Step 0: Gather Project Requirements

If the user hasn't provided requirements, ask:

```
To generate a Project Seed, I need to understand your project:

1. **What does the project do?** (2-3 sentences)
2. **What's the tech stack?** (language, framework, database)
3. **What are the main entities/concepts?** (list them)
4. **What user roles exist?** (admin, user, etc.)
5. **Any external integrations?** (APIs, services, SDKs)
6. **What's the architecture preference?** (hexagonal, MVC, clean, etc.)

Alternatively: paste your full requirements document and I'll extract everything.
```

If the user provides a requirements document (like a feature list, PRD, or freeform description), extract all the above from the document automatically.

#### Seed Step 1: Domain Entity Extraction

From the requirements, identify all domain entities, their relationships, and lifecycle:

```markdown
## Domain Entity Map (extracted from requirements)

### Entities Detected
| Entity | Type | Key Attributes | Relations | Lifecycle States |
|--------|------|---------------|-----------|-----------------|
| ${entity} | aggregate/entity/VO | ${attrs} | ${relations} | ${states} |

### Entity Relationship Diagram (text)
${entity1} 1──N ${entity2}
${entity2} N──1 ${entity3}
...

### Bounded Contexts (if detectable)
| Context | Entities | Responsibility |
|---------|----------|---------------|
| ${context} | ${entities} | ${what_it_manages} |
```

Write preliminary entity specs to `openspec/specs/entities/` using the entity spec format from Step 5.

#### Seed Step 2: Generate Architecture Profile

Based on the stated stack and detected domain complexity, generate `openspec/specs/architecture-profile.yaml`:

```yaml
# openspec/specs/architecture-profile.yaml
# Generated by /workflows:discover --seed on ${DATE}
# Source: Project requirements analysis (no codebase yet)
# NOTE: This is a SEED profile. It will be validated and enriched
#       by /workflows:discover --setup once code exists, and by
#       /workflows:compound after each feature.

stack:
  language: "${detected_or_stated}"       # e.g., php
  framework: "${detected_or_stated}"      # e.g., symfony
  paradigm: "${inferred}"                 # e.g., oop
  type_system: "${inferred}"              # e.g., strong-static

architecture:
  pattern: "${recommended_based_on_complexity}"  # e.g., hexagonal
  layers:
    - name: Domain
      path: "src/Domain/"
      depends_on: []
    - name: Application
      path: "src/Application/"
      depends_on: [Domain]
    - name: Infrastructure
      path: "src/Infrastructure/"
      depends_on: [Domain, Application]
  separation_enforced: true

patterns_detected:            # "recommended" for seed (no code to detect yet)
  data_access: "${recommended}"         # e.g., repository
  dependency_management: "${recommended}"  # e.g., constructor-injection
  error_handling: "${recommended}"       # e.g., exceptions
  async_pattern: "${recommended_if_needed}"  # e.g., none, or async-await for websocket
  testing_approach: tdd

solid_relevance:
  srp:
    relevance: "${based_on_stack}"
    metric: "${stack_appropriate_metric}"
    when_violated: "${stack_appropriate_fix}"
  ocp:
    relevance: "${based_on_requirements}"   # high if multiple strategies/types detected
    metric: "${metric}"
    when_violated: "${fix}"
  lsp:
    relevance: "${based_on_inheritance_needs}"
    metric: "${metric}"
    when_violated: "${fix}"
  isp:
    relevance: "${based_on_stack}"  # high for PHP/Java (explicit interfaces)
    metric: "${metric}"
    when_violated: "${fix}"
  dip:
    relevance: "${based_on_architecture}"  # critical for hexagonal
    metric: "${metric}"
    when_violated: "${fix}"

conventions:
  naming:
    classes: PascalCase
    methods: camelCase
    files: match-class-name
  structure:
    entity_path: "src/Domain/Entity/"
    usecase_path: "src/Application/UseCase/"
    repository_interface_path: "src/Domain/Port/"
    repository_impl_path: "src/Infrastructure/Persistence/"

quality_thresholds:
  max_class_loc: 200
  max_public_methods: 7
  max_constructor_deps: 7
  max_interface_methods: 5
  max_files_per_simple_change: 5

# SEED-specific: pre-populated from domain analysis
learned_patterns: []           # Empty — will be populated by compound
learned_antipatterns: []       # Empty — will be populated by compound
```

#### Seed Step 3: Generate Compound Memory Seed

This is the key differentiator. Analyze the requirements and the chosen stack to pre-populate `.ai/project/compound-memory.md` with **known pain points and patterns for this type of project**:

```markdown
# Compound Memory (Seeded)
# Generated by /workflows:discover --seed on ${DATE}
# Source: Requirements analysis + ${stack} best practices
# NOTE: This is SEEDED knowledge, not learned from this project.
#       Entries marked [SEED] will be validated/promoted by compound after real features.

## Known Pain Points

### [SEED] ${pain_point_1_title}
- **Area**: ${module_or_layer}
- **Description**: ${description_based_on_stack_and_domain}
- **Prevention**: ${how_to_prevent}
- **Severity**: ${high/medium/low}
- **Source**: ${stack} best practices / common ${domain} pitfalls
- **Frequency**: predicted (not yet validated)

### [SEED] ${pain_point_2_title}
...

## Historical Patterns

### [SEED] ${pattern_1_title}
- **Pattern**: ${description}
- **When to use**: ${context}
- **Reference**: ${stack_documentation_or_convention}
- **Reliability**: predicted (not yet validated)
- **Source**: ${stack} conventions

### [SEED] ${pattern_2_title}
...

## Agent Calibration (Seeded)

| Agent | Default Intensity | Seed Adjustment | Reason |
|-------|------------------|-----------------|--------|
| security-reviewer | default | ${adjusted_if_auth_payments} | ${reason} |
| performance-reviewer | default | ${adjusted_if_realtime} | ${reason} |
| architecture-reviewer | default | HIGH (new project) | First features define architecture |
| code-reviewer | default | default | No project-specific data yet |
```

**Stack-specific seed knowledge to include:**

| Stack | Known Pain Points to Seed | Patterns to Seed |
|-------|--------------------------|-----------------|
| **Symfony** | Doctrine lazy loading N+1, Messenger misconfiguration, Security voter complexity | Repository pattern, Form types, Voter pattern, Event subscribers |
| **Laravel** | Eloquent N+1, Service container binding, Queue job failures | Repository + Eloquent, Form Requests, Policy pattern, Job dispatching |
| **NestJS** | Circular dependency injection, TypeORM migration issues, Guard complexity | Module pattern, DTO validation with class-validator, Guard + Strategy |
| **Next.js** | Server/client component confusion, hydration mismatches, API route auth | Server actions, ISR/SSG patterns, middleware auth |
| **FastAPI** | Async/sync mixing, Pydantic V2 migration, Alembic migration complexity | Dependency injection, Pydantic models, SQLAlchemy repos |
| **Spring Boot** | Bean lifecycle issues, JPA lazy init outside transaction, Security filter chain | Repository pattern, Service layer, @Transactional boundaries |

**Domain-specific seed knowledge to include:**

| Domain Pattern | Known Pain Points | Patterns to Seed |
|---------------|------------------|-----------------|
| **Real-time tracking** | WebSocket connection management, GPS data volume, map rendering performance | Event-driven updates, data throttling/batching, GeoJSON format |
| **Multi-tenant (roles)** | Permission leaks between tenants, query scope forgetting tenant filter | Voter/Policy per role, global query scopes, middleware tenant resolver |
| **External API integration** | Rate limiting, SDK version changes, response format changes | Anti-corruption layer, adapter pattern, circuit breaker |
| **CRUD management** | Boring but error-prone validation, soft delete inconsistency | Shared base entity, validation VOs, soft delete trait/filter |
| **Delivery/logistics** | Route optimization complexity, status transition bugs, concurrent delivery updates | State machine for deliveries, optimistic locking, event sourcing for tracking |
| **Authentication with DNI/ID** | Input format validation across countries, privacy/GDPR | Validated VO for ID numbers, data encryption at rest, audit logging |

#### Seed Step 4: Generate Next Feature Briefing (Feature Roadmap)

Analyze the requirements to determine the optimal feature implementation order and generate `.ai/project/next-feature-briefing.md`:

```markdown
# Next Feature Briefing (Seeded)
# Generated by /workflows:discover --seed on ${DATE}
# Source: Requirements analysis + dependency mapping
# NOTE: This is the INITIAL roadmap. Updated by compound after each feature.

## Recommended Feature Order

Based on dependency analysis of your requirements:

| Order | Feature | Dependencies | Why This Order | Estimated Complexity |
|-------|---------|-------------|---------------|---------------------|
| 1 | ${feature_1} | None (foundation) | ${reason} | ${simple/medium/complex} |
| 2 | ${feature_2} | ${feature_1} | ${reason} | ${complexity} |
| 3 | ${feature_3} | ${feature_1}, ${feature_2} | ${reason} | ${complexity} |
| ... | ... | ... | ... | ... |

## Feature Dependency Graph

${feature_1} (foundation)
├── ${feature_2} (depends on ${feature_1})
│   ├── ${feature_3} (depends on ${feature_2})
│   └── ${feature_4} (depends on ${feature_2})
└── ${feature_5} (depends on ${feature_1})
    └── ${feature_6} (depends on ${feature_5})

## Reusable Patterns (Predicted)

| Pattern | First Needed In | Reused By | When to Use |
|---------|----------------|-----------|-------------|
| ${pattern} | Feature ${N} | Features ${M, O, P} | ${context} |

## Known Risks (Predicted from Requirements)

| Risk | Area | Mitigation | Affects Features |
|------|------|-----------|-----------------|
| ${risk} | ${area} | ${mitigation} | ${features} |

## Recommended First Feature

**Start with**: ${first_feature_name}

**Why**: ${rationale — typically the one that establishes domain model, auth, or core CRUD}

**What it establishes for future features**:
- Domain entities: ${list}
- Patterns: ${list}
- Infrastructure: ${list}

**Run**: `/workflows:plan ${first_feature_slug}`
```

#### Seed Step 5: Generate Project Directories and Configuration

Create the project structure for the chosen stack:

```bash
# Create project intelligence directories
mkdir -p .ai/project/intelligence
mkdir -p openspec/specs/entities
mkdir -p openspec/specs/api-contracts
mkdir -p openspec/specs/business-rules
mkdir -p openspec/specs/architectural-constraints
mkdir -p openspec/specs/api-consumers
mkdir -p openspec/changes
```

Also generate:
- `.ai/project/config.yaml` with detected stack info
- `.ai/project/compound_log.md` with seed entry
- `openspec/specs/constitution.md` from requirements (non-negotiable principles extracted from user requirements)

#### Seed Step 6: Display Summary

```markdown
╔══════════════════════════════════════════════════════════════════════╗
║                    Project Seed Complete                             ║
╚══════════════════════════════════════════════════════════════════════╝

## Project Seed Generated

Your project now has compound-equivalent knowledge BEFORE writing any code.

### Files Generated

✅ `openspec/specs/architecture-profile.yaml` — Architecture profile (stack, SOLID, patterns, thresholds)
✅ `openspec/specs/entities/*.yaml` — ${N} domain entities extracted from requirements
✅ `.ai/project/compound-memory.md` — ${N} known pain points + ${N} patterns (seeded from ${stack} best practices)
✅ `.ai/project/next-feature-briefing.md` — Feature roadmap with ${N} features ordered by dependency
✅ `.ai/project/config.yaml` — Project configuration
✅ `openspec/specs/constitution.md` — Non-negotiable principles from requirements

### Domain Model Detected

| Entity | Type | Relations |
|--------|------|-----------|
${entity_table}

### Recommended First Feature

▶ Start with: `/workflows:plan ${first_feature_slug}`

This feature establishes the foundation that ${N} other features depend on.

### How Seed Knowledge Is Used

```
/workflows:plan (Step 0.0d) ← reads compound-memory.md, architecture-profile.yaml
                                 Uses seeded pain points to write better specs
                                 Uses entity map to detect integration impacts

/workflows:work (Step 3.5)  ← reads learned patterns, next-feature-briefing.md
                                 Uses seeded patterns as implementation reference
                                 Uses known risks to increase BCP vigilance

/workflows:compound          ← validates/enriches seed knowledge after each feature
                                 [SEED] entries get promoted or demoted based on reality
```

### What Happens Next

1. Run `/workflows:plan ${first_feature_slug}` — planning will use seed knowledge
2. After completing the feature, `/workflows:compound` will validate seed entries
3. Each completed feature makes the seed knowledge MORE accurate
4. By feature 3, you'll have both seed AND real compound knowledge

> **The seed advantage**: Your first feature plans like your fifth.
```

### Seed Knowledge Lifecycle

Seed entries have a special lifecycle that differs from regular compound entries:

```
[SEED] entry created by --seed
         │
         ├── Feature N uses it during plan/work
         │    └── Was it accurate/useful?
         │
         ├── /workflows:compound validates it
         │    ├── YES (matched reality) → PROMOTE to regular entry (remove [SEED] tag)
         │    │                           Increment confidence
         │    └── NO (didn't match) → DEMOTE or UPDATE with real data
         │                            Add note: "Seed predicted X, reality was Y"
         │
         └── After 3 features without validation → STALE
              └── Mark for review: "[SEED-STALE] Not yet validated after 3 features"
```

In `compound.md` Step 3b (Update Agent Compound Memory), when processing entries:
- If entry has `[SEED]` tag AND was useful → remove tag, set confidence based on real data
- If entry has `[SEED]` tag AND was NOT useful → update with real learning, keep tag as `[SEED-UPDATED]`
- If entry has `[SEED]` tag AND 3+ features have passed without touching that area → mark `[SEED-STALE]`

---

## Related Commands

- `/workflows:status` - Estado actual
