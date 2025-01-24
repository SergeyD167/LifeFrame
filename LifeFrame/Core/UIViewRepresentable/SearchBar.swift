//
//  SearchBar.swift
//  LifeFrame
//
//  Created by Сергей Дятлов on 23.02.2024.
//

import SwiftUI

struct SearchView: View {
    @FocusState private var keyboardFocused: Bool
    @Binding var searchText: String
    @Binding var isPresented: Bool
    @Binding var inSearchMode: Bool
    
    var closeAddView: () -> ()

    var testTags : [String : Int] = ["ОченьДлиннаяИдеяПростоДляПримера" : 999999 ,"ОченьДлиннаяИдеяПросто" : 123, "한국어" : 98, "негодование" : 30, "погода" : 29, "Мурзик" : 29]
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Image(searchText.isEmpty ? UI.Icons.search : UI.Icons.search_active)
                    .padding(.leading, 16)
                    .padding(.trailing, 8)
                
                TextField("", text: $searchText, onEditingChanged: { _ in inSearchMode = true })
                    .placeholder(when: searchText.isEmpty, placeholder: { Text("Search by text...").foregroundColor(Color.theme.c4) })
                    .submitLabel(.search)
                    .foregroundColor(Color.theme.cB)
                    .font(.memoryTextBase())
                
                Button(action: {
                    withAnimation {
                        UIApplication.shared.endEditing()
                        isPresented.toggle()
                        inSearchMode = false
                    }
                    searchText = ""
                }, label: {
                    Text(UI.Strings.cancel)
                        .foregroundColor(Color.theme.c6)
                        .font(.title(17))
                        .padding(8)
                })
                .paddings(vertical: 10, horizontal: 8)
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.theme.cW)
                    .shadowFloating()
            )
            
            if searchText.isEmpty {
                VStack(spacing: 0) {
                    ScrollView {
                        Spacer(minLength: 16)
                        
                        FilterView()
                            .paddings(vertical: 11.5, horizontal: 16)
                        
                        ForEach(1...3, id: \.self) { num in
                            TagCellView(name: "какой-то тег", amount: num)
                        }
                        
                    }
                }
            }
        }
        .paddings(horizontal: 16)
        .focused($keyboardFocused)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation() {
                    keyboardFocused = true
//                    closeAddView()
                }
            }
        }
//
//            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//                withAnimation() {
////                    keyboardFocused = true
////                    closeAddView()
//                }
//            }
//        }
        .background(searchText.isEmpty ? Color.theme.cW : Color.clear)
        .ignoresSafeArea(.keyboard)

    }
}

struct FilterView: View {
    var body: some View {
        HStack(spacing: 16) {
            filterCell(name: "Медиа")
            filterCell(name: "Аудио")
            
            Spacer()
        }
    }
    
    func filterCell(name : String) -> some View {
        Button(action: {
            print("\(name)")
        }, label: {
            Text(name)
                .foregroundColor(Color.theme.c1)
                .font(.title(17))
                .paddings(vertical: 8, horizontal: 16)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.theme.c8)
                )
        })
    }
}


struct TagCellView: View {
    var name: String
    var amount: Int
    
    var body: some View {
        HStack() {
            VStack(alignment: .leading) {
                Text("#\(name)")
                    .lineLimit(1)
                    .minimumScaleFactor(1.0)
                    .font(.memoryTextBase())
                    .foregroundColor(Color.theme.c6)
                    .paddings(vertical: 8, horizontal: 16)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(amount.stringFormat)
                    .lineLimit(1)
                    .minimumScaleFactor(1.0)
                    .font(.subscription())
                    .foregroundColor(Color.theme.c7)
                    .paddings(vertical: 8, horizontal: 16)
            }
            .frame(width: 68, alignment: .trailing)
        }
    }
}


struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SearchView(searchText: .constant(""), isPresented: .constant(true), inSearchMode: .constant(true), closeAddView: { print("print") })
                .previewLayout(.sizeThatFits)
                .preferredColorScheme(.light)

            SearchView(searchText: .constant(""), isPresented: .constant(true), inSearchMode: .constant(true), closeAddView: { print("print") })
                .previewLayout(.sizeThatFits)
                .preferredColorScheme(.dark)

        }
    }
}
