//
//  HomeVCmapper.swift
//  BookStore
//
//  Created by Илья Шаповалов on 21.12.2023.
//

import Foundation

extension HomeVC {
    struct Mapper {
        let books: [TrendingBooks.Book]
        let segment: TrendingPeriod
        
        init(books: [TrendingBooks.Book], segment: TrendingPeriod) {
            self.books = books
            self.segment = segment
        }
        
        func toTopHeader(tap: @escaping () -> Void) -> CVDSHome.DataModel.Header {
            makeHeader("Top books", action: tap)
        }
        
        func toSegments() -> [String] {
            TrendingPeriod.allCases.map(\.rawValue)
        }
        
        func toTopBooks() -> [CVDSHome.DataModel.Book] {
            books.map { book in
                    .init(
                        title: book.title ?? "",
                        author: book.author_name?.first ?? "",
                        imageUrl: "https://covers.openlibrary.org/b/id/\(book.cover_i ?? 0)-M.jpg"
                    )
            }
        }
        
        func toRecentHeader(tap: @escaping () -> Void) -> CVDSHome.DataModel.Header {
            makeHeader("Recent books", action: tap)
        }
        
        private func makeHeader(_ title: String, action: @escaping () -> Void) -> CVDSHome.DataModel.Header {
            .init(title: title, action: action)
        }
    }
}
