<?php

declare(strict_types=1);

namespace App\Application\Factory\Response\Creator\BodyElement;

use App\Application\DTO\Response\BodyElementResponse;
use Ec\Editorial\Domain\Model\Body\BodyElement;
use Ec\Editorial\Domain\Model\Body\BodyTagPicture;

/**
 * Creates response DTO for BodyTagPicture body elements.
 */
final readonly class PictureResponseCreator implements BodyElementResponseCreatorInterface
{
    public function supports(BodyElement $element): bool
    {
        return $element instanceof BodyTagPicture;
    }

    public function create(BodyElement $element, array $resolveData = []): BodyElementResponse
    {
        assert($element instanceof BodyTagPicture);

        $photoId = $element->id()->id();
        $photoData = $resolveData['photoFromBodyTags'][$photoId] ?? null;

        return new BodyElementResponse(
            type: 'picture',
            imageUrl: $photoData['url'] ?? null,
            caption: $element->caption(),
            credit: $photoData['credit'] ?? null,
            extra: [
                'id' => $photoId,
            ],
        );
    }
}
