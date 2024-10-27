//
//  Accordion.swift
//  CellarStock
//
//  Created by CANTE Benjamin on 01/11/2023.
//

import SwiftUI

struct Accordion<Content>: View where Content: View {
    let title: String
    let subtitle: String?
    let image: UIImage?
    @Binding var isCollapsed: Bool
    @ViewBuilder let content: () -> Content
    
    init(title: String,
         subtitle: String? = nil,
         image: UIImage? = nil,
         isCollapsed: Binding<Bool>,
         content: @escaping () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.image = image
        _isCollapsed = isCollapsed
        self.content = content
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
        .clipShape(RoundedRectangle(cornerRadius: CharterConstants.radius))
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
            Image(systemName: isCollapsed ? "chevron.down" : "chevron.up")
        }
    }
    
    private var contentView: some View {
        VStack(spacing: 0) {
            if !isCollapsed {
                content()
            }
        }
        .padding(.horizontal, CharterConstants.marginXSmall)
        .padding(.vertical, CharterConstants.marginSmall)
        .frame(maxWidth: .infinity, maxHeight: isCollapsed ? 0 : .none)
        .clipped()
    }
}
