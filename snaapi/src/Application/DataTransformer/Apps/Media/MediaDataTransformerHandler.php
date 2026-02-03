<?php

declare(strict_types=1);

/**
 * @copyright
 */

namespace App\Application\DataTransformer\Apps\Media;

use App\Application\DataTransformer\Strategy\MediaDataTransformerStrategyInterface;
use Ec\Editorial\Domain\Model\Opening;
use Ec\Editorial\Exceptions\MultimediaDataTransformerNotFoundException;
use Ec\Multimedia\Domain\Model\Multimedia\Multimedia;

/**
 * Handler for media data transformers.
 *
 * Uses the Strategy pattern to iterate over injected transformers,
 * following Open/Closed principle - new multimedia types can be added
 * by creating new transformer classes without modifying this handler.
 *
 * Supports both:
 * - New transformers implementing MediaDataTransformerStrategyInterface (recommended)
 * - Legacy transformers implementing MediaDataTransformer (backwards compatible)
 *
 * @author Laura Gomez Cabero <lgomez@ext.elconfidencial.com>
 */
final readonly class MediaDataTransformerHandler
{
    /**
     * @param iterable<MediaDataTransformer|MediaDataTransformerStrategyInterface> $dataTransformers
     */
    public function __construct(
        private iterable $dataTransformers,
    ) {
    }

    /**
     * @param array<string, array<string, mixed>> $multimediaOpeningData
     *
     * @return array<string, mixed>
     *
     * @throws MultimediaDataTransformerNotFoundException
     */
    public function execute(array $multimediaOpeningData, Opening $openingData): array
    {
        /** @var Multimedia $multimediaElement */
        $multimediaElement = $multimediaOpeningData[$openingData->multimediaId()]['opening'];

        foreach ($this->dataTransformers as $transformer) {
            if ($this->supports($transformer, $multimediaElement)) {
                return $this->transform($transformer, $multimediaOpeningData, $openingData);
            }
        }

        throw new MultimediaDataTransformerNotFoundException(
            \sprintf('Media data transformer type %s not found', $multimediaElement->type())
        );
    }

    /**
     * Check if the transformer supports the given multimedia element.
     */
    private function supports(
        MediaDataTransformer|MediaDataTransformerStrategyInterface $transformer,
        Multimedia $multimediaElement
    ): bool {
        // New Strategy interface with explicit supports() method
        if ($transformer instanceof MediaDataTransformerStrategyInterface) {
            return $transformer->supports($multimediaElement);
        }

        // Legacy interface: use canTransform() to check class support
        $supportedClass = $transformer->canTransform();

        return $multimediaElement instanceof $supportedClass;
    }

    /**
     * Execute the transformation using the appropriate method.
     *
     * @param array<string, array<string, mixed>> $multimediaOpeningData
     *
     * @return array<string, mixed>
     */
    private function transform(
        MediaDataTransformer|MediaDataTransformerStrategyInterface $transformer,
        array $multimediaOpeningData,
        Opening $openingData
    ): array {
        // New Strategy interface with transform() method
        if ($transformer instanceof MediaDataTransformerStrategyInterface) {
            return $transformer->transform($multimediaOpeningData, $openingData);
        }

        // Legacy interface: use write/read pattern
        return $transformer->write($multimediaOpeningData, $openingData)->read();
    }
}
