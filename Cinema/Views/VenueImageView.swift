//
//  VenueImageView.swift
//  Cinema
//
//  Created by Marius on 2021-07-26.
//  Copyright © 2021 Marius. All rights reserved.
//

import UIKit

final class VenueImageView: UIImageView {
    var venue: Venue? {
        didSet {
            image = venueImage
            overlayLabel.text = venue?.rawValue
        }
    }

    private var venueImage: UIImage {
        switch venue {
        case .cinamon:
            return .cinamon
        case .forum, .forumVingis:
            return .forumGold
        case .forumAkropolis:
            return .forumWhite
        case .multikino:
            return .multikino
        default:
            return UIImage()
        }
    }

    private var showOverlay = false {
        didSet {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                if self.showOverlay {
                    self.toggleOverlay()
                }
            }
        }
    }

    private let overlayLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .caption1)
        label.textColor = .secondaryElement
        return label
    }()

    private lazy var overlay: UIView = {
        let view = UIView()
        view.alpha = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .secondaryBackground
        view.layer.cornerRadius = 10
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.secondaryElement.cgColor

        view.addSubview(overlayLabel)

        NSLayoutConstraint.activate([
            overlayLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .padding),
            overlayLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -.padding),
            overlayLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: .padding),
            overlayLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -.padding)
        ])

        return view
    }()

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        self.clipsToBounds = false
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleOverlay)))
    }

    override func awakeFromNib() {
        addSubview(overlay)

        self.image = venueImage
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        overlay.frame = overlay.frame.offsetBy(dx: self.bounds.midX - overlay.bounds.midX,
                                               dy: -overlay.frame.height - .padding)
    }

    @objc private func toggleOverlay() {
        showOverlay.toggle()

        UIView.animate(withDuration: 1.0) { [self] in
            overlay.alpha = showOverlay ? 1 : 0
        }
    }
}

private extension CGFloat {
    static let padding: CGFloat = 8
}
