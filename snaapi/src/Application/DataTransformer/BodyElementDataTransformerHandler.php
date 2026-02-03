<?php

declare(strict_types=1);

/**
 * @copyright
 */

namespace App\Application\DataTransformer;

use App\Application\DataTransformer\Strategy\BodyElementDataTransformerStrategyInterface;
use Ec\Editorial\Domain\Model\Body\BodyElement;
use Ec\Editorial\Exceptions\BodyDataTransformerNotFoundException;

/**
 * Handler for body element data transformers.
 *
 * Uses the Strategy pattern to iterate over injected transformers,
 * following Open/Closed principle - new element types can be added
 * by creating new transformer classes without modifying this handler.
 *
 * Supports both:
 * - New transformers implementing BodyElementDataTransformerStrategyInterface (recommended)
 * - Legacy transformers implementing BodyElementDataTransformer (backwards compatible)
 *
 * @author Razvan Alin Munteanu <arazvan@elconfidencial.com>
 */
final readonly class BodyElementDataTransformerHandler
{
    /**
     * @param iterable<BodyElementDataTransformer|BodyElementDataTransformerStrategyInterface> $dataTransformers
     */
    public function __construct(
        private iterable $dataTransformers,
    ) {
    }

    /**
     * @param array<string, mixed> $resolveData
     *
     * @return array<string, mixed>
     *
     * @throws BodyDataTransformerNotFoundException
     */
    public function execute(BodyElement $bodyElement, array $resolveData = []): array
    {
        foreach ($this->dataTransformers as $transformer) {
            if ($this->supports($transformer, $bodyElement)) {
                return $this->transform($transformer, $bodyElement, $resolveData);
            }
        }

        throw new BodyDataTransformerNotFoundException(
            \sprintf('BodyElement data transformer type %s not found', $bodyElement->type())
        );
    }

    /**
     * Check if the transformer supports the given body element.
     */
    private function supports(
        BodyElementDataTransformer|BodyElementDataTransformerStrategyInterface $transformer,
        BodyElement $bodyElement
    ): bool {
        // New Strategy interface with explicit supports() method
        if ($transformer instanceof BodyElementDataTransformerStrategyInterface) {
            return $transformer->supports($bodyElement);
        }

        // Legacy interface: use canTransform() to check class support
        $supportedClass = $transformer->canTransform();

        return $bodyElement instanceof $supportedClass;
    }

    /**
     * Execute the transformation using the appropriate method.
     *
     * @param array<string, mixed> $resolveData
     *
     * @return array<string, mixed>
     */
    private function transform(
        BodyElementDataTransformer|BodyElementDataTransformerStrategyInterface $transformer,
        BodyElement $bodyElement,
        array $resolveData
    ): array {
        // New Strategy interface with transform() method
        if ($transformer instanceof BodyElementDataTransformerStrategyInterface) {
            return $transformer->transform($bodyElement, $resolveData);
        }

        // Legacy interface: use write/read pattern
        $transformer->write($bodyElement, $resolveData);

        return $transformer->read();
    }
}
