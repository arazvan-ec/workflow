<?php

declare(strict_types=1);

namespace App\Application\Factory\Response\Creator\BodyElement;

use App\Application\DTO\Response\BodyElementResponse;
use Ec\Editorial\Domain\Model\Body\BodyElement;
use Ec\Editorial\Domain\Model\Body\BodyTagPictureMembership;

/**
 * Creates response DTO for BodyTagPictureMembership body elements.
 */
final readonly class PictureMembershipResponseCreator implements BodyElementResponseCreatorInterface
{
    public function supports(BodyElement $element): bool
    {
        return $element instanceof BodyTagPictureMembership;
    }

    public function create(BodyElement $element, array $resolveData = []): BodyElementResponse
    {
        assert($element instanceof BodyTagPictureMembership);

        $photoId = $element->id()->id();
        $photoData = $resolveData['photoFromBodyTags'][$photoId] ?? null;

        return new BodyElementResponse(
            type: 'picture_membership',
            imageUrl: $photoData['url'] ?? null,
            caption: $element->caption(),
            credit: $photoData['credit'] ?? null,
        );
    }
}
