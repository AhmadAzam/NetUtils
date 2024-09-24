import SwiftUI

struct CopyCellToggleableItemRowView: View {
    var title: String
    var contents: [String]
    let style: CopyCellStyleConfig

    var body: some View {
        HStack(alignment: .center) {
            Text(title)
            Spacer()
            TappedText(content: contents)
                .foregroundColor(style.detailStyle.color)

            if style.chevron {
                CopyCellChevronView()
            }
        }
        .modifier(PaddingListModifier(padding: style.padding))
    }
}
