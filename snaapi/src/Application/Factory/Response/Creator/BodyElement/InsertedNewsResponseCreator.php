<?php

declare(strict_types=1);

namespace App\Application\Factory\Response\Creator\BodyElement;

use App\Application\DTO\Response\BodyElementResponse;
use Ec\Editorial\Domain\Model\Body\BodyElement;
use Ec\Editorial\Domain\Model\Body\BodyTagInsertedNews;

/**
 * Creates response DTO for BodyTagInsertedNews body elements.
 */
final readonly class InsertedNewsResponseCreator implements BodyElementResponseCreatorInterface
{
    public function supports(BodyElement $element): bool
    {
        return $element instanceof BodyTagInsertedNews;
    }

    public function create(BodyElement $element, array $resolveData = []): BodyElementResponse
    {
        assert($element instanceof BodyTagInsertedNews);

        $editorialId = $element->editorialId()->id();
        $newsData = $resolveData['insertedNews'][$editorialId] ?? null;

        return new BodyElementResponse(
            type: 'inserted_news',
            extra: [
                'editorialId' => $editorialId,
                'editorial' => $newsData,
            ],
        );
    }
}
