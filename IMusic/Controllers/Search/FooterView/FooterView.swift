

import UIKit

class FooterView: UIView {

  private let titleLabel: UILabel = {
    $0.textColor = .gray
    $0.textAlignment = .center
    $0.font = .systemFont(ofSize: 14)
    return $0
  }(UILabel())

  private let indicator: UIActivityIndicatorView = {
    $0.hidesWhenStopped = true
    return $0
  }(UIActivityIndicatorView(style: .medium))

  private lazy var vStack: UIStackView = {
    $0.translatesAutoresizingMaskIntoConstraints = false
    $0.spacing = 3
    $0.axis = .vertical
    return $0
  }(UIStackView(arrangedSubviews: [titleLabel, indicator]))

  // MARK: - Init
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
    setConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func showIndicator() {
    indicator.startAnimating()
    titleLabel.text = "Loading..."

  }

  func hideIndicator() {
    indicator.stopAnimating()
    titleLabel.text = ""
  }
}

private extension FooterView {
  func setupUI() {
    self.addSubview(vStack)
  }

  func setConstraints() {
    NSLayoutConstraint.activate([
      vStack.centerYAnchor.constraint(equalTo: self.centerYAnchor),
      vStack.centerXAnchor.constraint(equalTo: self.centerXAnchor)
    ])
  }
}
