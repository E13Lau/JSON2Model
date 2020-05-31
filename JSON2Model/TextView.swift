//
//  TextView.swift
//  JSON2Model
//
//  Created by lau on 2020/5/31.
//  Copyright © 2020 xllau. All rights reserved.
//https://gist.github.com/unnamedd/6e8c3fbc806b8deb60fa65d6b9affab0

import Combine
import SwiftUI

struct TextView: NSViewRepresentable {
    @Binding var text: String
    var isEditable: Bool = true
    var font: NSFont? = .systemFont(ofSize: 14, weight: .regular)
    
    var onEditingChanged: () -> Void = { }
    var onCommit: () -> Void = { }
    var onTextChange: (String) -> Void = { _ in }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeNSView(context: Context) -> CustomTextView {
        let textView = CustomTextView(text: text, isEditable: isEditable, font: font)
        textView.delegate = context.coordinator
        return textView
    }
    
    func updateNSView(_ nsView: CustomTextView, context: Context) {
        nsView.text = text
        nsView.selectedRanget = context.coordinator.selectedRanges
    }
}

extension TextView {
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: TextView
        var selectedRanges: [NSValue] = []
        init(_ parent: TextView) {
            self.parent = parent
        }
        
        func textDidBeginEditing(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else {
                return
            }
            self.parent.text = textView.string
            self.parent.onEditingChanged()
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else {
                return
            }
            self.parent.text = textView.string
            self.selectedRanges = textView.selectedRanges
        }
        
        func textDidEndEditing(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else {
                return
            }
            self.parent.text = textView.string
            self.parent.onCommit()
        }
    }
}

// MARK: - CustomTextView
final class CustomTextView: NSView {
    private var isEditable: Bool
    private var font: NSFont?
    
    weak var delegate: NSTextViewDelegate?
    
    var text: String {
        didSet {
            textView.string = text
        }
    }
    
    var selectedRanget: [NSValue] = [] {
        didSet {
            guard selectedRanget.count > 0 else {
                return
            }
            textView.selectedRanges = selectedRanget
        }
    }
    
    private lazy var scrollView: NSScrollView = {
        let scrollView = NSScrollView()
        scrollView.drawsBackground = true
        scrollView.borderType = .noBorder
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalRuler = false
        scrollView.autoresizingMask = [.width, .height]
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var textView: NSTextView = {
        let contentSize = scrollView.contentSize
        let textStorage = NSTextStorage()
        
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        
        let textContainer = NSTextContainer(containerSize: scrollView.frame.size)
        textContainer.widthTracksTextView = true
        textContainer.containerSize = NSSize(width: contentSize.width, height: CGFloat.greatestFiniteMagnitude)
        
        layoutManager.addTextContainer(textContainer)
        
        let textView = NSTextView(frame: .zero, textContainer: textContainer)
        textView.autoresizingMask = .width
        textView.backgroundColor = .textBackgroundColor
        textView.delegate = self.delegate
        textView.drawsBackground = true
        textView.font = self.font
        textView.isEditable = self.isEditable
        textView.isHorizontallyResizable = false
        textView.isVerticallyResizable = true
        textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.minSize = NSSize(width: 0, height: contentSize.height)
        textView.textColor = .labelColor
        
        return textView
    }()
    
    init(text: String, isEditable: Bool, font: NSFont?) {
        self.font = font
        self.isEditable = isEditable
        self.text = text
        
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillDraw() {
        super.viewWillDraw()
        
        setupScrollViewConstraints()
        setupTextView()
    }
    
    func setupScrollViewConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
        ])
    }
    
    func setupTextView() {
        scrollView.documentView = textView
    }
}

#if DEBUG
struct TextView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TextView(
                text: .constant("{ \n    planets { \n        name \n    }\n}"),
                isEditable: true
            )
            .environment(\.colorScheme, .dark)
            .previewDisplayName("Dark Mode")
            
            TextView(
                text: .constant("{ \n    planets { \n        name \n    }\n}"),
                isEditable: false
            )
            .environment(\.colorScheme, .light)
            .previewDisplayName("Light Mode")
        }
    }
}
#endif
