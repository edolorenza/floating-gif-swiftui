//
//  ContentView.swift
//  floating-gif
//
//  Created by Edo Lorenza on 03/01/24.
//

import SwiftUI
import WebKit

struct ContentView: View {
    @StateObject var dragManager = DragGestureViewModel()
    let loremIpsumData: [String] = Array(repeating: "Lorem ipsum dolor sit amet, consectetur adipiscing elit", count: 20)

    var body: some View {
        NavigationView{
            ZStack {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading) {
                        ForEach(loremIpsumData, id: \.self) { ipsumText in
                            Text(ipsumText)
                                .font(.body)
                                .lineLimit(1)
                                .padding()
                        }
                    }
                }
                .navigationBarTitle("Floating GIF", displayMode: .inline)
                GeometryReader { gp in
                    GifView(gifName: "giphy")
                        .frame(width: 140, height: 140)
                        .animation(.default, value: self.dragManager.dragAmount)
                        .position(self.dragManager.dragAmount ?? CGPoint(x: gp.size.width - 50, y: UIScreen.main.bounds.height - (UIScreen.main.bounds.height*0.25)))
                        .highPriorityGesture(
                            DragGesture()
                                .onChanged {
                                    self.dragManager.dragAmount = $0.location
                                }
                                .onEnded { gesture in
                                    self.dragManager.handleDragEndGesture(gesture: gesture, geometry: gp, xPointLeft: 50, xPointRight: 50)
                                }
                        )
                }
            }
        }
    }
}

struct GifView: UIViewRepresentable {
    let gifName: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.isOpaque = false
        webView.backgroundColor = UIColor.clear
        webView.scrollView.isScrollEnabled = false
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let gifPath = Bundle.main.path(forResource: gifName, ofType: "gif") {
            let gifURL = URL(fileURLWithPath: gifPath)
            let data = try? Data(contentsOf: gifURL)
            uiView.load(data!, mimeType: "image/gif", characterEncodingName: "UTF-8", baseURL: NSURL() as URL)
        }
    }
}


final class DragGestureViewModel: ObservableObject {
    
    @Published var dragAmount: CGPoint? = nil
    
    func handleDragEndGesture(gesture: DragGesture.Value, geometry: GeometryProxy, xPointLeft: CGFloat, xPointRight: CGFloat) {
        let position = gesture.location.x
        let yPosition = gesture.location.y
        
        if position <= 60 || position > 300 {
            // use user drag location
        }else if position > 60 && position < 150 {
            // back to leading
            self.dragAmount = CGPoint(x: xPointLeft, y: yPosition)
        } else{
            //back to trailing
            self.dragAmount = CGPoint(x: geometry.size.width - xPointRight, y: yPosition)
        }
    }
}
