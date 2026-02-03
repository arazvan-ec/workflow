<?php

declare(strict_types=1);

namespace App\Application\Factory\Response;

use App\Application\DTO\Response\MultimediaResponse;
use App\Application\Factory\Response\Creator\Multimedia\MultimediaResponseCreatorInterface;
use Ec\Multimedia\Domain\Model\Multimedia\Multimedia;

/**
 * Factory for creating MultimediaResponse DTOs from domain multimedia entities.
 *
 * Uses the Strategy pattern with injected creators for Open/Closed compliance.
 * New multimedia types can be added by creating new creator classes without
 * modifying this factory.
 */
final readonly class MultimediaResponseFactory
{
    /**
     * @param iterable<MultimediaResponseCreatorInterface> $creators
     */
    public function __construct(
        private iterable $creators,
    ) {
    }

    public function create(Multimedia $multimedia): MultimediaResponse
    {
        foreach ($this->creators as $creator) {
            if ($creator->supports($multimedia)) {
                return $creator->create($multimedia);
            }
        }

        // Fallback for truly unknown multimedia (should rarely happen with FallbackCreator)
        return new MultimediaResponse(
            type: 'unknown',
            id: $multimedia->id(),
        );
    }
}
