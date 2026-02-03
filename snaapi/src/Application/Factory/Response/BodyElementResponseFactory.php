<?php

declare(strict_types=1);

namespace App\Application\Factory\Response;

use App\Application\DTO\Response\BodyElementResponse;
use App\Application\Factory\Response\Creator\BodyElement\BodyElementResponseCreatorInterface;
use Ec\Editorial\Domain\Model\Body\BodyElement;

/**
 * Factory for creating BodyElementResponse DTOs from domain body elements.
 *
 * Uses the Strategy pattern with injected creators for Open/Closed compliance.
 * New element types can be added by creating new creator classes without
 * modifying this factory.
 */
final readonly class BodyElementResponseFactory
{
    /**
     * @param iterable<BodyElementResponseCreatorInterface> $creators
     */
    public function __construct(
        private iterable $creators,
    ) {
    }

    /**
     * @param array<string, mixed> $resolveData Additional data for element transformation
     */
    public function create(BodyElement $element, array $resolveData = []): BodyElementResponse
    {
        foreach ($this->creators as $creator) {
            if ($creator->supports($element)) {
                return $creator->create($element, $resolveData);
            }
        }

        // Fallback for truly unknown elements (should rarely happen with FallbackCreator)
        return new BodyElementResponse(
            type: 'unknown',
            extra: ['class' => $element::class],
        );
    }
}
