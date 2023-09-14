//
//  SettingsView.swift
//  MyFirstApp
//
//  Created by Paul Miller on 11/4/21.
//

import SwiftUI

struct SettingsView: View {
    @State private var goToWords = false
    @State private var goToRecovery = false
    
    var body: some View {
            NavigationLink(destination: MnemonicView(), isActive: $goToWords) { EmptyView() }
            NavigationLink(destination: RecoverView(), isActive: $goToRecovery) { EmptyView() }
        BackgroundWrapper {
            Spacer()
            Text("Running on Bitcoin Testnet").textStyle(BasicTextStyle(white: true, bold: true))
            Spacer()
            BasicButton(action: { goToWords = true }, text: "Create a New Wallet")
            BasicButton(action: { goToRecovery = true}, text: "Recover Existing Wallet")
        }
        .navigationTitle("Wallet Setup")
        .modifier(BackButtonMod())
 
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
