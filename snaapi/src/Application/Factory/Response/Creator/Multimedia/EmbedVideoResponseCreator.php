<?php

declare(strict_types=1);

namespace App\Application\Factory\Response\Creator\Multimedia;

use App\Application\DTO\Response\MultimediaResponse;
use Ec\Multimedia\Domain\Model\Multimedia\Multimedia;
use Ec\Multimedia\Domain\Model\Multimedia\MultimediaEmbedVideo;

/**
 * Creates response DTO for embed video multimedia.
 */
final readonly class EmbedVideoResponseCreator implements MultimediaResponseCreatorInterface
{
    public function supports(Multimedia $multimedia): bool
    {
        return $multimedia instanceof MultimediaEmbedVideo;
    }

    public function create(Multimedia $multimedia): MultimediaResponse
    {
        /** @var MultimediaEmbedVideo $multimedia */
        return new MultimediaResponse(
            type: 'embed_video',
            id: $multimedia->id(),
            url: $multimedia->url(),
            caption: $multimedia->caption(),
        );
    }
}
