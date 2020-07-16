

import Foundation


struct CoinModel:Codable {
    var time: String
    var asset_id_base: String
    var asset_id_quote: String
    var rate: Double
}

struct Coin {
    let base: String
    let target: String
    let rate: Double
}
