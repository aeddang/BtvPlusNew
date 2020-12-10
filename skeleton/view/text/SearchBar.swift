//
//  SearchBar.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/17.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import WebKit

struct SearchBar: UIViewRepresentable {
    @Binding var text:String
    var search: ((_ text:String) -> Void)? = nil
    var searched: ((_ text:String) -> Void)? = nil
    
    class Coordinator: NSObject, UISearchBarDelegate {
        @Binding var text:String
        var search: ((_ idx:String) -> Void)? = nil
        var searched: ((_ idx:String) -> Void)? = nil
        
        init(
            text:Binding<String>,
            search: ((_ text:String) -> Void)?,
            searched: ((_ text:String) -> Void)?
        )
        {
            self._text = text
            self.search = search
            self.searched = searched
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            self.text = searchText
            guard let action = self.search else { return }
            action(searchText)
        }
        
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchBar.endEditing(true)
            guard let action = self.searched else { return }
            action(self.text)
            
        }
    }

    func makeCoordinator() -> SearchBar.Coordinator {
        return Coordinator(text:self.$text, search:search, searched:searched)
    }

    func makeUIView(context: UIViewRepresentableContext<SearchBar>) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        searchBar.searchBarStyle = .minimal
        return searchBar
    }

    func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<SearchBar>) {
    
    }
}
#if DEBUG
struct SearchBar_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            SearchBar(text:.constant("search start"))
        }
    }
}
#endif
