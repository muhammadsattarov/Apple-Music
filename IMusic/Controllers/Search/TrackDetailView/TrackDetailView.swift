

import UIKit
import SDWebImage
import AVKit


protocol TrackMovingDelegate {
  func moveBackForPreviousTrack() -> SearchViewModel.Cell?
  func moveForwardForPreviousTrack() -> SearchViewModel.Cell?
}

class TrackDetailView: UIView {

  @IBOutlet weak var miniTrackView: UIView!
  @IBOutlet weak var miniTrackImageView: UIImageView!
  @IBOutlet weak var miniTrackTitleLabel: UILabel!
  @IBOutlet weak var miniPlayPauseButton: UIButton!
  @IBOutlet weak var miniNextForwardButton: UIButton!
  
  @IBOutlet weak var maximizedStackView: UIStackView!
  @IBOutlet weak var trackImageView: UIImageView!
  @IBOutlet weak var currentTimeSlider: UISlider!
  @IBOutlet weak var currentTimeLabel: UILabel!
  @IBOutlet weak var durationTimeLabel: UILabel!
  @IBOutlet weak var trackTitleLabel: UILabel!
  @IBOutlet weak var authorNameLabel: UILabel!
  @IBOutlet weak var playPauseButton: UIButton!
  @IBOutlet weak var volumeSlider: UISlider!
  
  private let player: AVPlayer = {
    $0.automaticallyWaitsToMinimizeStalling = false
    return $0
  }(AVPlayer())

  var delegate: TrackMovingDelegate?
  weak var tabbarDelegate: MainTabBarControllerDelegate?

  // MARK: - awakeFromNib
  override func awakeFromNib() {
    super.awakeFromNib()
    isSmallImage()
    setupGesture()
  }

  // MARK: - Setup
  func configure(with model: SearchViewModel.Cell) {
      let track = UserDefaults.standard.savedTracks()
      print(track.map({ $0.trackName}))
    playPauseButton.setImage(UIImage(named: "pause"), for: .normal)
    miniPlayPauseButton.setImage(UIImage(named: "pause"), for: .normal)
    miniTrackTitleLabel.text = model.trackName

    authorNameLabel.text = model.artistName
    trackTitleLabel.text = model.trackName
    playTrack(previewUrl: model.previewUrl)

    monitorStartTime()
    observeOlayerCurrentTime()

    let imageUrl600 = model.iconUrlString?.replacingOccurrences(of: "100x100", with: "600x600")
    guard let url = URL(string: imageUrl600 ?? "") else { return }

    DispatchQueue.main.async { [weak self] in
      self?.miniTrackImageView.sd_setImage(with: url)
      self?.trackImageView.sd_setImage(with: url)
    }
  }

  private func playTrack(previewUrl: String?) {
    guard let url = URL(string: previewUrl ?? "") else { return }
    let playerItem = AVPlayerItem(url: url)
    player.replaceCurrentItem(with: playerItem)
    player.play()
  }

  // MARK: - Animation
  private func enLargeTackImageView() {
    UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseInOut) {
      self.trackImageView.transform = .identity
    }
  }

  private func reduceTrackImageView() {
    UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseInOut) { [weak self] in
      self?.isSmallImage()
    }
  }

  private func isSmallImage() {
    let scale: CGFloat = 0.8
    self.trackImageView.transform = CGAffineTransform(scaleX: scale, y: scale)
  }

  // MARK: - Time setup
  private func monitorStartTime() {
    let time = CMTimeMake(value: 1, timescale: 3)
    let times = [NSValue(time: time)]
    player.addBoundaryTimeObserver(forTimes: times, queue: .main) { [weak self] in
      self?.enLargeTackImageView()
    }
  }

  private func observeOlayerCurrentTime() {
    let interval = CMTimeMake(value: 1, timescale: 2)
    player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
      self?.currentTimeLabel.text = time.toDisplayString()

      let durationTime = self?.player.currentItem?.duration
      let currentDurationText = ((durationTime ?? CMTimeMake(value: 1, timescale: 1)) - time).toDisplayString()

      self?.durationTimeLabel.text = "-\(currentDurationText)"

      self?.updateCurrentTimeSlider()
    }
  }

  private func updateCurrentTimeSlider() {
    let currentTimeSeconds = CMTimeGetSeconds(player.currentTime())
    let durationSeconds = CMTimeGetSeconds(player.currentItem?.duration ?? CMTimeMake(value: 1, timescale: 1))
    let persentage = currentTimeSeconds / durationSeconds
    self.currentTimeSlider.value = Float(persentage)
  }

  // MARK: - @IBAction
  @IBAction func dragDownButtonTapped(_ sender: Any) {
    self.tabbarDelegate?.minimizedTrackDetailConstroller()
  }
  
  @IBAction func handleCurrentTimeSlider(_ sender: Any) {
    let persentage = currentTimeSlider.value
    guard let duration = player.currentItem?.duration else { return }
    let durationInSeconds = CMTimeGetSeconds(duration)
    let seekTimeInSeconds = Float64(persentage) * durationInSeconds
    let seekTime = CMTimeMakeWithSeconds(seekTimeInSeconds, preferredTimescale: 1)
    player.seek(to: seekTime)
  }

  @IBAction func playPauseButtonTapped(_ sender: Any) {
    if player.timeControlStatus == .paused {
      player.play()
      playPauseButton.setImage(UIImage(named: "pause"), for: .normal)
      miniPlayPauseButton.setImage(UIImage(named: "pause"), for: .normal)
      enLargeTackImageView()
    } else {
      player.pause()
      playPauseButton.setImage(UIImage(named: "play"), for: .normal)
      miniPlayPauseButton.setImage(UIImage(named: "play"), for: .normal)
      reduceTrackImageView()
    }
  }
  
  @IBAction func previousButtonTapped(_ sender: Any) {
    guard let cellViewModel = delegate?.moveBackForPreviousTrack() else { return }
    self.configure(with: cellViewModel)
  }

  @IBAction func nextTrackButtonTapped(_ sender: Any) {
    guard let cellViewModel = delegate?.moveForwardForPreviousTrack() else { return }
    self.configure(with: cellViewModel)
  }


  @IBAction func handleVolumeSlider(_ sender: Any) {
    player.volume = volumeSlider.value
  }
  
}


// MARK: - Setup Gestures
private extension TrackDetailView {
  func setupGesture() {
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
    let dismissGesture = UIPanGestureRecognizer(target: self, action: #selector(handleDismissPanGesture))
    self.miniTrackView.addGestureRecognizer(tapGesture)
    self.miniTrackView.addGestureRecognizer(panGesture)
    self.addGestureRecognizer(dismissGesture)
  }

  @objc func handleTapGesture() {
    self.tabbarDelegate?.maximizingTrackDetailContorller(viewModel: nil)
  }

  @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
    switch gesture.state {
    case .began:
      print("Began")
    case .changed:
      handlePanChnaged(gesture: gesture)
    case .ended:
      handlePanEnded(gesture: gesture)
    case .possible:
      print("possible")
    case .cancelled:
      print("cancelled")
    case .failed:
      print("failed")
    @unknown default:
      print("default")
    }
  }

  func handlePanChnaged(gesture: UIPanGestureRecognizer) {
    let translation = gesture.translation(in: self.superview)
    self.transform = CGAffineTransform(translationX: 0, y: translation.y)

    let newAlpha = 1 + translation.y / 200
    self.miniTrackView.alpha = newAlpha < 0 ? 0 : newAlpha
    self.maximizedStackView.alpha = -translation.y / 200
  }

  func handlePanEnded(gesture: UIPanGestureRecognizer) {
    let translation = gesture.translation(in: self.superview)
    let velocity = gesture.velocity(in: self.superview)

    UIView.animate(
      withDuration: 0.5,
      delay: 0,
      usingSpringWithDamping: 0.7,
      initialSpringVelocity: 1,
      options: .curveEaseOut) {
        self.transform = .identity
        if translation.y < -200 || velocity.y < -500 {
          self.tabbarDelegate?.maximizingTrackDetailContorller(viewModel: nil)
        } else {
          self.miniTrackView.alpha = 1
          self.maximizedStackView.alpha = 0
        }
      }
  }

  // Gesture for transform LargeTrackDetailView to miniTrackDetailView
  @objc func handleDismissPanGesture(gesture: UIPanGestureRecognizer) {
    switch gesture.state {
    case .changed:
      translationChangedInDismiss(gesture: gesture)
    case .ended:
      translationEndedInDismiss(gesture: gesture)
    case .possible:
      print("possible")
    case .began:
      print("began")
    case .cancelled:
      print("cancelled")
    case .failed:
      print("failed")
    @unknown default:
      print("unknown default")
    }
  }

  func translationChangedInDismiss(gesture: UIPanGestureRecognizer) {
    let translation = gesture.translation(in: self.superview)
    self.transform = CGAffineTransform(translationX: 0, y: translation.y)
  }

  func translationEndedInDismiss(gesture: UIPanGestureRecognizer) {
    let translation = gesture.translation(in: self.superview)
    UIView.animate(withDuration: 0.5,
                   delay: 0, usingSpringWithDamping: 0.7,
                   initialSpringVelocity: 1,
                   options: .curveEaseOut) {
      self.transform = .identity
      if translation.y > 50 {
        self.tabbarDelegate?.minimizedTrackDetailConstroller()
      }
    }
  }

}
