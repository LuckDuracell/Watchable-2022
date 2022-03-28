//
//  AppIconView.swift
//  Watchable
//
//  Created by Luke Drushell on 3/27/22.
//

import SwiftUI

struct AppIconView: View {
    var body: some View {
        ScrollView {
            VStack {
                Image("AppIcon", bundle: Bundle.main)
                    .resizable()
                    .frame(width: 100, height: 100, alignment: .center)
                Button {
                    UIApplication.shared.setAlternateIconName(nil)
                } label: {
                    HStack {
                        Text("Original")
                        Spacer()
                        Image(uiImage: UIImage(named:"AppIcon") ?? UIImage())
                            .resizable()
                            .frame(width: 48, height: 48, alignment: .center)
                            .cornerRadius(10)
                    } .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(15)
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                }
                Divider()
                Button {
                    UIApplication.shared.setAlternateIconName("AppIcon-1")
                } label: {
                    HStack {
                        Text("Overpriced")
                        Spacer()
                        Image(uiImage: UIImage(named:"AppIcon-1") ?? UIImage())
                            .resizable()
                            .frame(width: 48, height: 48, alignment: .center)
                            .cornerRadius(10)
                    } .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(15)
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                }
                
                Spacer()
                
                Text("More coming soon!")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .padding(100)
                
            }
        }
    }
}

struct AppIconView_Previews: PreviewProvider {
    static var previews: some View {
        AppIconView()
    }
}
