



import SwiftUI

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
