<?php

declare(strict_types=1);

/**
 * @copyright
 */

namespace App\Application\DataTransformer\Strategy;

use Ec\Editorial\Domain\Model\Body\BodyElement;

/**
 * Strategy interface for body element data transformers.
 *
 * Each implementation handles a specific type of BodyElement,
 * following the Strategy pattern for Open/Closed compliance.
 *
 * New body element transformers should implement this interface
 * to be automatically discovered and used by the handler.
 */
interface BodyElementDataTransformerStrategyInterface
{
    /**
     * Check if this transformer supports the given body element.
     */
    public function supports(BodyElement $element): bool;

    /**
     * Transform the body element into an array representation.
     *
     * @param array<string, mixed> $resolveData Additional data for element transformation
     *
     * @return array<string, mixed>
     */
    public function transform(BodyElement $element, array $resolveData = []): array;
}
