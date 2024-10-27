//
//  FloatingTextField.swift
//  CellarStock
//
//  Created by CANTE Benjamin  on 23/10/2024.
//

import Foundation
import SwiftUI

enum TextFieldType {
    case picker(rows: [String])
    case textField
}

struct FloatingTextField: View {
    
    // MARK: - Variable
    @Binding private var text: String
    
    @FocusState private var isFocused: Bool
    @State private var sheetIsPresented = false
    
    private let type: TextFieldType
    private let placeHolderText: String
    private let isRequired: Bool
    private let rightIcon: String?
    private let rightAction: (() -> Void)?
    
    private let textFieldHeight: CGFloat = 50
    
    private var shouldPlaceHolderMove: Bool {
        isFocused || !text.isEmpty
    }
    
    private var textFiedAllowed: Bool {
        rightIcon == nil || rightAction != nil
    }
    
    private var placeHolder: AttributedString {
        var text = AttributedString(placeHolderText)
        text.foregroundColor = .white
        
        if isRequired, !shouldPlaceHolderMove {
            return text + " " + requiredAttributedText()
        } else {
            return text
        }
    }
    
    // MARK: - init
    public init(type: TextFieldType = .textField,
                placeHolder: String,
                text: Binding<String>,
                isRequired: Bool = false,
                rightIcon: String? = nil,
                rightAction: (() -> Void)? = nil) {
        self.type = type
        self.placeHolderText = placeHolder
        _text = text
        self.isRequired = isRequired
        self.rightIcon = rightIcon
        self.rightAction = rightAction
    }
    
    var body: some View {
        HStack(spacing: CharterConstants.marginSmall) {
            TextField("", text: $text)
                .focused($isFocused)
                .allowsHitTesting(textFiedAllowed)
            
            if let rightIcon {
                if let rightAction {
                    Button {
                        rightAction()
                    } label: {
                        rightIconView(rightIcon)
                    }
                } else {
                    rightIconView(rightIcon)
                }
            }
        }
        .if(!textFiedAllowed) {
            $0
                .contentShape(Rectangle())
                .onTapGesture {
                    hideKeyboard()
                    sheetIsPresented = true
                }
        }
        .padding(.vertical, CharterConstants.marginSmall)
        .background(alignment: .leading) {
            Text(placeHolder)
                .scaleEffect(shouldPlaceHolderMove ? 0.7 : 1, anchor: .leading)
                .padding(.bottom, shouldPlaceHolderMove ? textFieldHeight : 0)
                .opacity(isFocused ? 1 : 0.6)
                .animation(.linear, value: shouldPlaceHolderMove)
        }
        .overlay(alignment: .bottom) {
            Divider()
                .frame(height: isFocused ? 1: 0.5)
                .background(isFocused ? .white : CharterConstants.halfWhite)
                .animation(.linear, value: shouldPlaceHolderMove)
        }
        .sheet(isPresented: $sheetIsPresented) {
            switch type {
            case .picker(let rows):
                AutoCompleteSheet(title: placeHolderText,
                                  rows: rows,
                                  isPresented: $sheetIsPresented,
                                  value: $text)
            case .textField:
                EmptyView()
            }
        }
        .frame(height: textFieldHeight)
    }
    
    private var isRightIconHighlited: Bool {
        if case .picker = type { return true }
        return isFocused || rightAction != nil
    }
    
    private func rightIconView(_ rightIcon: String) -> some View {
        Image(systemName: rightIcon)
            .foregroundStyle(isRightIconHighlited ? Color.white : CharterConstants.halfWhite)
            .animation(.linear, value: shouldPlaceHolderMove)
    }
}
