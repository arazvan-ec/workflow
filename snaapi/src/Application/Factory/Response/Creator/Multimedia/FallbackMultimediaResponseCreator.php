<?php

declare(strict_types=1);

namespace App\Application\Factory\Response\Creator\Multimedia;

use App\Application\DTO\Response\MultimediaResponse;
use Ec\Multimedia\Domain\Model\Multimedia\Multimedia;

/**
 * Fallback creator for unknown multimedia types.
 *
 * This creator supports all multimedia types and should be
 * registered with the lowest priority in the creator chain.
 */
final readonly class FallbackMultimediaResponseCreator implements MultimediaResponseCreatorInterface
{
    public function supports(Multimedia $multimedia): bool
    {
        return true;
    }

    public function create(Multimedia $multimedia): MultimediaResponse
    {
        return new MultimediaResponse(
            type: 'unknown',
            id: $multimedia->id(),
        );
    }
}
