import SwiftUI

/**
 An simple NavigationView that has an X in the top right
 */
struct EZPanel<Content>: View where Content: View {
    let content: () -> Content
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        NavigationView {
            content().navigationBarItems(trailing: Button(action: { presentationMode.wrappedValue.dismiss() }) {
                Image(systemName: "xmark.circle.fill").foregroundColor(Color(UIColor.systemGray3))
            })
        }
    }
}

#if DEBUG
    struct EZPanel_preview: PreviewProvider {
        static var previews: some View {
            EZPanel {
                Text("Hello World")
            }
        }
    }
#endif
