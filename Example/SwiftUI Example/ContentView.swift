//  Copyright (c) 2021 Pedro Almeida
//  
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.


import SwiftUI
import Inspector

struct ContentView: View {
    var window: UIWindow?

    @State var isPresented = false

    @State var text = "Hello, world!"

    var body: some View {
        NavigationView() {
            VStack {
                TextField("text field", text: $text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button("Inspect") {
                    isPresented.toggle()
                }
                .padding()
            }
            .inspect(
                isPresented: $isPresented,
                inspectorViewHierarchyLayers: nil,
                inspectorViewHierarchyColorScheme: nil,
                inspectorCommandGroups: nil,
                inspectorElementLibraries: nil
            )
        }
        .navigationTitle("Inspector")
        .background(Color(UIColor.systemGroupedBackground))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
