//
//  PrototypeButton.swift
//  Watchable
//
//  Created by Luke Drushell on 4/3/22.
//

import SwiftUI

struct PrototypeButton: View {
    
    var source: String
    
    var body: some View {
        HStack {
            Text(source)
                .foregroundColor(.red)
            Spacer()
            Image(systemName: "arrow.up.right.square")
                .foregroundColor(.red)
        } .frame(width: UIScreen.main.bounds.width * 0.85, alignment: .leading)
            .padding()
            .background(Color.white)
            .cornerRadius(15)
    }
}

struct PrototypeButton_Previews: PreviewProvider {
    static var previews: some View {
        PrototypeButton(source: "")
    }
}
