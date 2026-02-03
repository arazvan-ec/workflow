<?php

declare(strict_types=1);

namespace App\Application\Factory\Response\Creator\BodyElement;

use App\Application\DTO\Response\BodyElementResponse;
use Ec\Editorial\Domain\Model\Body\BodyElement;
use Ec\Editorial\Domain\Model\Body\SubHead;

/**
 * Creates response DTO for SubHead body elements.
 */
final readonly class SubHeadResponseCreator implements BodyElementResponseCreatorInterface
{
    public function supports(BodyElement $element): bool
    {
        return $element instanceof SubHead;
    }

    public function create(BodyElement $element, array $resolveData = []): BodyElementResponse
    {
        assert($element instanceof SubHead);

        return new BodyElementResponse(
            type: 'subhead',
            content: $element->content(),
            level: $element->level(),
        );
    }
}
