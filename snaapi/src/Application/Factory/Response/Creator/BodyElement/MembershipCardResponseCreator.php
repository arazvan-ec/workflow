<?php

declare(strict_types=1);

namespace App\Application\Factory\Response\Creator\BodyElement;

use App\Application\DTO\Response\BodyElementResponse;
use Ec\Editorial\Domain\Model\Body\BodyElement;
use Ec\Editorial\Domain\Model\Body\BodyTagMembershipCard;

/**
 * Creates response DTO for BodyTagMembershipCard body elements.
 */
final readonly class MembershipCardResponseCreator implements BodyElementResponseCreatorInterface
{
    public function supports(BodyElement $element): bool
    {
        return $element instanceof BodyTagMembershipCard;
    }

    public function create(BodyElement $element, array $resolveData = []): BodyElementResponse
    {
        assert($element instanceof BodyTagMembershipCard);

        $membershipLinks = $resolveData['membershipLinkCombine'] ?? [];

        return new BodyElementResponse(
            type: 'membership_card',
            extra: [
                'title' => $element->title(),
                'membershipLinks' => $membershipLinks,
            ],
        );
    }
}
