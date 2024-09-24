import SwiftUI

struct DeviceInfoSectionView: View {
    var section: DeviceInfoSectionModel
    @AppStorage var isExpanded: Bool
    @State var focused = false

    init(section: DeviceInfoSectionModel) {
        self.section = section
        _isExpanded = AppStorage(wrappedValue: true, "\(section.title).deviceinfo.isExpanded")
    }

    var body: some View {
        FSDisclosureGroup(isExpanded: $isExpanded, content: {
            VStack(spacing: 0) {
                ForEach(section.rows) { row in
                    row
                }
            }
            .cornerRadius(6)
        }, label: {
            HStack(alignment: .center) {
                Text(section.title).font(.headline).padding()
                Spacer()
            }
        })
        .background(Color(UIColor.systemGroupedBackground))
        .contextMenu {
            Button(action: {
                withAnimation {
                    isExpanded.toggle()
                }
            }, label: {
                Label(isExpanded ? "Collapse" : "Expand", systemImage: isExpanded ? "rectangle.compress.vertical" : "rectangle.expand.vertical")
            })
            Button(action: {
                withAnimation {
                    focused.toggle()
                }
            }, label: {
                Label("Focus", systemImage: "rectangle.and.text.magnifyingglass")
            })
        }
        .sheet(isPresented: $focused, content: {
            EZPanel(content: {
                ScrollView {
                    ForEach(section.rows) { row in
                        row
                    }
                }
                .navigationTitle(section.title)
                .navigationBarTitleDisplayMode(.inline)
            })
        })
    }
}
