<?php

declare(strict_types=1);

namespace App\Application\Factory\Response\Creator\BodyElement;

use App\Application\DTO\Response\BodyElementResponse;
use Ec\Editorial\Domain\Model\Body\BodyElement;
use Ec\Editorial\Domain\Model\Body\Link;

/**
 * Creates response DTO for Link body elements.
 */
final readonly class LinkResponseCreator implements BodyElementResponseCreatorInterface
{
    public function supports(BodyElement $element): bool
    {
        return $element instanceof Link;
    }

    public function create(BodyElement $element, array $resolveData = []): BodyElementResponse
    {
        assert($element instanceof Link);

        return new BodyElementResponse(
            type: 'link',
            content: $element->text(),
            extra: [
                'url' => $element->url(),
            ],
        );
    }
}
