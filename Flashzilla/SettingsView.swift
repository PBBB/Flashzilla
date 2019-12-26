//
//  SettingsView.swift
//  Flashzilla
//
//  Created by Issac Penn on 2019/12/26.
//  Copyright © 2019 Issac Penn. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    @Binding var reuseWrongCards: Bool
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        NavigationView {
            Form {
                Toggle(isOn: $reuseWrongCards) {
                    Text("Re-test Wrong Cards")
                }
            }
            .navigationBarTitle("Settings")
            .navigationBarItems(trailing:
                Button("Done") {
                    self.presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        let reuseWrongCards = Binding.constant(true)
        return SettingsView(reuseWrongCards: reuseWrongCards)
    }
}
