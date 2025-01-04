import CMUDict

@main
struct Main {
    static func singabilityDescription(_ phrase: String) -> String {
        let pronunciations = phrase.components(separatedBy: .letters.inverted).compactMap { Pronunciation(word: $0) }
        let stressPattern = StressPattern(elements: pronunciations.flatMap { $0.stressPattern.elements })
        return "\(stressPattern)"
    }
    static func main() async throws {
        let phrases = [
            "teenage mutant ninja turtles",
            "common wordplay indicator",
            "first time dyson air wrap users",
            "call yourself a people pleaser",
            "gender non conforming parent",
            "dirty diet doctor pepper",
            "in-house caesar salad dressing",
            "cozy skillet dinner season",
            "perfect new york politician",
            "english is my second language",
            "peel off that adhesive backing",
            "decimate your top performers",
            "age-old bumper sticker question",
            "very grumpy climate kitty",
            "this is how my cat is sitting",
            "I just ate the Wednesday whopper",
            "un-ironic white nerd anthem",
            "bold, autumnal aspen yellow",
            "poop too long and take my nuggets",
            "very good pronunciation"
        ]
        for phrase in phrases {
            if !phrase.isSingable {
                print("\(phrase) is not singable")
            }
        }
    }
}

enum StressPatternElement: String, Equatable, CustomStringConvertible {
    case any
    case stressed
    case unstressed
    
    func matches(_ element: StressPatternElement) -> Bool {
        if self == .any || element == .any {
            return true
        }
        return self == element
    }
    
    var description: String {
        rawValue
    }
}

extension StressPatternElement {
    init(_ stress: Stress) {
        switch stress {
        case .primary, .secondary: self = .stressed
        case .unstressed: self = .unstressed
        }
    }
}

struct StressPattern {
    static let tmnt = StressPattern(elements: [.stressed, .unstressed, .stressed, .unstressed, .stressed, .unstressed, .stressed, .unstressed])
    var elements: [StressPatternElement]
    
    init(elements: [StressPatternElement]) {
        self.elements = elements
    }
    
    mutating func consumeIfFrontMatches(_ pattern: StressPattern) -> Bool {
        if pattern.elements.count > elements.count {
            return false
        }
        if zip(pattern.elements, elements).allSatisfy({ $0.matches($1) }) {
            elements.removeFirst(pattern.elements.count)
            return true
        }
        return false
    }
    
    func matches(_ pattern: StressPattern) -> Bool {
        if pattern.elements.count != elements.count {
            return false
        }
        return zip(pattern.elements, elements).allSatisfy { $0.matches($1) }
    }
}

extension Pronunciation {
    var stressPattern: StressPattern {
        let syllables = Array(syllables)
        if syllables.count == 1 {
            return StressPattern(elements: [.any])
        }
        var elements = [StressPatternElement]()
        for syllable in syllables {
            let syllableStress = syllable.stress
            var stress = StressPatternElement(syllableStress)
            guard let last = elements.last else {
                elements.append(stress)
                continue
            }
            
            // Special case, for words like "turtle" and "indicator" -- if we have a secondary stress
            // immediately following a stressed vowel, treat it as either.
            if syllableStress == .secondary && last.matches(.stressed) {
                stress = .any
            }
            
            elements.append(stress)
        }
        return StressPattern(elements: elements)
    }
}

extension String {
    var isSingable: Bool {
        var pattern = StressPattern.tmnt
        for word in self.components(separatedBy: .letters.inverted) {
            if word.isEmpty { continue }
            var matched = false
            for pronunciation in Pronunciation.pronunciations(for: word) {
                if pattern.consumeIfFrontMatches(pronunciation.stressPattern) {
                    matched = true
                    break
                }
            }
            if !matched {
                return false
            }
        }
        return pattern.elements.isEmpty
    }
}
