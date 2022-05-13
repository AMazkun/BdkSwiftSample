//
//  SendReceiveButtons.swift
//  MyFirstApp
//
//  Created by Paul Miller on 11/5/21.
//

import SwiftUI
import BitcoinDevKit

struct SendReceiveButtons: View {
    var wallet: Wallet
    var blockchain: Blockchain
    
    func getWidth(w: CGFloat) -> CGFloat {
        return (w - 10.0) / 2.0
    }
    
    
    @State private var goToSend = false
    @State private var goToReceive = false
    
    var body: some View {
        // Invisible link to receive
        NavigationLink(destination: ReceiveView(), isActive: $goToReceive) { EmptyView() }
        
        // Invisible link to Send
        NavigationLink(destination: SendView(onSend: { recipient, amount in
            do {
                let txBuilder = TxBuilder().addRecipient(address: recipient, amount: amount)
                let psbt = try txBuilder.finish(wallet: wallet)
                try wallet.sign(psbt: psbt)
                try blockchain.broadcast(psbt: psbt)
                let txid = psbt.txid()
                print(txid)
            } catch let error {
                print(error)
            }
        }), isActive: $goToSend) { EmptyView() }
        GeometryReader { geometry in
            HStack(spacing: 10) {
                let w = getWidth(w: geometry.size.width)
                Button(action: { goToReceive = true }) {
                    Text("receive")
                        .font(.system(size: 14, design: .monospaced))
                        .fontWeight(.bold)
                        .foregroundColor(Color("Shadow"))
                        .frame(width: w, height: w)
                        .background(Color("Green"))
                        .cornerRadius(10.0)
                        .shadow(color: Color("Shadow"), radius: 1, x: 5, y: 5)
                }
                Button(action: { goToSend = true }) {
                    Text("send")
                        .font(.system(size: 14, design: .monospaced))
                        .fontWeight(.bold)
                        .foregroundColor(Color("Shadow"))
                        .frame(width: w, height: w)
                        .background(Color("Red"))
                        .cornerRadius(10.0)
                        .shadow(color: Color("Shadow"), radius: 1, x: 5, y: 5)
                }
            }
        }
    }
}

struct SendReceiveButtons_Previews: PreviewProvider {
    static var previews: some View {
//        SendReceiveButtons()
        Text("Hello")
    }
}
