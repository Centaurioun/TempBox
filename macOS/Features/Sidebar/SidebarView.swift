//
//  SidebarView.swift
//  TempBox (macOS)
//
//  Created by Waseem Akram on 16/09/21.
//

import SwiftUI

let placeholderAddresses = [
    "something1@example.com",
    "something2@example.com",
    "something3@example.com"
]

let placeholderArchivedAddresses = [
    "something4@example.com",
    "something5@example.com",
    "something6@example.com"
]

struct SidebarView: View {
    
    @EnvironmentObject var appController: AppController
    
    var body: some View {
        
        VStack(alignment: .leading) {
            AddAccountView()
                .padding()
            List(selection: $appController.selectedAccount) {
                Section(header: Text("Active Accounts")) {
                    
                    ForEach(appController.activeAccounts, id: \.self) { account in
                        AddressItemView(account: account)
                            .tag(account)
                    }
                }
                
                Section(header: Text("Archived Accounts")) {
                    
                    ForEach(appController.archivedAccounts, id: \.self) { account in
                        AddressItemView(account: account)
                            .tag(account)
                    }
                }
            }
            .listStyle(SidebarListStyle())
            Spacer()
            
            if let selectedAccount = appController.selectedAccount {
                QuotaView(value: selectedAccount.quotaUsed, total: selectedAccount.quotaLimit)
                    .padding()
            }
            Divider()
            
            footer
        }
        .padding(.top)
        .toolbar {
            ToolbarItem(placement: ToolbarItemPlacement.automatic) {
                Button(action: toggleSidebar) {
                    Label("Back", systemImage: "sidebar.squares.left")
                }
                .help("Toggle sidebar")
            }
            
        }
        
    }
    
    var footer: some View {
        HStack(alignment: .center) {
            Spacer()
            Text("Powered by Mail.tm")
                .padding()
            Spacer()
        }
    }
}

func toggleSidebar() {
    NSApp.keyWindow?
        .firstResponder?
        .tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
}

struct AddressItemView: View {
    
    @EnvironmentObject var appController: AppController
    var account: Account
    
    @State var showConfirmationForRemove = false
    @State var showConfirmationForDelete = false
    
    var body: some View {
        HStack {
            Label(account.address, systemImage: "tray")
            Spacer()
            if !account.isArchived {
                BadgeView(model: .init(title: "1", color: .secondary.opacity(0.5)))
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 3)
        .contextMenu(menuItems: {
            
            Menu("Copy") {
                Button(action: {}, label: {
                    Label("Address: \(account.address)", systemImage: "tray")
                })
                Button(action: {}, label: {
                    Label("Password", systemImage: "tray")
                })
            }
            Divider()
            Button(action: {
                if account.isArchived {
                    appController.activateAccount(account: account)
                } else {
                    appController.archiveAccount(account: account)
                }
            }, label: {
                Label(archiveActivateButtonText, systemImage: "tray")
            })
            Button(action: {
                showConfirmationForRemove = true
            }, label: {
                Label("Remove", systemImage: "tray")
            })
            
            Button(action: {
                showConfirmationForDelete = true
            }, label: {
                Label("Delete", systemImage: "tray")
            })
        })
        .background(
            EmptyView()
                .alert(isPresented: $showConfirmationForRemove) {
                Alert(title: Text("Remove \(account.address) from TempBox"),
                      message: Text("""
                        This action will only remove your account from TempBox.
                        You can still access the account using the email address and password on mail.tm. \n
                        NOTE: Make sure you save a copy of email address and password before removing the account!
    """),
                      primaryButton: .destructive(Text("Remove"), action: { appController.removeAccount(account: account) }),
                      secondaryButton: .default(Text("Cancel")))
            }
        )
        .background(
            EmptyView()
                .alert(isPresented: $showConfirmationForDelete) {
                    Alert(title: Text("Delete \(account.address) from TempBox"),
                          message: Text("This action will delete your account permanently."),
                          primaryButton: .destructive(Text("Delete"), action: { appController.deleteAccount(account: account) }),
                          secondaryButton: .default(Text("Cancel")))
                }
        )
    }
}

extension AddressItemView {
    
    var archiveActivateButtonText: String {
        account.isArchived ? "Activate" : "Archive"
    }
}

struct SidebarView_Previews: PreviewProvider {
    static var previews: some View {
        SidebarView()
            .previewLayout(.fixed(width: 500, height: 800))
    }
}
