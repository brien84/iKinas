//
//  LoadingView.swift
//  Cinema
//
//  Created by Marius on 2020-11-17.
//  Copyright © 2020 Marius. All rights reserved.
//

import UIKit

enum LoadingError: String, Error {
    case none = ""
    case noNetwork = "Nepavyksta pasiekti serverio..."
    case noMovies = "Šią dieną filmų nėra"
    case noShowings = "Šią dieną seansų nėra"
    case requiresUpdate = "Ši aplikacijos versija yra nebepalaikoma. Prašome atnaujinti aplikaciją."
}

protocol LoadingViewDelegate: AnyObject {
    func loadingView(_ view: LoadingView, retryButtonDidTap: UIButton)
}

final class LoadingView: UIView {
    weak var delegate: LoadingViewDelegate?

    @IBOutlet private weak var errorMessage: UILabel!
    @IBOutlet private weak var retryButton: UIButton!
    @IBOutlet private weak var updateButton: UIButton!
    @IBOutlet private weak var imageView: UIImageView!

    override init(frame: CGRect) {
        super.init(frame: frame)

        loadView()

        // Always on top, when added to superview.
        self.layer.zPosition = CGFloat(Float.greatestFiniteMagnitude)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @IBAction private func retryButtonDidTap(_ sender: UIButton) {
        delegate?.loadingView(self, retryButtonDidTap: sender)
    }

    @IBAction private func updateButtonDidTap(_ sender: UIButton) {
        if let url = URL(string: "https://apps.apple.com/app/id1580929676") {
            UIApplication.shared.open(url)
        }
    }

    private func set(error: LoadingError) {
        imageView.stopAnimating()
        imageView.image = error == .none ? nil : .empty
        retryButton.isHidden = error == .noNetwork ? false : true
        updateButton.isHidden = error == .requiresUpdate ? false : true
        errorMessage.text = error.rawValue
        isHidden = false
    }

    func startLoading() {
        set(error: .none)
        startAnimation()
    }

    func show(_ error: LoadingError, animated: Bool, completion: (() -> Void)? = nil) {
        if animated {
            frame.origin.y += frame.height
            set(error: error)

            UIView.animate(withDuration: .stdAnimation) { [self] in
                frame.origin.y -= frame.height
            } completion: { _ in
                completion?()
            }
        } else {
            set(error: error)
            completion?()
        }
    }

    func hide(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: .stdAnimation) { [self] in
            frame.origin.y += frame.height
        } completion: { [self] _ in
            isHidden = true
            frame.origin.y -= frame.height

            completion?()
        }
    }

    private func getAnimationImages() -> [UIImage] {
        var images = [UIImage]()
        var index = 0

        while let image = UIImage(named: "\("LoadingAnimation")/\(index)") {
            images.append(image)
            index += 1
        }

        return images
    }

    private func startAnimation() {
        imageView.animationImages = getAnimationImages()
        imageView.image = imageView.animationImages?.first
        imageView.animationDuration = 0.75
        imageView.animationRepeatCount = 0
        imageView.startAnimating()
    }

    private func loadView() {
        guard let nib = Bundle.main.loadNibNamed("LoadingView", owner: self),
              let view = nib.first as? UIView else { fatalError("Could not load nib!") }

        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }
}

private extension UIImage {
    static let empty = UIImage(named: "empty")!
}
