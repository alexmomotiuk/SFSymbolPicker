import SwiftUI

public struct SFSymbolsPicker: View {
    
    public static var isAvailable: Bool {
        SymbolLoader.isAvailable
    }
    
    @Binding public var selection: String
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var search = ""
    @State private var allSymbols = [SFSymbolInfo]()
    @State private var visibleSymbols = [SFSymbolInfo]()
    
    private let topSymbols: [String]
    
    public init(
        topSymbols: [String] = Self.DefaultTopSymbols,
        selection: Binding<String>
    ) {
        self.topSymbols = topSymbols
        self._selection = selection
    }
    
    public var body: some View {
        ScrollView {
            LazyVGrid(
                columns: [
                    GridItem(.adaptive(minimum: 40, maximum: 60), spacing: 8)
                ],
                spacing: 8
            ) {
                ForEach(visibleSymbols) { symbol in
                    let isSelected = selection == symbol.name
                    Image(systemName: symbol.name)
                        .foregroundStyle(isSelected ? Color.white : Color(uiColor: .label).opacity(0.9))
                        .fontDesign(.rounded)
                        .font(.system(size: 22))
                        .frame(width: 48, height: 48)
                        .background {
                            if isSelected {
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(.tint.opacity(0.9))
                            } else {
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(Color(uiColor: .secondarySystemBackground))
                            }
                        }
                        .onTapGesture {
                            selection = symbol.name
                            dismiss()
                        }
                }
            }
            .padding()
            .searchable(text: $search)
        }
        .scrollContentBackground(.hidden)
        .task {
            allSymbols = await SymbolLoader.getAllSymbols().sorted { symbol1, symbol2 in
                topSymbols.contains(symbol1.name) && !topSymbols.contains(symbol2.name)
            }
            visibleSymbols = allSymbols
        }
        .onChange(of: search) { _, _ in
            performSearch()
        }
    }
    
    func performSearch() {
        let trimmedQuery = search.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if trimmedQuery.isEmpty {
            visibleSymbols = allSymbols
        } else {
            visibleSymbols = searchSymbols(query: trimmedQuery, symbols: allSymbols)
        }
    }
    
    private func searchSymbols(query: String, symbols: [SFSymbolInfo]) -> [SFSymbolInfo] {
        let lowercasedQuery = query.lowercased()
        
        return symbols
            .map { symbol in
                let score = matchScore(query: lowercasedQuery, symbol: symbol)
                return (symbol, score)
            }
            .filter { $0.1 > 0 } // Remove non-matching results
            .sorted { $0.1 > $1.1 } // Sort by match score (higher is better)
            .map { $0.0 } // Extract symbol info
    }
    
    private func matchScore(query: String, symbol: SFSymbolInfo) -> Int {
        let lowercasedName = symbol.name.lowercased()
        let lowercasedTokens = symbol.searchTokens.map { $0.lowercased() }
        
        var score = 0
        
        // Exact name match (highest priority)
        if lowercasedName.contains(query) {
            score += 100
        }
        
        // Token match
        for token in lowercasedTokens {
            if token.contains(query) {
                score += 50
            }
        }
        
        // Fuzzy matching (split words and check partials)
        let queryWords = Set(query.split(separator: " "))
        let tokenWords = Set(lowercasedTokens.flatMap { $0.split(separator: " ") })
        
        let commonWords = queryWords.intersection(tokenWords)
        score += commonWords.count * 30
        
        return score
    }
    
    public static let DefaultTopSymbols = [
        "eraser.fill",
        "trash.fill",
        "folder.fill",
        "tray.fill",
        "tray.2.fill",
        "externaldrive.fill",
        "archivebox",
        "archivebox.fill",
        "xmark.bin.fill",
        "document.on.clipboard",
        "heart.text.clipboard.fill",
        "calendar",
        "books.vertical.fill",
        "book.closed.fill",
        "character.book.closed.fill",
        "magazine.fill",
        "bookmark.fill",
        "graduationcap.fill",
        "backpack.fill",
        "link",
        "person.fill",
        "lanyardcard.fill",
        "person.crop.square.on.square.angled",
        "person.crop.rectangle.stack.fill",
        "figure.stand.dress",
        "figure.arms.open",
        "oar.2.crossed",
        "dumbbell.fill",
        "soccerball.inverse",
        "baseball.fill",
        "basketball.fill",
        "american.football.fill",
        "american.football.professional.fill",
        "tennis.racket",
        "tennisball.fill",
        "volleyball.fill",
        "skateboard",
        "snowboard.fill",
        "trophy.fill",
        "keyboard.fill",
        "sun.max.fill",
        "moon.fill",
        "moon.circle.fill",
        "cloud.fill",
        "cloud.circle.fill",
        "cloud.moon.fill",
        "wind.snow",
        "snowflake",
        "tornado.circle.fill",
        "thermometer.variable",
        "thermometer.medium",
        "fire.extinguisher.fill",
        "beach.umbrella.fill",
        "umbrella",
        "microphone.fill",
        "shield.lefthalf.filled",
        "flag.pattern.checkered",
        "bell.fill",
        "tag.fill",
        "camera.fill",
        "message.fill",
        "checkmark.message.fill",
        "ellipsis.message.fill",
        "bubble.right.fill",
        "exclamationmark.bubble.fill",
        "quote.closing",
        "translate",
        "phone.fill",
        "video.fill",
        "envelope.front.fill",
        "envelope.fill",
        "bag.fill",
        "basket",
        "creditcard",
        "creditcard.fill",
        "wallet.pass",
        "wallet.pass.fill",
        "wallet.bifold",
        "wallet.bifold.fill",
        "dice.fill",
        "die.face.5.fill",
        "pianokeys.inverse",
        "paintbrush.fill",
        "paintbrush.pointed.fill",
        "wrench.adjustable.fill",
        "hammer.fill",
        "screwdriver.fill",
        "wrench.and.screwdriver.fill",
        "scroll.fill",
        "printer",
        "printer.fill",
        "handbag.fill",
        "latch.2.case.fill",
        "cross.case.fill",
        "suitcase.fill",
        "suitcase.rolling.fill",
        "puzzlepiece.fill",
        "lightbulb.fill",
        "fan.fill",
        "lamp.desk.fill",
        "lamp.floor.fill",
        "chair.lounge.fill",
        "fireplace.fill",
        "stove.fill",
        "robotic.vacuum.fill",
        "toilet.fill",
        "tent",
        "signpost.right.fill",
        "lock",
        "lock.fill",
        "pin.fill",
        "sensor.tag.radiowaves.forward.fill",
        "watch.analog",
        "headphones",
        "radio.fill",
        "airplane",
        "car",
        "car.rear",
        "bus.fill",
        "tram",
        "sailboat",
        "sailboat.fill",
        "truck.box.fill",
        "bicycle",
        "moped.fill",
        "fuelpump.fill",
        "key.card.fill",
        "horn.fill",
        "lungs.fill",
        "facemask.fill",
        "pill.fill",
        "pills.fill",
        "tortoise.fill",
        "dog.fill",
        "cat.fill",
        "bird.fill",
        "ant.fill",
        "ladybug.fill",
        "fish.fill",
        "pawprint.fill",
        "teddybear.fill",
        "tree.fill",
        "crown.fill",
        "hat.widebrim.fill",
        "hat.cap.fill",
        "tshirt.fill",
        "jacket",
        "jacket.fill",
        "shoe.fill",
        "shoe.2",
        "face.smiling.inverse",
        "eyes.inverse",
        "comb.fill",
        "sunglasses.fill",
        "hearingdevice.ear.fill",
        "hand.raised.fingers.spread.fill",
        "hands.clap.fill",
        "shippingbox.fill",
        "deskclock.fill",
        "alarm.fill",
        "gamecontroller.fill",
        "paintpalette",
        "swatchpalette.fill",
        "cup.and.saucer.fill",
        "cup.and.heat.waves.fill",
        "mug.fill",
        "takeoutbag.and.cup.and.straw.fill",
        "wineglass.fill",
        "birthday.cake",
        "birthday.cake.fill",
        "carrot.fill",
        "fork.knife",
        "waveform.circle.fill",
        "simcard.fill",
        "scalemass.fill",
        "fossil.shell.fill",
        "gift.fill",
        "hourglass",
        "binoculars.fill",
        "battery.75percent",
        "exclamationmark.shield.fill"
    ]
}

#Preview {
    @Previewable @State var selection: String = ""
    NavigationStack {
        SFSymbolsPicker(selection: $selection)
            .tint(Color.blue)
    }
}
