


import SwiftUI

struct Library: View {
    
    @State var tracks = UserDefaults.standard.savedTracks()
    @State private var showAlert: Bool = false
    @State private var track: SearchViewModel.Cell!
    
    var tabbarDelegate: MainTabBarControllerDelegate?
    
  var body: some View {
    NavigationView {
      VStack(spacing: 10) {
        GeometryReader { geometry in
          HStack(spacing: 15) {
            Button {
              print("Play")
                self.track = self.tracks[0]
                self.tabbarDelegate?.maximizingTrackDetailContorller(viewModel: track)
            } label: {
              Image(systemName: "play.fill")
                .frame(width: geometry.size.width / 2 - 10, height: 50)
                .accentColor(Color.redColor)
                .background(Color.buttonFonColor)
                .cornerRadius(10)
            }
            Button {
              print("refresh")
                self.tracks = UserDefaults.standard.savedTracks()
            } label: {
              Image(systemName: "arrow.2.circlepath")
                .frame(width: geometry.size.width / 2 - 10, height: 50)
                .accentColor(Color.redColor)
                .background(Color.buttonFonColor)
                .cornerRadius(10)
            }
          }
        }
        .padding()
        .frame(height: 50)

        Divider()
          .padding(.top, 20)
          .padding(.horizontal)
          List {
              ForEach(tracks) { track in
                  LibraryCell(cell: track)
                      .gesture(
                        LongPressGesture()
                            .onEnded { _ in
                      self.track = track
                      self.showAlert = true
                  }
                            .simultaneously(with: TapGesture().onEnded { _ in
                                if let keyWindow = UIApplication.shared.connectedScenes
                                    .compactMap({ $0 as? UIWindowScene })
                                    .flatMap({ $0.windows })
                                    .first(where: { $0.isKeyWindow }) {
                                    let tabbarVC = keyWindow.rootViewController as? MainTabBarController
                                    tabbarVC?.trackDetailView.delegate = self
                                }
                                self.track = track
                                self.tabbarDelegate?.maximizingTrackDetailContorller(viewModel: self.track)
                            })
                      )
              }
              .onDelete(perform: delete)
        }.listStyle(.plain)
      }
      .actionSheet(isPresented: $showAlert, content: {
          ActionSheet(title: Text("Are you sure tou want to delete this track?"), buttons: [
            .destructive(Text("Delete"), action: {
                print("Delete")
                self.delete(at: self.track)
            }),
            .cancel()
          ])
      })
      .navigationTitle("Library")
    }
  }
    
    func delete(at offsets: IndexSet) {
        tracks.remove(atOffsets: offsets)
        getFromArchive()
    }
    
    func delete(at offsets: SearchViewModel.Cell) {
        let index = tracks.firstIndex(of: track)
        guard let myIndex = index else { return }
        tracks.remove(at: myIndex)
        getFromArchive()
    }
    
    func getFromArchive() {
        if let savedData = try? NSKeyedArchiver.archivedData(withRootObject: tracks, requiringSecureCoding: false) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: UserDefaults.favoriteTracksKey)
        }
    }
    
}

extension Library: TrackMovingDelegate {
    func moveBackForPreviousTrack() -> SearchViewModel.Cell? {
        let index = tracks.firstIndex(of: track)
        guard let myIndex = index else { return nil }
        var nextTrack: SearchViewModel.Cell
        if myIndex - 1 == -1 {
            nextTrack = tracks[tracks.count - 1]
        } else {
            nextTrack = tracks[myIndex - 1]
        }
        self.track = nextTrack
        return nextTrack
    }
    
    func moveForwardForPreviousTrack() -> SearchViewModel.Cell? {
        let index = tracks.firstIndex(of: track)
        guard let myIndex = index else { return nil }
        var nextTrack: SearchViewModel.Cell
        if myIndex + 1 == tracks.count {
            nextTrack = tracks[0]
        } else {
            nextTrack = tracks[myIndex + 1]
        }
        self.track = nextTrack
        return nextTrack
    }
}

#Preview {
  Library()
}

