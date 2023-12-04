//
//  Previews.swift
//  Cinema
//
//  Created by Marius on 2023-09-25.
//  Copyright © 2023 Marius. All rights reserved.
//

import Foundation
import OrderedCollections

struct Previews {
    static func createFeatured(
        id: UUID = UUID(),
        label: String = "Premjera",
        networkImage: NetworkImage.State = .init(url: .featuredPreview),
        originalTitle: String = "Movie Title",
        title: String = "Filmo Pavadinimas"
    ) -> Featured.State {
        Featured.State(
            id: id,
            label: label,
            networkImage: networkImage,
            originalTitle: originalTitle,
            title: title
        )
    }

    static func createShowing(
        ageRating: String = "N-18",
        city: City = .vilnius,
        date: Date = Date(timeIntervalSinceNow: .hour),
        duration: String = "90 min",
        genres: OrderedSet<String> = ["Drama", "Komedija"],
        metadata: OrderedSet<String> = ["Independent"],
        id: UUID = UUID(),
        is3D: Bool = true,
        networkImage: NetworkImage.State = NetworkImage.State(url: .posterPreview),
        originalTitle: String = "Movie Title",
        plot: String = .loremIpsum,
        title: String = "Filmo Pavadinimas",
        trailer: String = "https://youtu.be/ra9I0HScTDw",
        url: URL = URL(string: "https://www.ioys.lt/iKinas/")!,
        venue: Venue = .forum,
        year: String = "2020"
    ) -> Showing.State {
        Showing.State(
            ageRating: ageRating,
            city: city,
            date: date,
            duration: duration,
            genres: genres,
            metadata: metadata,
            id: id,
            is3D: is3D,
            networkImage: networkImage,
            originalTitle: originalTitle,
            plot: plot,
            title: title,
            trailer: trailer,
            url: url,
            venue: venue,
            year: year
        )
    }
}

private extension String {
    static let loremIpsum =
        """
        Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla vulputate sapien interdum auctor pharetra.
        Aenean ut facilisis lectus. Ut metus eros, convallis eu orci vel, lacinia porttitor lacus.
        Integer lorem leo, maximus vel sapien vitae, pretium aliquam eros.
        Nunc fringilla egestas enim, a ullamcorper dolor imperdiet finibus.
        Mauris consectetur ut justo vel euismod. Curabitur non mollis nisl.

        Etiam lobortis cursus commodo. Duis congue ligula quis urna volutpat elementum. Nam in erat felis.
        Fusce ornare nulla sed elit placerat, sagittis dignissim ligula viverra. Maecenas non placerat leo.
        Proin eu sollicitudin lectus, bibendum cursus lacus. In et tempor nisi, quis finibus est.
        Nunc consequat non lorem nec rutrum. Suspendisse potenti. Cras posuere rhoncus laoreet.
        Etiam eu tellus vel erat egestas volutpat maximus ut mi.
        Pellentesque erat nisi, aliquam id lacus ut, mollis vestibulum sem.
        Vivamus volutpat posuere quam, vitae euismod eros posuere non. Sed pellentesque rutrum vestibulum.
        Sed maximus vitae felis eleifend malesuada.

        Sed consequat quis lorem eget consequat. Donec porta libero in magna euismod imperdiet tincidunt in neque.
        Etiam dictum nisl vitae fringilla posuere. Maecenas nec justo facilisis, efficitur nisl eget, fermentum nibh.
        Sed tempor eros ex, a semper est placerat sed.
        Aenean egestas, lacus quis luctus ultrices, odio erat consectetur sem, vitae imperdiet orci metus quis turpis.
        Integer ac lorem ac nunc interdum consectetur. Etiam eu dui sit amet ex dapibus eleifend.
        """
}

private extension URL {
    static let featuredPreview = URL(string: "featuredPreview")!
    static let posterPreview = URL(string: "posterPreview")!
}
