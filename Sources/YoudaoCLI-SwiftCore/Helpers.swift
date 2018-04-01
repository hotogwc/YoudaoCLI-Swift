//
//  Helpers.swift
//  YoudaoCLI-SwiftPackageDescription
//
//  Created by addictedtoelixir on 2018/3/25.
//

import Foundation

func printNoNewLine(str: String) {
    print(str, terminator: "")
}

@discardableResult
func shell(_ args: String...) -> Int32 {
    let task = Process()
    task.launchPath = "/usr/bin/env"
    task.arguments = args
    task.standardInput = FileHandle.nullDevice
    task.standardOutput = FileHandle.nullDevice
    task.standardError = FileHandle.nullDevice
    task.launch()
    task.waitUntilExit()
    return task.terminationStatus
}

func isChineseIncluded(str: String) -> Bool {
    for value in str {
        if ("\u{4E00}" <= value  && value <= "\u{9FA5}") {
            return true
        }
    }
    return false
}


func isAvaliableOS() -> Bool {
#if os(Linux) || os(macOS)
    return true
#else
    return false
#endif
}
