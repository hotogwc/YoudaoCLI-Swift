import Foundation
import Rainbow
import Kanna
import CLISpinner
import Files

fileprivate extension String {
    fileprivate func urlEncode() -> String {
        guard let encode = self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return "" }
        return encode
    }
    
    fileprivate func trimmSpace() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

public final class YoudaoCLISwift {
    
    public typealias ArgumentType = (words: [String], isVoice: Bool, isMore: Bool)
    
    struct QueryURLs {
        let isMore: Bool
        let words: [String]
        let queryString: String
        let voiceString: String

        init(words: [String], isMore: Bool) {
            self.words = words
            self.queryString = words.joined(separator: " ")
            self.voiceString = words.joined(separator: "+")
            self.isMore = isMore
        }
        
        var isChinese: Bool {
            return isChineseIncluded(str: queryString)
        }
        
        var queryURL: URL {
            if isChinese {
                return URL(string: "http://dict.youdao.com/w/eng/" + queryString.urlEncode())!
            } else {
                return URL(string: "http://dict.youdao.com/w/" + queryString.urlEncode())!
            }
        }
        
        var voiceURL: URL {
            let s = "https://dict.youdao.com/dictvoice?audio=" + voiceString.urlEncode() + "&type=2"
            return URL(string: s)!
        }

    }
    
    var argumentType: ArgumentType?
    
    private let arguments: [String]
    
    public init(arguments: [String] = CommandLine.arguments) {
        self.arguments = arguments
    }
    
    public func run() throws {

        if arguments.count == 1 {
            displayUsage()
            return
        }
        
        argumentType = parseArguments(arguments)
        guard let _argumentType = argumentType else {
            throw Error.invalidArgument
        }
        
        var doc: HTMLDocument?
        
        
        let query = QueryURLs(words: _argumentType.words, isMore: _argumentType.isMore)
        let spinner = Spinner(pattern: .dots2)
        spinner.start()
        do {
            doc = try HTML(url: query.queryURL, encoding: .utf8)
        } catch {
            print(error.localizedDescription)
        }
        
        guard let _doc = doc else {
            return
        }
        
        //word basic query
        processBasicQuery(doc: _doc, isChinese: query.isChinese, isMulti: _argumentType.words.count != 1, query: query.queryString)
        
        //get sentence
        getSentence(words: _argumentType.words, doc: _doc, isChinese: query.isChinese, withMore: _argumentType.isMore)

        //play voice
        if _argumentType.isVoice, isAvaliableOS() {
            spinner.info(text: "Fetching Voice....")
            playVoice(url: query.voiceURL)
        }
        spinner.succeed(text: "Finish")
    }
    
    public func parseArguments(_ arguments: [String]) -> ArgumentType {
        var words = [String]()
        var isMore = false
        var isVoice = false
        var args = arguments
        args.reverse()
        _ = args.popLast()
        while let arg = args.popLast() {
            if arg == "-v" { isVoice = true; continue }
            if arg == "-m" { isMore = true; continue }
            words.append(arg)
        }
        return (words: words, isVoice: isVoice, isMore: isMore)
    }

    
    //MARK: - Internal Method
    
    internal func playVoice(url: URL) {
        let fileName = "tmp"
        var path = ""
        var file: File!
        
        defer {
            try? file.delete()
        }
        
        do {
            file = try Folder.current.createFile(named: fileName)
            let data = try Data(contentsOf: url)
            try file.write(data: data)
            path = file.path
            
        } catch {
            fatalError("Error playing voice: \(error.localizedDescription)")
        }
        shell("mpg123", path)
    }
    
    internal func displayUsage() {
        print("Usage:".blue)
        print("YoudaoCLI <word(s) to query>        Query the word(s)".blue)
        print("YoudaoCLI <word(s) to query> -v     Query with speech".blue)
        print("YoudaoCLI <word(s) to query> -m     Query with more example sentences".blue)
    }
    

    internal func processBasicQuery(doc: HTMLDocument, isChinese: Bool, isMulti: Bool, query: String) {
        if isChinese {
            let chnDoc = doc.css(".trans-container > ul > p")
            print("")
            for l in chnDoc {
                var meanings = [String]()
                for j in l.css(".contentTitle > .search-js") {
                    if let _text = j.text {
                        meanings.append(_text)
                    }
                }
                let title = l.css(".contentTitle")
                title.forEach { l.removeChild($0) }
                print("    \(l.text!.trimmSpace().blue) \(meanings.joined(separator: ";").trimmSpace().yellow)")
            }
            print("")
        } else {
            if getHint(doc: doc,query: query) {
                return
            }
            if !isMulti {
                print("")
                //get pronounce
                let pronounceDoc = doc.css("div.baav > span.pronounce")
                for (i, n) in pronounceDoc.enumerated()  {
                    let p = n.css("span.phonetic").first
                    if let text = p?.text {
                        if i == 0 {
                            printNoNewLine(str: "     英: ".lightYellow.bold)
                            printNoNewLine(str: "\(text)    ".blue)
                        } else if i == 1 {
                            printNoNewLine(str: "美: ".blue.bold)
                            printNoNewLine(str: "\(text)".blue)
                        }
                    }
                }
            }
            print("")
            //get mean
            let mean = doc.css("div#phrsListTab > div.trans-container > ul")
            for link in mean {
                print((link.text?.blue)!)
            }
        }

    }
    
    internal func getSentence(words: [String], doc: HTMLDocument, isChinese: Bool, withMore: Bool) {
        let moreURLString = "http://dict.youdao.com/example/blng/eng/" + words.joined(separator: "_").urlEncode()
        let url = URL(string: moreURLString)!
        do {
            let moreDoc = try HTML(url: url, encoding: .utf8)
            let sentences = moreDoc.css("div#bilingual > ul > li")
            var count = 1
            print("")
            for s in sentences {
                for (i,p) in s.css("p").enumerated() {
                    if i == 0 {
                        print("  \(String(count).green). \(p.text!.trimmSpace().green)")
                    }
                    if i == 1 {
                        print("     " + p.text!.trimmSpace().blue)
                        count += 1
                    }
                    print("")
                    if count == 4, !withMore {
                        return
                    }
                }
            }
        } catch {
            print(error.localizedDescription)
        }
        
    }
    internal func getHint(doc: HTMLDocument, query: String) -> Bool {
        let typos = doc.css(".typo-rel")
        if typos.count == 0 {
            return false
        }
        print("")
        print("     word(s) '\(query)' not found, do you mean?".blue)
        print("")
        for l in typos {
            let word = l.css("a").first
            if let _word = word, let text = _word.text {
                print("     \(text)".green)
                l.removeChild(_word)
            }
            if let desc = l.text {
                print("     \(desc.trimmSpace())".yellow)
            }
        }
        print("")
        return true
    }
}

public extension YoudaoCLISwift {
    enum Error: Swift.Error {
        case failedToCreateFile
        case invalidArgument
        
        public var localizedDescription: String {
            switch  self {
            case .failedToCreateFile:
                return "play voice failed"
            case .invalidArgument:
                return "wrong argument"
            }
        }
    }
}
