//
//  VenueImageView.swift
//  Cinema
//
//  Created by Marius on 2021-07-26.
//  Copyright © 2021 Marius. All rights reserved.
//

import UIKit

private enum OverlayPosition: Int {
    case top
    case leading
    case trailing
    case bottom
}

final class VenueImageView: UIImageView {
    var venue: Venue? {
        didSet {
            image = venueImage
            overlayLabel.text = venue?.rawValue
        }
    }

    private var venueImage: UIImage {
        switch venue {
        case .apollo:
            return .apollo
        case .atlantis:
            return .atlantis
        case .cinamon:
            return .cinamon
        case .forum:
            return .forum
        case .multikino:
            return .multikino
        default:
            return UIImage()
        }
    }

    @IBInspectable
    private var overlayPosition: Int = 0 {
        didSet {
            _overlayPosition = OverlayPosition(rawValue: overlayPosition) ?? .top
        }
    }

    @IBInspectable
    private var isOverlayEnabled: Bool = true

    private var _overlayPosition: OverlayPosition = .top

    private var showOverlay = false {
        didSet {
            DispatchQueue.main.asyncAfter(deadline: .now() + .hideOverlayInterval) {
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
        view.alpha = .zero
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .secondaryBackground
        view.layer.cornerRadius = .overlayCornerRadius
        view.layer.borderWidth = .overlayBorderWidth
        view.layer.borderColor = UIColor.secondaryElement.cgColor

        view.addSubview(overlayLabel)

        NSLayoutConstraint.activate([
            overlayLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .overlayPadding),
            overlayLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -.overlayPadding),
            overlayLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: .overlayPadding),
            overlayLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -.overlayPadding)
        ])

        return view
    }()

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        self.clipsToBounds = false
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleOverlay)))
    }

    override func awakeFromNib() {
        addSubview(overlay)

        self.isUserInteractionEnabled = isOverlayEnabled
        self.image = venueImage
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        switch _overlayPosition {
        case .top:
            overlay.frame = overlay.frame.offsetBy(
                dx: self.bounds.midX - overlay.bounds.midX,
                dy: -overlay.frame.height - .overlayPadding
            )
        case .leading:
            overlay.frame = overlay.frame.offsetBy(
                dx: -overlay.bounds.maxX - .overlayPadding,
                dy: .zero
            )
        case .trailing:
            overlay.frame = overlay.frame.offsetBy(
                dx: bounds.maxX + .overlayPadding,
                dy: .zero
            )
        case .bottom:
            overlay.frame = overlay.frame.offsetBy(
                dx: self.bounds.midX - overlay.bounds.midX,
                dy: overlay.frame.height + .overlayPadding
            )
        }
    }

    @objc private func toggleOverlay() {
        showOverlay.toggle()

        UIView.animate(withDuration: .stdAnimation) { [self] in
            overlay.alpha = showOverlay ? 1 : 0
        }
    }
}

private extension CGFloat {
    static let overlayPadding: CGFloat = 8
    static let overlayCornerRadius: CGFloat = 10
    static let overlayBorderWidth: CGFloat = 1
}

private extension TimeInterval {
    static let hideOverlayInterval = 2.0
}
