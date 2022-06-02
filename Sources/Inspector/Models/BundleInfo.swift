//  Copyright (c) 2022 Pedro Almeida
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

import Foundation

struct BundleInfo: Codable {
    var build: String
    var displayName: String?
    var executableName: String?
    var icons: Icons?
    var identifier: String?
    var minimumOSVersion: String?
    var name: String
    var version: String
    var xcodeVersion: String
    var xcodeBuild: String

    struct Icons: Codable {
        var primaryIcon: Icon
        
        private enum CodingKeys: String, CodingKey {
            case primaryIcon = "CFBundlePrimaryIcon"
        }
    }
    
    struct Icon: Codable {
        var files: [String]
        var name: String
        
        private enum CodingKeys: String, CodingKey {
            case files = "CFBundleIconFiles"
            case name = "CFBundleIconName"
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case minimumOSVersion = "MinimumOSVersion"
        case name = "CFBundleName"
        case version = "CFBundleShortVersionString"
        case build = "CFBundleVersion"
        case executableName = "CFBundleExecutable"
        case displayName = "CFBundleDisplayName"
        case identifier = "CFBundleIdentifier"
        case icons = "CFBundleIcons"
        case xcodeVersion = "DTXcode"
        case xcodeBuild = "DTXcodeBuild"
    }
}
