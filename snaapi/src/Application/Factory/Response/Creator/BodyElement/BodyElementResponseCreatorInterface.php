<?php

declare(strict_types=1);

namespace App\Application\Factory\Response\Creator\BodyElement;

use App\Application\DTO\Response\BodyElementResponse;
use Ec\Editorial\Domain\Model\Body\BodyElement;

/**
 * Interface for body element response creators.
 *
 * Each implementation handles a specific type of BodyElement,
 * following the Strategy pattern for Open/Closed compliance.
 */
interface BodyElementResponseCreatorInterface
{
    /**
     * Check if this creator supports the given element.
     */
    public function supports(BodyElement $element): bool;

    /**
     * Create a response DTO from the element.
     *
     * @param array<string, mixed> $resolveData Additional data for element transformation
     */
    public function create(BodyElement $element, array $resolveData = []): BodyElementResponse;
}
