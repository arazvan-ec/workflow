<?php

declare(strict_types=1);

namespace App\Application\Factory\Response\Creator\BodyElement;

use App\Application\DTO\Response\BodyElementResponse;
use Ec\Editorial\Domain\Model\Body\BodyElement;
use Ec\Editorial\Domain\Model\Body\UnorderedList;

/**
 * Creates response DTO for UnorderedList body elements.
 */
final readonly class UnorderedListResponseCreator implements BodyElementResponseCreatorInterface
{
    public function supports(BodyElement $element): bool
    {
        return $element instanceof UnorderedList;
    }

    public function create(BodyElement $element, array $resolveData = []): BodyElementResponse
    {
        assert($element instanceof UnorderedList);

        return new BodyElementResponse(
            type: 'unordered_list',
            items: $element->items(),
        );
    }
}
