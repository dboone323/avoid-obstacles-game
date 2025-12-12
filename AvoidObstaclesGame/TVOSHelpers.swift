
import SwiftUI

// Enhancement #90: tvOS Support Support Config
// This file acts as a tvOS specific view implementation

#if os(tvOS)
struct TVOSControlsView: View {
    var body: some View {
        HStack {
            Text("Press Play/Pause to Start")
            Text("Swipe to Move")
        }
        .font(.title)
    }
}
#endif
