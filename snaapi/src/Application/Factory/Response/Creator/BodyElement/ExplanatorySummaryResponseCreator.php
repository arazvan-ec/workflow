<?php

declare(strict_types=1);

namespace App\Application\Factory\Response\Creator\BodyElement;

use App\Application\DTO\Response\BodyElementResponse;
use Ec\Editorial\Domain\Model\Body\BodyElement;
use Ec\Editorial\Domain\Model\Body\BodyTagExplanatorySummary;

/**
 * Creates response DTO for BodyTagExplanatorySummary body elements.
 */
final readonly class ExplanatorySummaryResponseCreator implements BodyElementResponseCreatorInterface
{
    public function supports(BodyElement $element): bool
    {
        return $element instanceof BodyTagExplanatorySummary;
    }

    public function create(BodyElement $element, array $resolveData = []): BodyElementResponse
    {
        assert($element instanceof BodyTagExplanatorySummary);

        return new BodyElementResponse(
            type: 'explanatory_summary',
            content: $element->content(),
            extra: [
                'title' => $element->title(),
            ],
        );
    }
}
