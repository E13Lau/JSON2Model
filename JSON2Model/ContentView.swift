//
//  ContentView.swift
//  JSON2Model
//
//  Created by lau on 2020/5/30.
//  Copyright © 2020 xllau. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State
    private var editText: String = ""
    @State
    private var name: String = ""

    @State
    private var text: String = ""
    @State
    private var type: Config.ModelType = .struct
    
    var body: some View {
        HStack(spacing: 20) {
            TextView(text: $editText)
                .frame(minWidth: 300, minHeight: 300)
            
            VStack(spacing: 10) {
                MenuButton(label: Text("\(self.type.rawValue)")) {
                    Button(action: {
                        self.type = Config.ModelType.struct
                    }) {
                        Text(Config.ModelType.struct.rawValue)
                    }
                    Button(action: {
                        self.type = Config.ModelType.class
                    }) {
                        Text(Config.ModelType.class.rawValue)
                    }
                }
                .frame(width: 80)
                TextField("ModelName", text: $name)
                    .lineLimit(1)
                    .frame(minWidth: 100, maxWidth: 150)
                Button(action: {
                    self.text = Utility.formtter(text: self.editText, name: self.name, type: self.type)
                }) {
                    Text(">>>")
                }
            }
            
            TextView(text: $text, isEditable: false)
                .frame(minWidth: 300, minHeight: 300)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
