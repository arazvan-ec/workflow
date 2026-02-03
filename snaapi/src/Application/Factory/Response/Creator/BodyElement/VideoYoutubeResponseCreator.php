<?php

declare(strict_types=1);

namespace App\Application\Factory\Response\Creator\BodyElement;

use App\Application\DTO\Response\BodyElementResponse;
use Ec\Editorial\Domain\Model\Body\BodyElement;
use Ec\Editorial\Domain\Model\Body\BodyTagVideoYoutube;

/**
 * Creates response DTO for BodyTagVideoYoutube body elements.
 */
final readonly class VideoYoutubeResponseCreator implements BodyElementResponseCreatorInterface
{
    public function supports(BodyElement $element): bool
    {
        return $element instanceof BodyTagVideoYoutube;
    }

    public function create(BodyElement $element, array $resolveData = []): BodyElementResponse
    {
        assert($element instanceof BodyTagVideoYoutube);

        return new BodyElementResponse(
            type: 'video_youtube',
            videoId: $element->videoId(),
        );
    }
}
