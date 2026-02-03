<?php

declare(strict_types=1);

namespace App\Application\Factory\Response\Creator\BodyElement;

use App\Application\DTO\Response\BodyElementResponse;
use Ec\Editorial\Domain\Model\Body\BodyElement;
use Ec\Editorial\Domain\Model\Body\GenericList;

/**
 * Creates response DTO for GenericList body elements.
 */
final readonly class GenericListResponseCreator implements BodyElementResponseCreatorInterface
{
    public function supports(BodyElement $element): bool
    {
        return $element instanceof GenericList;
    }

    public function create(BodyElement $element, array $resolveData = []): BodyElementResponse
    {
        assert($element instanceof GenericList);

        return new BodyElementResponse(
            type: 'generic_list',
            items: $element->items(),
        );
    }
}
