//
//  WalletViewModel.swift
//  IOSBdkAppSample
//
//  Created by Sudarsan Balaji on 29/10/21.
//

import Foundation
import BitcoinDevKit

extension TransactionDetails: Comparable {
    public static func < (lhs: TransactionDetails, rhs: TransactionDetails) -> Bool {
        
        let lhs_timestamp: UInt64 = lhs.confirmationTime?.timestamp ?? UInt64.max;
        let rhs_timestamp: UInt64 = rhs.confirmationTime?.timestamp ?? UInt64.max;
        
        return lhs_timestamp < rhs_timestamp
    }
}

extension TransactionDetails: Equatable {
    public static func == (lhs: TransactionDetails, rhs: TransactionDetails) -> Bool {
        
        let lhs_timestamp: UInt64 = lhs.confirmationTime?.timestamp ?? UInt64.max;
        let rhs_timestamp: UInt64 = rhs.confirmationTime?.timestamp ?? UInt64.max;
        
        return lhs_timestamp == rhs_timestamp
    }
}

class WalletViewModel: ObservableObject {
    internal init(key: String = "private_key", state: WalletViewModel.State = State.empty, syncState: WalletViewModel.SyncState = SyncState.empty, balance: UInt64 = 0, balanceText: String = "sync plz", lastSend: String = "", lastFee: String = "", transactions: [TransactionDetails] = [], words: String = "clutch solar sand travel vital fitness hand piece dial flag garment grant") {
        self.key = key
        self.state = state
        self.syncState = syncState
        self.balance = balance
        self.balanceText = balanceText
        self.lastSend = lastSend
        self.lastFee = lastFee
        self.transactions = transactions
        self.words = words
    }
        
    enum State {
        case empty
        case loading
        case failed(Error)
        case loaded(Wallet, Blockchain)
    }
    
    enum SyncState {
        case empty
        case syncing
        case synced
        case failed(Error)
    }
    
    private(set) var key = "private_key"
    @Published private(set) var state = State.empty
    @Published private(set) var syncState = SyncState.empty
    @Published private(set) var balance: UInt64 = 0
    @Published public var balanceText = "sync plz"
    @Published public var lastSend = ""
    @Published public var lastFee = ""
    @Published private(set) var transactions: [BitcoinDevKit.TransactionDetails] = []
    // this initial mnemonics in example couse CRC error
    @Published public var words: String = "clutch solar sand travel vital fitness hand piece dial flag garment grant"
    
    func load() {
        state = .loading
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            let db = DatabaseConfig.memory
            do {
                if self.words.isEmpty {
                    let genKey = Mnemonic.init(wordCount: WordCount.words12);
                    self.words = genKey.asString();
                    self.balanceText = "New Wallet"
                    debugPrint(self.words)
                }
                let mn = try Mnemonic.fromString(mnemonic: self.words)
                debugPrint(mn.asString())
                let deK =  DescriptorSecretKey(network: Network.testnet, mnemonic: mn, password: "")
                debugPrint(deK.asString())
                let descriptor = Descriptor.newBip44(secretKey: deK, keychain: .external, network:  Network.testnet)
                debugPrint(descriptor.asString())
                let electrum = ElectrumConfig(url: "ssl://electrum.blockstream.info:60002", socks5: nil, retry: 5, timeout: nil, stopGap: 10, validateDomain: true)
                let blockchainConfig = BlockchainConfig.electrum(config: electrum)
                let blockchain = try Blockchain(config: blockchainConfig)
                let wallet = try Wallet(descriptor: descriptor, changeDescriptor: nil, network: Network.testnet, databaseConfig: db)
                
                DispatchQueue.main.async {
                    self.state = State.loaded(wallet, blockchain)
                }
            } catch {
                do {
                    // Old Example Wallet restoring by Descriptor
                    let descriptor = try Descriptor.init(descriptor: "wpkh(tprv8ZgxMBicQKsPeSitUfdxhsVaf4BXAASVAbHypn2jnPcjmQZvqZYkeqx7EHQTWvdubTSDa5ben7zHC7sUsx4d8tbTvWdUtHzR8uhHg2CW7MT/*)", network: Network.testnet)
                    let electrum = ElectrumConfig(url: "ssl://electrum.blockstream.info:60002", socks5: nil, retry: 5, timeout: nil, stopGap: 10, validateDomain: true)
                    let blockchainConfig = BlockchainConfig.electrum(config: electrum)
                    let blockchain = try Blockchain(config: blockchainConfig)
                    let wallet = try Wallet(descriptor: descriptor, changeDescriptor: nil, network: Network.testnet, databaseConfig: db)
                    DispatchQueue.main.async {
                        self.balanceText = "Wallet reset to example"
                        self.state = State.loaded(wallet, blockchain)
                    }
                } catch let error {
                    DispatchQueue.main.async {
                        self.balanceText = "Fatal:" + error.localizedDescription
                        self.state = State.failed(error)
                    }
                }
            }
        }
    }
    
    func estimateFee (_ to: String, amount: UInt64) -> UInt64? {
        switch self.state {
        case .loaded(let wallet, let blockchain):
            do {
                //let rate = try blockchain.estimateFee(target: target).asSatPerVb()
                let address = try Address(address: to)
                let script = address.scriptPubkey()
                let txBuilder = TxBuilder().addRecipient(script: script, amount: UInt64(amount))
                let details = try txBuilder.finish(wallet: wallet)
                return details.psbt.feeAmount()
            } catch {
                return nil
            }
        default: break
        }
        return nil
    }
    
    func generateNewMnemonic () -> String{
        let genKey = Mnemonic.init(wordCount: WordCount.words12);
        return genKey.asString();
    }
    
    func newWalletConnection(_ words : String) {
        self.words = words
        newWalletConnection()
    }
    
    func newWalletConnection() {
        self.balance = 0
        self.balanceText = "sync plz"
        self.lastSend = ""
    }
    
    func sync() {
        self.balanceText = "syncing"
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }

            switch self.state {
            case .loaded(let wallet, let blockchain):
                DispatchQueue.main.async {
                    self.syncState = .syncing
                }
                do {
                    // TODO use this progress update to show "syncing"
                    try wallet.sync(blockchain: blockchain, progress: nil)
                    let balance = try wallet.getBalance().confirmed
                    let wallet_transactions: [TransactionDetails] = try wallet.listTransactions(includeRaw: false)

                    DispatchQueue.main.async {
                        self.syncState = .synced
                        self.balance = balance
                        self.balanceText = String(format: "%.8f", Double(self.balance) / Double(100000000))
                        self.transactions = wallet_transactions.sorted().reversed()
                    }
              } catch let error {
                  print(error)
                  DispatchQueue.main.async {
                      self.syncState = .failed(error)
                  }
              }
            default: do { }
                debugPrint("default")
            }
        }
    }
}
