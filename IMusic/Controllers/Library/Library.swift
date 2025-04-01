


import SwiftUI

struct Library: View {
    
    let tracks = UserDefaults.standard.savedTracks()

  var body: some View {
    NavigationView {
      VStack(spacing: 10) {
        GeometryReader { geometry in
          HStack(spacing: 15) {
            Button {
              print("Play")
            } label: {
              Image(systemName: "play.fill")
                .frame(width: geometry.size.width / 2 - 10, height: 50)
                .accentColor(Color.redColor)
                .background(Color.buttonFonColor)
                .cornerRadius(10)
            }
            Button {
              print("Play")
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
          List(tracks) { track in
              LibraryCell(cell: track)
        }.listStyle(.plain)
      }
      .navigationTitle("Library")
    }
  }
}


struct LibraryCell: View {
    
    let cell: SearchViewModel.Cell
    
  var body: some View {
    HStack {
        ImageContentView(imageUrl: cell.iconUrlString ?? "")
            .frame(width: 60, height: 60)
        VStack(alignment: .leading) {
          Text("\(cell.trackName)")
          Text("\(cell.artistName)")
      }
    }
  }
}
#Preview {
  Library()
}


struct ImageContentView: View {
    let imageUrl: String
    
    var body: some View {
        AsyncImage(url: URL(string: imageUrl)) { phase in
            switch phase {
            case .empty:
                ProgressView() // Yuklanayotganda
            case .success(let image):
                image
                    .resizable()
                    .scaledToFit()
            case .failure:
                Image(systemName: "photo") // Xatolik bo'lsa
                    .resizable()
                    .scaledToFit()
            @unknown default:
                EmptyView()
            }
        }
    }
}
