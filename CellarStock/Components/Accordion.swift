//
//  Accordion.swift
//  CellarStock
//
//  Created by CANTE Benjamin on 01/11/2023.
//

import SwiftUI

struct Accordion<Content, RightView>: View where Content: View, RightView: View {
    let title: String
    let subtitle: String?
    let image: UIImage?
    @State private var isCollapsed: Bool
    @ViewBuilder let content: () -> Content
    @ViewBuilder let rightView: () -> RightView
    
    init(title: String,
         subtitle: String? = nil,
         image: UIImage? = nil,
         isCollapsed: Bool = true,
         content: @escaping () -> Content,
         rightView: @escaping () -> RightView = { EmptyView() }) {
        self.title = title
        self.subtitle = subtitle
        self.image = image
        _isCollapsed = State(initialValue: isCollapsed)
        self.content = content
        self.rightView = rightView
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            titleView
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation {
                        isCollapsed.toggle()
                    }
                }
            contentView
        }
        .padding(CharterConstants.margin)
        .background(.black)
        .clipShape(RoundedRectangle(cornerRadius: CharterConstants.radiusSmall))
        .bordered()
    }
    
    private var titleView: some View {
        HStack(alignment: .center, spacing: CharterConstants.marginSmall) {
            if let image {
                Image(uiImage: image)
                    .frame(width: 24, height: 24)
            }
            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .font(.title3)
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                }
            }
            Spacer()
            rightView()
            Image(systemName: isCollapsed ? "chevron.down" : "chevron.up")
        }
    }
    
    private var contentView: some View {
        VStack(spacing: 0) {
            if !$isCollapsed.wrappedValue {
                content()
            }
        }
        .padding(.horizontal, CharterConstants.marginXSmall)
        .padding(.vertical, CharterConstants.marginSmall)
        .frame(maxWidth: .infinity, maxHeight: isCollapsed ? 0 : .none)
        .clipped()
    }
}

private extension View {
    @ViewBuilder
    func bordered() -> some View {
        self
            .overlay(RoundedRectangle(cornerRadius: CharterConstants.radiusSmall)
                .stroke(.gray, lineWidth: 1))
    }
}
