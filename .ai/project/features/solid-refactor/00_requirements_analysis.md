# Requirements Analysis: SOLID Refactor

## Current State Analysis

### BodyElementResponseFactory (CRÍTICO)

**Location**: `snaapi/src/Application/Factory/Response/BodyElementResponseFactory.php`

**Current Implementation**:
```php
public function create(BodyElement $element, array $resolveData = []): BodyElementResponse
{
    return match (true) {
        $element instanceof Paragraph => $this->createParagraph($element),
        $element instanceof SubHead => $this->createSubHead($element),
        // ... 15+ más tipos
        default => $this->createGeneric($element),
    };
}
```

**Problems**:
1. 15+ instanceof checks en un match
2. 24 imports de tipos de dominio
3. Cada nuevo tipo requiere modificar esta clase
4. No es `readonly` (inconsistencia menor)

**Types to Extract** (15 creators):
- ParagraphResponseCreator
- SubHeadResponseCreator
- PictureResponseCreator
- PictureMembershipResponseCreator
- VideoYoutubeResponseCreator
- VideoResponseCreator
- HtmlResponseCreator
- SummaryResponseCreator
- ExplanatorySummaryResponseCreator
- InsertedNewsResponseCreator
- MembershipCardResponseCreator
- LinkResponseCreator
- UnorderedListResponseCreator
- NumberedListResponseCreator
- GenericListResponseCreator

---

### MultimediaResponseFactory (CRÍTICO)

**Location**: `snaapi/src/Application/Factory/Response/MultimediaResponseFactory.php`

**Current Implementation**:
```php
return match (true) {
    $multimedia instanceof MultimediaPhoto => $this->createPhotoResponse($multimedia),
    $multimedia instanceof MultimediaEmbedVideo => $this->createVideoResponse($multimedia),
    $multimedia instanceof MultimediaWidget => $this->createWidgetResponse($multimedia),
    default => $this->createGenericResponse($multimedia),
};
```

**Problems**:
1. Mismo patrón que BodyElementResponseFactory
2. Menos tipos pero mismo problema de escalabilidad

**Types to Extract** (4 creators):
- PhotoResponseCreator
- EmbedVideoResponseCreator
- WidgetResponseCreator
- GenericMultimediaResponseCreator

---

### EditorialResponseFactory (CRÍTICO)

**Location**: `snaapi/src/Application/Factory/Response/EditorialResponseFactory.php`

**Problems**:
1. 46 imports
2. 11 métodos privados de transformación
3. Conoce demasiados detalles de NewsBase
4. `method_exists()` anti-pattern (líneas 86, 104, 113, etc.)

**Extractable Responsibilities**:
- DateFormatter (formatDate, getEndOn, getUrlDate)
- EditorialTypeResolver (getTypeName)
- EditorialPropertiesExtractor (getClosingModeId, getIsBrand, getIsAmazonOnsite, etc.)
- StandfirstFactory (createStandfirst)

---

### EditorialOrchestrator (CRÍTICO)

**Location**: `snaapi/src/Orchestrator/Chain/EditorialOrchestrator.php`

**Problems**:
1. 46 imports, 17 dependencias inyectadas
2. God class que conoce todo el sistema
3. Mezcla orquestación con lógica de negocio

**Analysis Needed**:
- Identificar responsabilidades separables
- Evaluar si EnrichmentPipeline puede absorber más lógica
- Considerar patrón Saga o Chain of Responsibility

---

### DataTransformerHandlers (ALTO)

**Locations**:
- `snaapi/src/Application/DataTransformer/BodyElementDataTransformerHandler.php`
- `snaapi/src/Application/DataTransformer/Apps/Media/MediaDataTransformerHandler.php`

**Problems**:
1. Usan `get_class()` para buscar transformadores
2. Error solo en runtime si falta transformador
3. Registro manual en CompilerPass

**Solution**:
- Usar interface con `supports()` method
- Auto-discovery via tagged services
- Validación en compilación del contenedor

---

### MultimediaTrait (ALTO)

**Location**: `snaapi/src/Infrastructure/Trait/MultimediaTrait.php`

**Problems**:
1. 128 líneas
2. Usado por 7 clases
3. Tamaños de imagen hardcodeados
4. Mezcla múltiples responsabilidades

**Consumers**:
- BodyTagInsertedNewsDataTransformer
- DetailsAppsDataTransformer
- DetailsMultimediaDataTransformer
- JournalistsDataTransformer
- RecommendedEditorialsDataTransformer
- DetailsMultimediaPhotoDataTransformer
- EditorialOrchestrator

**Solution**:
- Extraer a ImageSizeConfiguration (config/parameters)
- Crear MultimediaUrlGenerator service
- Inyectar service en lugar de usar trait

---

## Functional Requirements

1. **Backward Compatibility**: API response debe ser idéntica
2. **No Breaking Changes**: Tests existentes deben pasar sin modificación
3. **Symfony Integration**: Usar tagged services para auto-discovery

## Non-Functional Requirements

1. **Maintainability**: Cada clase < 100 líneas
2. **Testability**: Cobertura >= 80%
3. **Performance**: Sin degradación (micro-optimizations no necesarias)
4. **Documentation**: PHPDoc en interfaces públicas

## Constraints

1. PHP 8.2+
2. Symfony 6.x
3. No cambiar DTOs de respuesta existentes
4. No cambiar estructura de carpetas radicalmente
