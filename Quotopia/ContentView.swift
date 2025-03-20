//
//  ContentView.swift
//  Quotopia
//
//  Created by Devan Myers on 3/20/25.
//

import SwiftUI

struct ContentView: View {
    @State private var quote = "Get Random Quote!"
    @State private var author = ""
    @State private var fullquote = ""
    @State private var showingAlert = false

    var body: some View {
        NavigationView {
            ZStack {
                //https://developer.apple.com/documentation/swiftui/lineargradient/#topics
                //https://medium.com/push-2-prod/gradients-in-swiftui-e3481685cb9d
                LinearGradient(gradient: Gradient(colors: [Color.white, Color.black]), startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                Image (systemName: "quote.closing")
                    .font(.system(size: 270))
                    .foregroundStyle(Color.white.opacity (0.4))
                VStack(spacing: 20) {
                    // quote
                    Text("❝\(quote)❞")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        //.multilineTextAlignment(.center)
                        .padding()
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(15)

                    // author
                    Text("- \(author)")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                    //get new quote
                    Button(action: {
                        Task {
                            await newQuote()
                        }})
                    {
                        Text("Generate New Quote")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                                        ////https://developer.apple.com/documentation/swiftui/lineargradient/#topics
                                        //https://medium.com/push-2-prod/gradients-in-swiftui-e3481685cb9d
                            .background(LinearGradient(gradient: Gradient(colors: [Color.gray, Color.white]), startPoint: .top, endPoint: .bottom)
                                .ignoresSafeArea())
                            .foregroundColor(.black)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.3), radius: 5, x: 2, y: 2)
                    }
                    .padding(.horizontal, 40)
                    
                    //https://www.youtube.com/watch?v=3igQV_xrcI0&t=496s
                    ShareLink(item: fullquote) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundStyle(Color.white)
                    }
                    Text("About").onTapGesture {
                        about()
                    }
                    .foregroundColor(.white)
                }
                .padding()
            }
            .navigationTitle("Quotopia")
            .navigationBarTitleDisplayMode(.inline)
        }
        .task {
            await newQuote()
        }
        //warning if cant get data frm api
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Loading Error"),
                  message: Text("There was a problem loading your quote. \nPlease check network connection or API."),
                  dismissButton: .default(Text("OK")))
        }
    }
    func about() {
        quote = "This app uses 'https://dummyjson.com/quotes/' to generate inspirational, interesting, or thought provoking quotes. \n\nEnjoy!"
        author = "Devan Myers"
    }
    //generate random number return ad string string
    func generateRandomNumberString() -> String {
                           //https://stackoverflow.com/questions/24007129/how-to-generate-a-random-number-in-swift
        let randomNumber = Int.random(in: 1...1454)
        return String(randomNumber)
    }
    func newQuote() async {
        let randomNum = generateRandomNumberString()
        let query = "https://dummyjson.com/quotes/\(randomNum)"
        
        if let url = URL(string: query) {
            if let (data, _) = try? await URLSession.shared.data(from: url) {
                if let decodedResponse = try? JSONDecoder().decode(Quote.self, from: data) {
                    quote = decodedResponse.quote
                    author = decodedResponse.author
                    fullquote = "❝\(quote)❞ -\(author)"
                    return
                }
            }
        }
        showingAlert = true
    }
}

#Preview {
    ContentView()
}

struct Quote: Codable {
    var quote: String
    var author: String
}

