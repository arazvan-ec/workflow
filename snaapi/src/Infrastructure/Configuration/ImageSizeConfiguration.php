<?php

declare(strict_types=1);

namespace App\Infrastructure\Configuration;

/**
 * Configuration class for multimedia image sizes.
 *
 * Provides centralized management of image dimension presets used
 * for generating cropped thumbnail URLs.
 */
final readonly class ImageSizeConfiguration
{
    private const string WIDTH = 'width';
    private const string HEIGHT = 'height';

    /**
     * Default landscape sizes used for body tag images and recommendations.
     *
     * @var array<string, array{width: string, height: string}>
     */
    private const array LANDSCAPE_SIZES = [
        '202w' => [self::WIDTH => '202', self::HEIGHT => '152'],
        '144w' => [self::WIDTH => '144', self::HEIGHT => '108'],
        '128w' => [self::WIDTH => '128', self::HEIGHT => '96'],
    ];

    /**
     * @return array<string, array{width: string, height: string}>
     */
    public function getLandscapeSizes(): array
    {
        return self::LANDSCAPE_SIZES;
    }

    /**
     * @return array<string>
     */
    public function getAvailableViewports(): array
    {
        return array_keys(self::LANDSCAPE_SIZES);
    }

    /**
     * @return array{width: string, height: string}|null
     */
    public function getSizeByViewport(string $viewport): ?array
    {
        return self::LANDSCAPE_SIZES[$viewport] ?? null;
    }
}
