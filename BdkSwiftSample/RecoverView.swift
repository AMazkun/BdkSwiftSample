//
//  RecoverView.swift
//  MyFirstApp
//
//  Created by Paul Miller on 11/5/21.
//

import SwiftUI
import BitcoinDevKit

struct RecoverView: View {
    @EnvironmentObject var viewModel: WalletViewModel
    @State private var goHome = false

    var body: some View {
        BackgroundWrapper {
            VStack{
                Text("Input 12 Mnemonic words below:")
                    .font(.caption)
                TextEditor(text: $viewModel.words)
                    .font(.largeTitle)
                    .disableAutocorrection(true).padding(.bottom, 10)
                    .textInputAutocapitalization(.never)

                NavigationLink(destination: WalletView(), isActive: $goHome) { EmptyView() }
                BasicButton(action: {
                    viewModel.newWalletConnection()
                    goHome = true
                }, text: "Get Restore")
                .textFieldStyle(.roundedBorder)
            }
            .textFieldStyle(.roundedBorder)
        }
        .navigationTitle("Restore Wallet with Mnemonic")
        .modifier(BackButtonMod())
    }
}

struct RecoverView_Previews: PreviewProvider {
    static var viewModel = WalletViewModel()

    static var previews: some View {
        RecoverView().environmentObject(viewModel)
    }
}
