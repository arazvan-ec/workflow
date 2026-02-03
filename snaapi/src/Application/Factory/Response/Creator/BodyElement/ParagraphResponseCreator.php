<?php

declare(strict_types=1);

namespace App\Application\Factory\Response\Creator\BodyElement;

use App\Application\DTO\Response\BodyElementResponse;
use Ec\Editorial\Domain\Model\Body\BodyElement;
use Ec\Editorial\Domain\Model\Body\Paragraph;

/**
 * Creates response DTO for Paragraph body elements.
 */
final readonly class ParagraphResponseCreator implements BodyElementResponseCreatorInterface
{
    public function supports(BodyElement $element): bool
    {
        return $element instanceof Paragraph;
    }

    public function create(BodyElement $element, array $resolveData = []): BodyElementResponse
    {
        assert($element instanceof Paragraph);

        return new BodyElementResponse(
            type: 'paragraph',
            content: $element->content(),
        );
    }
}
