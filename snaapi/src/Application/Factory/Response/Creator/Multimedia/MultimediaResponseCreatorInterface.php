<?php

declare(strict_types=1);

namespace App\Application\Factory\Response\Creator\Multimedia;

use App\Application\DTO\Response\MultimediaResponse;
use Ec\Multimedia\Domain\Model\Multimedia\Multimedia;

/**
 * Interface for multimedia response creators.
 *
 * Each implementation handles a specific type of Multimedia,
 * following the Strategy pattern for Open/Closed compliance.
 */
interface MultimediaResponseCreatorInterface
{
    /**
     * Check if this creator supports the given multimedia.
     */
    public function supports(Multimedia $multimedia): bool;

    /**
     * Create a response DTO from the multimedia.
     */
    public function create(Multimedia $multimedia): MultimediaResponse;
}
