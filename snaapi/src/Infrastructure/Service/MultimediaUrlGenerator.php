<?php

declare(strict_types=1);

namespace App\Infrastructure\Service;

use App\Infrastructure\Configuration\ImageSizeConfiguration;
use Ec\Editorial\Domain\Model\Multimedia\Multimedia;
use Ec\Editorial\Domain\Model\Multimedia\MultimediaId;
use Ec\Editorial\Domain\Model\Multimedia\PhotoExist;
use Ec\Editorial\Domain\Model\Multimedia\Video;
use Ec\Editorial\Domain\Model\Multimedia\Widget;
use Ec\Multimedia\Domain\Model\Clipping;
use Ec\Multimedia\Domain\Model\ClippingTypes;
use Ec\Multimedia\Domain\Model\Multimedia as MultimediaModel;
use Ec\Multimedia\Domain\Model\Multimedia\MultimediaPhoto;
use Ec\Multimedia\Domain\Model\Photo\Photo;

/**
 * Service for generating multimedia thumbnail URLs.
 *
 * Provides methods to generate cropped image URLs using Thumbor
 * for various multimedia content types.
 */
final readonly class MultimediaUrlGenerator
{
    public function __construct(
        private Thumbor $thumbor,
        private ImageSizeConfiguration $imageSizeConfiguration,
    ) {
    }

    public function getThumbor(): Thumbor
    {
        return $this->thumbor;
    }

    public function getImageSizeConfiguration(): ImageSizeConfiguration
    {
        return $this->imageSizeConfiguration;
    }

    /**
     * Extract MultimediaId from various multimedia types.
     */
    public function extractMultimediaId(Multimedia $multimedia): ?MultimediaId
    {
        if ($multimedia instanceof PhotoExist) {
            return $multimedia->id();
        }

        if (
            ($multimedia instanceof Video || $multimedia instanceof Widget)
            && ($multimedia->photo() instanceof PhotoExist)
        ) {
            return $multimedia->photo()->id();
        }

        return null;
    }

    /**
     * Generate landscape shots for a multimedia model.
     *
     * @return array<string, string> Map of viewport size to URL
     */
    public function generateLandscapeShots(MultimediaModel $multimedia): array
    {
        $clippings = $multimedia->clippings();
        $clipping = $clippings->clippingByType(ClippingTypes::SIZE_ARTICLE_4_3);

        return $this->generateShotsFromClipping(
            $multimedia->file(),
            $clipping
        );
    }

    /**
     * Generate landscape shots from media opening data.
     *
     * @param array{opening: MultimediaPhoto, resource: Photo} $multimediaOpening
     *
     * @return array<string, string> Map of viewport size to URL
     */
    public function generateLandscapeShotsFromMedia(array $multimediaOpening): array
    {
        $clippings = $multimediaOpening['opening']->clippings();
        $clipping = $clippings->clippingByType(ClippingTypes::SIZE_ARTICLE_4_3);

        return $this->generateShotsFromClipping(
            $multimediaOpening['resource']->file(),
            $clipping
        );
    }

    /**
     * Generate shots for a specific file and clipping.
     *
     * @return array<string, string> Map of viewport size to URL
     */
    private function generateShotsFromClipping(string $file, Clipping $clipping): array
    {
        $shots = [];
        $sizes = $this->imageSizeConfiguration->getLandscapeSizes();

        foreach ($sizes as $viewport => $dimensions) {
            $shots[$viewport] = $this->thumbor->retriveCropBodyTagPicture(
                $file,
                $dimensions['width'],
                $dimensions['height'],
                $clipping->topLeftX(),
                $clipping->topLeftY(),
                $clipping->bottomRightX(),
                $clipping->bottomRightY()
            );
        }

        return $shots;
    }
}
