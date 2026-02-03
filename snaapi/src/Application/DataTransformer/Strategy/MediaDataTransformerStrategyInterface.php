<?php

declare(strict_types=1);

/**
 * @copyright
 */

namespace App\Application\DataTransformer\Strategy;

use Ec\Editorial\Domain\Model\Opening;
use Ec\Multimedia\Domain\Model\Multimedia\Multimedia;

/**
 * Strategy interface for media data transformers.
 *
 * Each implementation handles a specific type of Multimedia,
 * following the Strategy pattern for Open/Closed compliance.
 *
 * New media transformers should implement this interface
 * to be automatically discovered and used by the handler.
 */
interface MediaDataTransformerStrategyInterface
{
    /**
     * Check if this transformer supports the given multimedia element.
     */
    public function supports(Multimedia $multimedia): bool;

    /**
     * Transform the multimedia element into an array representation.
     *
     * @param array<string, array<string, mixed>> $multimediaOpeningData
     *
     * @return array<string, mixed>
     */
    public function transform(array $multimediaOpeningData, Opening $openingData): array;
}
