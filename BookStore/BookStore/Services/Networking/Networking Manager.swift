import UIKit

enum TrendingPeriod: String, CaseIterable {
    case weekly
    case monthly
    case yearly
}

enum Categories: String {
    case love = "love"
    case fiction = "fiction"
    case horror = "horror"
    case crime = "crime"
    case drama = "drama"
    case classics = "classics"
    case forChildren = "children"
    case sci_fi = "sci-fi"
    case humor = "humor"
    case poetry = "poetry"
    case art = "history_of_art__art__design_styles"
    case history = "history"
    case biography = "biography"
    case business = "business"
    case fantasy = "fantasy"
}

public class NetworkingManager {
    
    static let instance = NetworkingManager()
    
    var searchCompletion: ((BookObject) -> Void)?
    var timer: Timer?
    
    var urlEndpoints = [("&mode=everything", false),
                        ("&sort=editions&mode=everything", false),
                        ("&sort=old&mode=everything", false),
                        ("&sort=new&mode=everything", false),
                        ("https://openlibrary.org/search.json?title=", true),
                        ("https://openlibrary.org/search.json?author=", true)]
    
    func importJson(url: String, completion: @escaping (BookObject) -> Void) {
        
        guard let url = URL(string: url) else { return }
        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            guard let data = data else { return }
            do {
                let object = try JSONDecoder().decode(BookObject.self, from: data)
                DispatchQueue.main.async {
                    completion(object)
                }
            } catch {
                print(error)
            }
        }).resume()
    }
    
    func getUrl(rawUrl: String) -> String {
        let url = rawUrl.replacingOccurrences(of: " ", with: "+")
        return url
    }
    
    public func searchBooks(keyword: String, emptyCompletion: () -> Void, searchCompletion: @escaping (BookObject) -> Void) {
        timer?.invalidate()
        self.searchCompletion = searchCompletion
        if keyword.isEmpty {
            emptyCompletion()
            return
        }
        var url = "https://openlibrary.org/search.json?q=" + "\(keyword)"
        
        for (i,c) in urlEndpoints.enumerated(){
            if(UserDefaults.standard.bool(forKey: "\(i)") == true){
                if(c.1 == false){
                    url = url + c.0
                }else{
                    url = c.0 + "\(keyword)"
                }
            }
        }
//        let passData = (url: url, completion: searchCompletion)
        timer = Timer.scheduledTimer(timeInterval: 0.35, target: self, selector: #selector(startSearching), userInfo: url, repeats: false)
    }

    // getting top books
    func getTrendingBooks(for period: TrendingPeriod, completion: @escaping (Result<[(TrendingBooks.Book, URL)], Error>) -> Void) {
        let trendingURL = "https://openlibrary.org/trending/\(period.rawValue).json"
        
        guard let url = URL(string: trendingURL) else {
            let error = NSError(domain: "Invalid URL", code: 0, userInfo: nil)
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                let error = NSError(domain: "No data", code: 0, userInfo: nil)
                completion(.failure(error))
                return
            }
            
            do {
                let trendingBooks = try JSONDecoder().decode(TrendingBooks.self, from: data)
                
                let booksWithCover = trendingBooks.works.compactMap { work -> (TrendingBooks.Book, URL)? in
                    guard let coverID = work.cover_i else {
                        return nil
                    }

                    let coverURL = URL(string: "https://covers.openlibrary.org/b/id/" + "\(coverID)-M.jpg")!
                    return (work, coverURL)
                }
                completion(.success(booksWithCover))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    //getting categories collection
    func getCategoryCollection(for category: Categories, completion: @escaping (Result<[CategoryCollection], Error>) -> Void) {
        let trendingURL = "https://openlibrary.org/subjects/\(category.rawValue).json"
        
        guard let url = URL(string: trendingURL) else {
            let error = NSError(domain: "Invalid URL", code: 0, userInfo: nil)
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                let error = NSError(domain: "No data", code: 0, userInfo: nil)
                completion(.failure(error))
                return
            }

            do {
                let jsonDecoder = JSONDecoder()

                if let subjectsResponse = try? jsonDecoder.decode([CategoryCollection].self, from: data) {
                    completion(.success(subjectsResponse))
                    return
                }

                if let singleSubjectResponse = try? jsonDecoder.decode(CategoryCollection.self, from: data) {
                    completion(.success([singleSubjectResponse]))
                } else {
                    let error = NSError(domain: "Invalid Response", code: 0, userInfo: nil)
                    completion(.failure(error))
                }
            }
            }.resume()
        }

    //присваивание изображения по ссылке
    func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error loading image: \(error)")
                completion(nil)
                return
            }

            if let data = data, let image = UIImage(data: data) {
                completion(image)
            } else {
                print("Error creating image from data")
                completion(nil)
            }
        }.resume()
    }

    func getBookDetails(for key: String, completion: @escaping (Result<DetailsModel, Error>) -> Void) {
        let detailsURL = "https://openlibrary.org\(key).json"

        guard let url = URL(string: detailsURL) else {
            let error = NSError(domain: "Invalid URL", code: 0, userInfo: nil)
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                let error = NSError(domain: "No data", code: 0, userInfo: nil)
                completion(.failure(error))
                return
            }

            do {
                let bookDetails = try JSONDecoder().decode(DetailsModel.self, from: data)

                completion(.success(bookDetails))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func getBookRating(for key: String, completion: @escaping (Result<DetailsModel, Error>) -> Void) {
        let detailsURL = "https://openlibrary.org\(key)/ratings.json"

        guard let url = URL(string: detailsURL) else {
            let error = NSError(domain: "Invalid URL", code: 0, userInfo: nil)
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                let error = NSError(domain: "No data", code: 0, userInfo: nil)
                completion(.failure(error))
                return
            }

            do {
                let bookDetails = try JSONDecoder().decode(DetailsModel.self, from: data)

                completion(.success(bookDetails))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }


    @objc func startSearching() {
        let url = timer!.userInfo as! String
        let finalUrl = getUrl(rawUrl: url)
        guard let completion = searchCompletion else { return }
        importJson(url: finalUrl, completion: completion)
    }
}
