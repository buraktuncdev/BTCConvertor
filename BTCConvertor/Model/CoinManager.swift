

import Foundation

protocol CoinManagerDelegate {
    func didUpdateCoins(_ coinManager: CoinManager, coin: Coin)
    
    func didFailWithError(error: Error)
}

struct CoinManager {
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "<API_KEY>"
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]

    var delegate: CoinManagerDelegate?
    
    func getCoinPrice(for currency: String){
        let urlString = "\(baseURL)/\(currency)?apikey=\(apiKey)"
        performRequest(with: urlString)
    }
    
    
    func performRequest(with urlString:String){
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error:error!)
                    return
                }
                
                if let safeData = data {
                    if let coin = self.parseJSON(safeData) {
                        self.delegate?.didUpdateCoins(self, coin: coin)
                    }
                }
            }
            task.resume()
        }
    }
    
    
    func parseJSON(_ coinData: Data) -> Coin? {
        let decoder = JSONDecoder()
        
        do {
            let decodedData = try decoder.decode(CoinModel.self, from: coinData)
            let currencyCalculated = decodedData.asset_id_quote
            let btc = decodedData.asset_id_base
            let rate = decodedData.rate
            
            let coin = Coin(base: btc, target: currencyCalculated, rate: rate)
            return coin
            
        } catch{
            print("Decode error \(error)")
            delegate?.didFailWithError(error: error)
            return nil
        }
        
    }
    
}
