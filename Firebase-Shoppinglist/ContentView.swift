//
//  ContentView.swift
//  Firebase-Shoppinglist
//
//  Created by David Svensson on 2023-01-03.
//

import SwiftUI
import Firebase
import FirebaseAuth

// 1. förbättra strukturen genom att lägga över shoppinglistan ( items)
// i ett observable object

// 2. användaren kan välja att skapa ett konto i en instälnings sida.
//

struct ContentView: View {
    
    @State var signedIn = false
    
    var body: some View {
        if !signedIn {
            SigningInView(signedIn: $signedIn)
        } else   {
            ShoppinListView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct SigningInView: View {
    @Binding var signedIn : Bool
    
    var body: some View {
        Text("Not working signing in")
            .onAppear(){
                Auth.auth().signInAnonymously { authResult, error in
                    if let error = error {
                        print("error signing in \(error)")
                        
                    } else {
                        print("Signed in \(Auth.auth().currentUser?.uid)")
                        signedIn = true
                    }
                }
            }
    }
}

struct ShoppinListView: View {
    let db = Firestore.firestore()
    
    @State var items = [Item]()
    
    var body: some View {
        VStack {
            List {
                ForEach(items) { item in
                    ItemRowView(item: item)
                }.onDelete() { indexSet in
                    for index in indexSet {
                        let item = items[index]
                        if let id = item.id,
                           let user = Auth.auth().currentUser
                        {
                            db.collection("users").document(user.uid).collection("items").document(id).delete()
                        }
                    }
                }
            }
        }.onAppear() {
            //  saveToFirestore(itemName: "pepsi")
            listenToFirestore()
        }
        .padding()
    }
    
    func saveToFirestore(itemName: String) {
        let item = Item(name: itemName)
        guard let user = Auth.auth().currentUser else {return}
        
        do {
            _ = try db.collection("users").document(user.uid).collection("items").addDocument(from: item)
        } catch {
            print("Error saving to DB")
        }
    }
    
    func listenToFirestore() {
        
        guard let user = Auth.auth().currentUser else {return}
        
        db.collection("users").document(user.uid).collection("items").addSnapshotListener { snapshot, err in
            guard let snapshot = snapshot else {return}
            
            if let err = err {
                print("Error getting document \(err)")
            } else {
                items.removeAll()
                for document in snapshot.documents {

                    let result = Result {
                        try document.data(as: Item.self)
                    }
                    switch result  {
                    case .success(let item)  :
                        items.append(item)
                    case .failure(let error) :
                        print("Error decoding item: \(error)")
                    }
                }
            }
        }
    }
    
    
}

struct ItemRowView: View {
    let db = Firestore.firestore()
    
    let item : Item
    
    var body: some View {
        HStack {
            Text(item.name)
            Spacer()
            Button(action: {
                if let id = item.id,
                   let user = Auth.auth().currentUser
                {
                    db.collection("users").document(user.uid)
                        .collection("items").document(id).updateData(["done": !item.done])
                }
            }) {
                Image(systemName: item.done ? "checkmark.square" : "square")
            }
        }
    }
}
