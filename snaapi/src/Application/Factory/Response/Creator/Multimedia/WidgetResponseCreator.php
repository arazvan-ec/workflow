<?php

declare(strict_types=1);

namespace App\Application\Factory\Response\Creator\Multimedia;

use App\Application\DTO\Response\MultimediaResponse;
use Ec\Multimedia\Domain\Model\Multimedia\Multimedia;
use Ec\Multimedia\Domain\Model\Multimedia\MultimediaWidget;

/**
 * Creates response DTO for widget multimedia.
 */
final readonly class WidgetResponseCreator implements MultimediaResponseCreatorInterface
{
    public function supports(Multimedia $multimedia): bool
    {
        return $multimedia instanceof MultimediaWidget;
    }

    public function create(Multimedia $multimedia): MultimediaResponse
    {
        /** @var MultimediaWidget $multimedia */
        return new MultimediaResponse(
            type: 'widget',
            id: $multimedia->id(),
            metadata: [
                'widgetType' => $multimedia->type(),
            ],
        );
    }
}
