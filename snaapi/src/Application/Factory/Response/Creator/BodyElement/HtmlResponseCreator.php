<?php

declare(strict_types=1);

namespace App\Application\Factory\Response\Creator\BodyElement;

use App\Application\DTO\Response\BodyElementResponse;
use Ec\Editorial\Domain\Model\Body\BodyElement;
use Ec\Editorial\Domain\Model\Body\BodyTagHtml;

/**
 * Creates response DTO for BodyTagHtml body elements.
 */
final readonly class HtmlResponseCreator implements BodyElementResponseCreatorInterface
{
    public function supports(BodyElement $element): bool
    {
        return $element instanceof BodyTagHtml;
    }

    public function create(BodyElement $element, array $resolveData = []): BodyElementResponse
    {
        assert($element instanceof BodyTagHtml);

        return new BodyElementResponse(
            type: 'html',
            html: $element->content(),
        );
    }
}
