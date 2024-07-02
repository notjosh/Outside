import Foundation
import RegexBuilder

// extract the JSON config out of the HTML of an embedded player page (i.e. https://player.vimeo.com/video/xxxxxxx?h=yyyyyyy)
struct VimeoConfigExtractor {
    let html: String
    
    var json: Substring? {
        let jsonRef = Reference<Substring>()

        let pattern = Regex {
            // start
            // matches things like:
            //  - `config =`
            //  - `window.playerConfig =`
            //
            // aka: /\b(?:playerC|c)onfig\s*=/.wordBoundaryKind(.simple)
            Regex {
                Anchor.wordBoundary
                ChoiceOf {
                    Regex {
                        "playerC"
                    }
                    "c"
                }
                "onfig"
                ZeroOrMore(CharacterClass.whitespace)
                "="
            }
            .wordBoundaryKind(.simple)

            ZeroOrMore(CharacterClass.whitespace)
            
            // JSON contents
            Capture(as: jsonRef) {
                "{"
                ZeroOrMore(CharacterClass.any)
                "}"
            }
            ZeroOrMore(CharacterClass.whitespace)
            
            // end
            ZeroOrMore(CharacterClass.any)
        }

        return html.firstMatch(of: pattern)?[jsonRef]
    }
}
