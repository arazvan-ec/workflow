# Architecture Criteria: SOLID Refactor

## SOLID Principles Applied

### S - Single Responsibility Principle

**Criterio**: Cada clase tiene una única razón para cambiar.

| Clase | Responsabilidad Única | Métrica |
|-------|----------------------|---------|
| `BodyElementResponseFactory` | Orquestar creators | < 30 líneas |
| `ParagraphResponseCreator` | Crear response de Paragraph | < 20 líneas |
| `MultimediaResponseFactory` | Orquestar multimedia creators | < 30 líneas |
| `ImageSizeConfiguration` | Configuración de tamaños | Config only |
| `MultimediaUrlGenerator` | Generar URLs de multimedia | < 50 líneas |

**Test**: Si la descripción de una clase contiene "y" o "o", viola SRP.

---

### O - Open/Closed Principle

**Criterio**: Abierto para extensión, cerrado para modificación.

**Patrón**: Strategy + Registry via Symfony Tagged Services

```php
// Interface (cerrada para modificación)
interface BodyElementResponseCreatorInterface
{
    public function supports(BodyElement $element): bool;
    public function create(BodyElement $element, array $resolveData = []): BodyElementResponse;
}

// Factory (cerrada para modificación)
final readonly class BodyElementResponseFactory
{
    /** @param iterable<BodyElementResponseCreatorInterface> $creators */
    public function __construct(private iterable $creators) {}

    public function create(BodyElement $element, array $resolveData = []): BodyElementResponse
    {
        foreach ($this->creators as $creator) {
            if ($creator->supports($element)) {
                return $creator->create($element, $resolveData);
            }
        }
        return $this->createFallback($element);
    }
}

// Extension (abierto para extensión - nueva clase)
final readonly class QuoteResponseCreator implements BodyElementResponseCreatorInterface
{
    public function supports(BodyElement $element): bool
    {
        return $element instanceof Quote;
    }

    public function create(BodyElement $element, array $resolveData = []): BodyElementResponse
    {
        return new BodyElementResponse(type: 'quote', content: $element->content());
    }
}
```

**Test**: Agregar nuevo tipo requiere 0 modificaciones a clases existentes.

---

### L - Liskov Substitution Principle

**Criterio**: Subtipos deben ser sustituibles por sus tipos base.

**Aplicación**:
- Todos los creators implementan la misma interface
- Factory trabaja con interface, no con implementaciones
- Cualquier creator puede ser reemplazado sin afectar el factory

**Test**: Reemplazar un creator por mock no rompe el factory.

---

### I - Interface Segregation Principle

**Criterio**: Interfaces pequeñas y específicas.

**Interfaces Definidas**:

```php
// Mínima - solo 2 métodos
interface BodyElementResponseCreatorInterface
{
    public function supports(BodyElement $element): bool;
    public function create(BodyElement $element, array $resolveData = []): BodyElementResponse;
}

// Separada para multimedia
interface MultimediaResponseCreatorInterface
{
    public function supports(Multimedia $multimedia): bool;
    public function create(Multimedia $multimedia): MultimediaResponse;
}

// Separada para URL generation
interface MultimediaUrlGeneratorInterface
{
    public function generate(string $photoId, string $size): string;
}
```

**Test**: Ninguna clase implementa métodos que no usa.

---

### D - Dependency Inversion Principle

**Criterio**: Depender de abstracciones, no de concretos.

**Antes** (viola DIP):
```php
class BodyElementResponseFactory
{
    // Conoce TODOS los tipos concretos
    $element instanceof Paragraph => ...
    $element instanceof SubHead => ...
}
```

**Después** (cumple DIP):
```php
class BodyElementResponseFactory
{
    // Solo conoce la interface
    public function __construct(
        private iterable $creators // BodyElementResponseCreatorInterface[]
    ) {}
}
```

**Test**: Factory no importa ningún tipo concreto de BodyElement.

---

## Symfony Integration Criteria

### Tagged Services

```yaml
# config/services.yaml
services:
    _instanceof:
        App\Application\Factory\Response\Creator\BodyElementResponseCreatorInterface:
            tags: ['app.body_element_creator']

        App\Application\Factory\Response\Creator\MultimediaResponseCreatorInterface:
            tags: ['app.multimedia_creator']

    App\Application\Factory\Response\BodyElementResponseFactory:
        arguments:
            $creators: !tagged_iterator app.body_element_creator
```

### Auto-Discovery

```yaml
services:
    App\Application\Factory\Response\Creator\:
        resource: '../src/Application/Factory/Response/Creator/'
        autoconfigure: true
```

---

## Code Quality Criteria

### PHPStan Level 8

```neon
# phpstan.neon
parameters:
    level: 8
    paths:
        - src/Application/Factory/Response/
```

### Metrics

| Métrica | Target |
|---------|--------|
| Cyclomatic Complexity | < 5 por método |
| Lines per class | < 100 |
| Methods per class | < 10 |
| Dependencies per class | < 5 |

### Naming Conventions

| Tipo | Patrón | Ejemplo |
|------|--------|---------|
| Interface | `{Name}Interface` | `BodyElementResponseCreatorInterface` |
| Creator | `{Type}ResponseCreator` | `ParagraphResponseCreator` |
| Factory | `{Name}ResponseFactory` | `BodyElementResponseFactory` |

---

## Testing Criteria

### Unit Tests

Cada creator debe tener:
1. `test_supports_returns_true_for_correct_type()`
2. `test_supports_returns_false_for_other_types()`
3. `test_create_returns_expected_response()`

### Integration Tests

Factory debe tener:
1. `test_factory_uses_correct_creator_for_each_type()`
2. `test_factory_returns_fallback_for_unknown_type()`

### Coverage

```xml
<!-- phpunit.xml -->
<coverage>
    <include>
        <directory suffix=".php">src/Application/Factory/Response/</directory>
    </include>
</coverage>
```

Target: >= 80%

---

## File Structure Criteria

```
src/Application/Factory/Response/
├── BodyElementResponseFactory.php          # Orchestrator (< 30 lines)
├── MultimediaResponseFactory.php           # Orchestrator (< 30 lines)
├── Creator/
│   ├── BodyElement/
│   │   ├── BodyElementResponseCreatorInterface.php
│   │   ├── ParagraphResponseCreator.php
│   │   ├── SubHeadResponseCreator.php
│   │   ├── PictureResponseCreator.php
│   │   └── ... (12 más)
│   └── Multimedia/
│       ├── MultimediaResponseCreatorInterface.php
│       ├── PhotoResponseCreator.php
│       ├── EmbedVideoResponseCreator.php
│       └── WidgetResponseCreator.php
├── EditorialResponseFactory.php            # Refactored
├── SignatureResponseFactory.php            # Sin cambios
├── SectionResponseFactory.php              # Sin cambios
├── TagResponseFactory.php                  # Sin cambios
└── TitlesResponseFactory.php               # Sin cambios
```
