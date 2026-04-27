import SwiftUI
import Kingfisher

struct RemoteImage: View {
    let url: String?
    let placeholder: Image
    let failureImage: Image
    let contentMode: SwiftUI.ContentMode
    let cornerRadius: CGFloat
    let resizing: CGSize?

    init(
        url: String?,
        placeholder: Image = Image(systemName: "photo"),
        failureImage: Image = Image(systemName: "exclamationmark.triangle"),
        contentMode: SwiftUI.ContentMode = .fill,
        cornerRadius: CGFloat = 0,
        resizing: CGSize? = nil
    ) {
        self.url = url
        self.placeholder = placeholder
        self.failureImage = failureImage
        self.contentMode = contentMode
        self.cornerRadius = cornerRadius
        self.resizing = resizing
    }

    var body: some View {
        Group {
            if let urlString = url, let url = URL(string: urlString) {
                KFImage(url)
                    .setProcessor(processor)
                    .placeholder { placeholder.resizable().aspectRatio(contentMode: contentMode) }
                    .onFailure { _ in failureImage.resizable().aspectRatio(contentMode: contentMode) }
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else {
                placeholder.resizable().aspectRatio(contentMode: contentMode)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }

    private var processor: ImageProcessor {
        if let size = resizing {
            return DownsamplingImageProcessor(size: size)
        }
        return DefaultImageProcessor.default
    }
}

struct AvatarImage: View {
    let urlString: String?
    let size: CGFloat

    init(urlString: String?, size: CGFloat = 44) {
        self.urlString = urlString
        self.size = size
    }

    var body: some View {
        RemoteImage(
            url: urlString,
            placeholder: Image(systemName: "person.crop.circle.fill"),
            failureImage: Image(systemName: "person.crop.circle.fill"),
            contentMode: .fill,
            cornerRadius: size / 2,
            resizing: CGSize(width: size * 2, height: size * 2)
        )
        .frame(width: size, height: size)
        .background(AppPalette.divider)
    }
}

extension View {
    func remoteImage(
        url: String?,
        width: CGFloat? = nil,
        height: CGFloat? = nil,
        cornerRadius: CGFloat = 0
    ) -> some View {
        RemoteImage(
            url: url,
            contentMode: .fill,
            cornerRadius: cornerRadius,
            resizing: width.map { CGSize(width: $0 * 2, height: (height ?? $0) * 2) }
        )
        .frame(width: width, height: height)
    }
}
