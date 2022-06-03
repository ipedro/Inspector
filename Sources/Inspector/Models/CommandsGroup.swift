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

import UIKit

typealias CommandsGroups = [Inspector.CommandsGroup]
typealias CommandsGroup = Inspector.CommandsGroup

public extension Inspector {
    /// A group of commands.
    struct CommandsGroup {
        public var title: String?
        public var commands: [Command]

        private init(title: String?, commands: [Command]) {
            self.title = title
            self.commands = commands
        }

        public static func group(title: String? = nil, commands: [Command]) -> CommandsGroup {
            CommandsGroup(title: title, commands: commands)
        }

        public static func group(with command: Command) -> CommandsGroup {
            CommandsGroup(title: nil, commands: [command])
        }
    }
}
