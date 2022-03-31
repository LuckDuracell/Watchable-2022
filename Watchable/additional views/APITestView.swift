//
//  APITestView.swift
//  Watchable
//
//  Created by Luke Drushell on 3/30/22.
//

import SwiftUI

struct APITestView: View {
    
    @State var joke = ""
    
    var body: some View {
        VStack {
//            Text(joke)
//                .multilineTextAlignment(.center)
//                .padding()
//            Button {
//                Task {
//                    let (data, _) = try await URLSession.shared.data(from: URL(string:"http://api-public.guidebox.com/v2/search?api_key=YOUR_API_KEY&type=movie&field=title&query=Terminator")!)
//                                    let decodedResponse = try? JSONDecoder().decode(Joke.self, from: data)
//                                    joke = decodedResponse?.value ?? ""
//                }
//            } label: {
//                Text("Fetch Test")
//            }
        }
    }
}

struct APITestView_Previews: PreviewProvider {
    static var previews: some View {
        APITestView()
    }
}

struct Joke: Codable {
    let value: String
}
