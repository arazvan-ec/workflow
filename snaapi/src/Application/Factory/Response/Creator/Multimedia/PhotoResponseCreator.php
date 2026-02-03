<?php

declare(strict_types=1);

namespace App\Application\Factory\Response\Creator\Multimedia;

use App\Application\DTO\Response\MultimediaResponse;
use Ec\Multimedia\Domain\Model\Multimedia\Multimedia;
use Ec\Multimedia\Domain\Model\Multimedia\MultimediaPhoto;

/**
 * Creates response DTO for photo multimedia.
 */
final readonly class PhotoResponseCreator implements MultimediaResponseCreatorInterface
{
    public function supports(Multimedia $multimedia): bool
    {
        return $multimedia instanceof MultimediaPhoto;
    }

    public function create(Multimedia $multimedia): MultimediaResponse
    {
        /** @var MultimediaPhoto $multimedia */
        return new MultimediaResponse(
            type: 'photo',
            id: $multimedia->id(),
            url: $multimedia->url(),
            caption: $multimedia->caption(),
            credit: $multimedia->credit(),
        );
    }
}
