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
                VStack {
                    OriginalAppIconButton()
                    Divider()
                    AppIconButton(title: "Susan", iconName: "AppIcon-1")
                    Divider()
                    AppIconButton(title: "Construction", iconName: "constructionIcons")
                    Divider()
                    AppIconButton(title: "Superior", iconName: "superiorIcons")
                    Divider()
                    AppIconButton(title: "Master", iconName: "masterIcons")
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

struct AppIconButton: View {
    
    let title: String
    let iconName: String
    
    var body: some View { 
        Button {
            UIApplication.shared.setAlternateIconName("\(iconName)")
        } label: {
            HStack {
                Text("\(title)")
                Spacer()
                Image(uiImage: UIImage(named:"\(iconName)") ?? UIImage())
                    .resizable()
                    .frame(width: 48, height: 48, alignment: .center)
                    .cornerRadius(10)
            } .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(15)
                .padding(.horizontal)
                .padding(.vertical, 5)
        }
    }
}

struct OriginalAppIconButton: View {
    var body: some View {
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
    }
}
