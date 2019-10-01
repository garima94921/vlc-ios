/*****************************************************************************
 * VideoGroupViewModel.swift
 *
 * Copyright © 2019 VLC authors and VideoLAN
 *
 * Authors: Soomin Lee <bubu@mikan.io>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

// Fake VLCMLVideoGroup as a medialibrary entity with an id

extension VLCMLVideoGroup: VLCMLObject {
    public func identifier() -> VLCMLIdentifier {
        return 42
    }
}

class VideoGroupViewModel: MLBaseModel {
    typealias MLType = VLCMLVideoGroup

    var sortModel = SortModel([.alpha, .nbVideo])

    var updateView: (() -> Void)?

    var files: [VLCMLVideoGroup]

    var cellType: BaseCollectionViewCell.Type { return MovieCollectionViewCell.self }

    var medialibrary: MediaLibraryService

    var indicatorName: String = NSLocalizedString("VIDEO_GROUPS", comment: "")

    required init(medialibrary: MediaLibraryService) {
        self.medialibrary = medialibrary
        self.files = medialibrary.medialib.videoGroups() ?? []
        medialibrary.medialib.setVideoGroupsAllowSingleVideo(false)
    }

    func append(_ item: VLCMLVideoGroup) {
        assertionFailure("VideoGroupViewModel: Cannot append VideoGroups")
    }

    func delete(_ items: [VLCMLObject]) {
        assertionFailure("VideoGroupViewModel: Cannot delete VideoGroups")
    }

    func updateVideoGroups() {
        files = medialibrary.medialib.videoGroups() ?? []
    }

    func sort(by criteria: VLCMLSortingCriteria, desc: Bool) {
        files = medialibrary.medialib.videoGroups(with: criteria, desc: desc) ?? []
        sortModel.currentSort = criteria
        sortModel.desc = desc
        updateView?()
    }
}

// MARK: - Edit

extension VideoGroupViewModel: EditableMLModel {
    func editCellType() -> BaseCollectionViewCell.Type {
        return MediaEditCell.self
    }
}

// MARK: - VLCMLVideoGroup - Search

extension VLCMLVideoGroup: SearchableMLModel {
    func contains(_ searchString: String) -> Bool {
        return name().lowercased().contains(searchString)
    }
}

// MARK: - VLCMLVideoGroup - MediaCollectionModel

extension VLCMLVideoGroup: MediaCollectionModel {
    func sortModel() -> SortModel? {
        return nil
    }

    func files() -> [VLCMLMedia]? {
        return media()
    }

    func title() -> String {
        return name()
    }

    func sortFilesInCollection(with criteria: VLCMLSortingCriteria,
                               desc: Bool) -> [VLCMLMedia]? {
        return media(with: criteria, desc: desc)
    }
}

// MARK: - VLCMLVideoGroup - Helpers

extension VLCMLVideoGroup {
    func numberOfTracksString() -> String {
        let mediaCount = count()
        let tracksString = mediaCount > 1 ? NSLocalizedString("TRACKS", comment: "") : NSLocalizedString("TRACK", comment: "")
        return String(format: tracksString, mediaCount)
    }

    @objc func thumbnail() -> UIImage? {
        var image: UIImage?

        for media in files() ?? [] where media.isThumbnailGenerated() {
            image = UIImage(contentsOfFile: media.thumbnail()?.path ?? "")
            break
        }

        if image == nil {
            let isDarktheme = PresentationTheme.current == PresentationTheme.darkTheme
            image = isDarktheme ? UIImage(named: "movie-placeholder-dark") : UIImage(named: "movie-placeholder-white")
        }
        return image
    }

    func accessibilityText() -> String? {
        return name() + " " + numberOfTracksString()
    }
}
