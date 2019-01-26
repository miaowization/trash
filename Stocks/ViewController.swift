//
//  ViewController.swift
//  Stocks
//
//  Created by Rafael Valiev on 26/01/2019.
//  Copyright © 2019 AigulGabi. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var companySymbolLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var priceChangeLabel: UILabel!
    @IBOutlet weak var companyPickerView: UIPickerView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.companyPickerView.dataSource = self
        self.companyPickerView.delegate = self
        
        self.activityIndicator.hidesWhenStopped = true
        self.requestQuoteUpdate()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.companies.keys.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Array(self.companies.keys)[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.requestQuoteUpdate()
    }
    
    private func requestQuote(for symbol:String){
        let url = URL(string: "https://api.iextrading.com/1.0/stock/\(symbol)/quote")!
        let dataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                error == nil,
                (response as? HTTPURLResponse)?.statusCode == 200,
                let data = data
            else {
                print("! Network error")
                return
            }
            print(String(data: data, encoding: .utf8)!)
            self.parseQuote(data:data)
        }
        dataTask.resume()
        
    }
    
    private func requestQuoteUpdate(){
        self.activityIndicator.startAnimating()
        self.companyNameLabel.text = "-"
        self.companySymbolLabel.text = "-"
        self.priceLabel.text = "-"
        self.priceChangeLabel.text = "-"
        
        
        let selectedRow = self.companyPickerView.selectedRow(inComponent: 0)
        let selectedSymbol = Array(self.companies.values)[selectedRow]
        self.requestQuote(for: selectedSymbol)
    }
    
    private func parseQuote(data:Data){
        do{
            let jsonObject = try JSONSerialization.jsonObject(with: data)

            guard
                let json = jsonObject as? [String : Any],
                let companyName = json["companyName"] as? String,
                let companySymbol = json["symbol"] as? String,
                let price = json["latestPrice"] as? Double,
                let priceChange = json["change"] as? Double
            else {
                print("! Invalid JSON format")
                return
            }
            DispatchQueue.main.async {
                self.displayStockInfo(companyName: companyName, symbol:companySymbol,
                                      price:price, priceChange:priceChange)
            }
        }
        catch {
            print("! JSON parsing error: " + error.localizedDescription)
        }
    }
    
    private func displayStockInfo(companyName: String, symbol: String, price: Double, priceChange:Double){
        self.activityIndicator.stopAnimating()
        self.companyNameLabel.text = companyName
        self.companySymbolLabel.text = symbol
        self.priceLabel.text = "\(price)"
        self.priceChangeLabel.text = "\(priceChange)"
    }
    
    private let companies: [String:String] = [
        "Apple" : "AAPL",
        "Microsoft":"MSFT",
        "Google":"GOOG",
        "Amazon":"AMZN",
        "Facebook":"FB"]
    

    
}

