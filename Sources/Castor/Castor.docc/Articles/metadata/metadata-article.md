# Metadata

@Metadata {
    @PageColor(purple)
    @PageImage(purpose: card, source: metadata-card, alt: "An image depicting a database.")
}

Associate metadata with the content being cast.

## Overview

When casting content, metadata describes what is being played. Providing consistent metadata ensures a smooth and unified casting experience across devices. Metadata serves two main purposes:

- **Sender UI:** Presents content information such as title, artwork, and chapters in your app interface.
- **Receiver UI:** Displays the same information on the Cast device's playback interface.

## Creating metadata

Metadata is represented by the ``CastMetadata`` type. Metadata includes a title, a metadata type, and optional artwork images. You can then create metadata with no image, one image or multiple images.

@TabNavigator {
    @Tab("No image") {
        ```swift
        let metadata = CastMetadata(title: "Video", metadataType: .movie, image: nil)
        ```
    }

    @Tab("One image") {
        ```swift
        let image = CastImage(url: URL(string: "https://example.com/poster.jpg"))
        let metadata = CastMetadata(title: "Video", metadataType: .movie, image: image)
        ```
    }

    @Tab("Multiple images") {
        ```swift
        let image1 = CastImage(url: URL(string: "https://example.com/poster1.jpg"))
        let image2 = CastImage(url: URL(string: "https://example.com/poster2.jpg"))
        let metadata = CastMetadata(title: "Video", metadataType: .movie, images: [image1, image2])
        ```
    }
}

> Important: The [`GCKMediaMetadataType`](https://developers.google.com/cast/docs/reference/ios/g_c_k_media_metadata_8h#a24f7de80a98dfc6f8626c01167a97a6a) helps receivers adjust their layout based on the type of content. For example, when casting a radio channel, nothing is being displayed on the screen, so you should use **`GCKMediaMetadataTypeMusicTrack`** to ensure the receiver displays the artwork correctly. Otherwise, the receiver may fail to show the channel's artwork, leaving a black screen.

### Images

Images are represented using ``CastImage``.

- Use ``CastMetadata/imageUrl(matching:)`` to select an image that best matches display hints.
- By default, the first image is returned if no hints are provided.
- Implement a [`GCKUIImagePicker`](https://developers.google.com/cast/docs/reference/ios/protocol_g_c_k_u_i_image_picker-p?hl=en) to control image selection for specific layouts.

> Note: Always provide at least one image. Keep image sizes reasonable to avoid exceeding Cast message size limits (64 KB).

### Fetching metadata

In ``Castor``, a ``CastPlayerItem`` represents an item in a Cast queue. While its identifier is immediately available, the full metadata including, title, images and custom data must be explicitly fetched from the Cast receiver by calling ``CastPlayerItem/fetch()`` method.

- Call ``CastPlayerItem/fetch()`` only when the view displaying the item appears. Avoid fetching items that are not currently visible on the screen.
- After calling ``CastPlayerItem/fetch()``, the ``CastPlayerItem/asset`` property provides access to a ``CastMetadata`` containing the full metadata.
