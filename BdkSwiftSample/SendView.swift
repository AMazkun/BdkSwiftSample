//
//  SendView.swift
//  IOSBdkAppSample
//
//  Created by Sudarsan Balaji on 02/11/21.
//

import SwiftUI
import Combine
import CodeScanner
import BitcoinDevKit

struct SendView: View {
    @State var to: String = ""
    @State var amount: String = "0"
    @State var fee: String = "na"
    @State var balanceAfter: String = "na"
    @State private var isShowingScanner = false
    
    @EnvironmentObject var viewModel: WalletViewModel
    @Environment(\.presentationMode) var presentationMode
    func handleScan(result: Result<String, CodeScannerView.ScanError>) {
       self.isShowingScanner = false
        switch result {
        case .success(let code):
            self.to = code
        case .failure(let error):
            print(error)
        }
    }
    let formatter: NumberFormatter = {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            return formatter
        }()
    var onSend : (String, UInt64) -> [String]
    
    var body: some View {
        BackgroundWrapper {
            VStack {
                Form {
                    Section(header: Text("Recipient").textStyle(BasicTextStyle(white: true))) {
                        TextField("Address", text: Binding (
                            // validate address
                            get: {to},
                            set: {
                                if $0.unicodeScalars.allSatisfy(CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789").contains) {
                                        to = $0
                                    }
                                 }
                        ))
                        .modifier(BasicTextFieldStyle())
                        
                    }
                    Section(header: Text("Amount (sats)").textStyle(BasicTextStyle(white: true))) {
                        TextField("Amount", text: Binding(
                            // validate sum
                            get:{ amount },
                            set:{ if let i = UInt64($0), i>0  {
                                amount = $0
                                if let feeUInt = viewModel.estimateFee(to, amount: UInt64(i)) {
                                    fee = String(feeUInt)
                                    balanceAfter = String(viewModel.balance - feeUInt - i)
                                } else {
                                    balanceAfter = "na"
                                    fee = "na"
                                }
                            }
                            }
                        ))
                        .modifier(BasicTextFieldStyle())
                        .keyboardType(.numberPad)
                    }
                    Section(header: Text("Fee and Balance (Aprox)").textStyle(BasicTextStyle(white: true))) {
                        Text(fee)
                        Text(balanceAfter)
                    }

                    
                }
            }
            .onAppear {
                UITableView.appearance().backgroundColor = .clear }
            
            Spacer()
            BasicButton(action: { self.isShowingScanner = true}, text: "Scan Address")
            BasicButton(action: {
                let res = onSend(to, (UInt64(amount) ?? 0))
                viewModel.lastSend = res[0]
                viewModel.lastFee = res[1]
                viewModel.sync()
                presentationMode.wrappedValue.dismiss()
            }, text: "Broadcast Transaction", color: "Red")
            // trasaction prohibited if
            .disabled(to == "" || (Double(amount) ?? 0) == 0
                      || (Int64(balanceAfter) ?? -1) < 0)
        }
        .navigationTitle("Send")
        .modifier(BackButtonMod())
        .sheet(isPresented: $isShowingScanner) {
            CodeScannerView(codeTypes: [.qr], simulatedData: "Testing1234", completion: self.handleScan)}
    }
}

struct SendView_Previews: PreviewProvider {
    static func onSend(to: String, amount: UInt64) -> [String] {
        return ["n/a", "n/a"]
    }
    static var previews: some View {
        SendView(onSend: self.onSend)
            .environmentObject(WalletViewModel())
    }
}
