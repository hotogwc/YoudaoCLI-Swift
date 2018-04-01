import YoudaoCLI_SwiftCore


let youdao = YoudaoCLISwift()


do {
    try youdao.run()
} catch {
    print("error happened: ", error)
}

