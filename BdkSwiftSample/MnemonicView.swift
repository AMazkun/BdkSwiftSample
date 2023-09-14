//
//  IntroView.swift
//  MyFirstApp
//
//  Created by Paul Miller on 11/4/21.
//

import SwiftUI

struct MnemonicView: View {
    @EnvironmentObject var viewModel: WalletViewModel
    @State private var goHome = false
    @State var words: String = "Tap here to generate new 12 Mnemonic words";
    
    var body: some View {
        BackgroundWrapper {
            Spacer()
            Text(words).textStyle(BasicTextStyle(big: true, white: true))
                .onTapGesture {
                    words = viewModel.generateNewMnemonic()
                }
            Spacer()
            NavigationLink(destination: WalletView(), isActive: $goHome) { EmptyView() }
            BasicButton(action: { () in
                UIPasteboard.general.string = words
                viewModel.newWalletConnection(words)
                goHome = true
            }, text: "Copy Mnemonic, Use New Wallet")
        }
        .navigationTitle("Mnemonic")
        .modifier(BackButtonMod())
    }
}

struct RecoveryView_Previews: PreviewProvider {
    static var viewModel = WalletViewModel()
    static var previews: some View {
        MnemonicView().environmentObject(viewModel)
    }
}
