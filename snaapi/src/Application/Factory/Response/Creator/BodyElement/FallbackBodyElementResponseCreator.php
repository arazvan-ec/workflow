<?php

declare(strict_types=1);

namespace App\Application\Factory\Response\Creator\BodyElement;

use App\Application\DTO\Response\BodyElementResponse;
use Ec\Editorial\Domain\Model\Body\BodyElement;

/**
 * Fallback creator for unknown body element types.
 *
 * This creator supports ALL body elements and should be registered
 * with the lowest priority to act as a catch-all fallback.
 */
final readonly class FallbackBodyElementResponseCreator implements BodyElementResponseCreatorInterface
{
    public function supports(BodyElement $element): bool
    {
        return true;
    }

    public function create(BodyElement $element, array $resolveData = []): BodyElementResponse
    {
        return new BodyElementResponse(
            type: 'unknown',
            extra: [
                'class' => $element::class,
            ],
        );
    }
}
