<?php

declare(strict_types=1);

namespace App\Application\Factory\Response\Creator\BodyElement;

use App\Application\DTO\Response\BodyElementResponse;
use Ec\Editorial\Domain\Model\Body\BodyElement;
use Ec\Editorial\Domain\Model\Body\NumberedList;

/**
 * Creates response DTO for NumberedList body elements.
 */
final readonly class NumberedListResponseCreator implements BodyElementResponseCreatorInterface
{
    public function supports(BodyElement $element): bool
    {
        return $element instanceof NumberedList;
    }

    public function create(BodyElement $element, array $resolveData = []): BodyElementResponse
    {
        assert($element instanceof NumberedList);

        return new BodyElementResponse(
            type: 'numbered_list',
            items: $element->items(),
        );
    }
}
