<?php

declare(strict_types=1);

namespace App\Application\Factory\Response\Creator\BodyElement;

use App\Application\DTO\Response\BodyElementResponse;
use Ec\Editorial\Domain\Model\Body\BodyElement;
use Ec\Editorial\Domain\Model\Body\BodyTagSummary;

/**
 * Creates response DTO for BodyTagSummary body elements.
 */
final readonly class SummaryResponseCreator implements BodyElementResponseCreatorInterface
{
    public function supports(BodyElement $element): bool
    {
        return $element instanceof BodyTagSummary;
    }

    public function create(BodyElement $element, array $resolveData = []): BodyElementResponse
    {
        assert($element instanceof BodyTagSummary);

        return new BodyElementResponse(
            type: 'summary',
            content: $element->content(),
        );
    }
}
