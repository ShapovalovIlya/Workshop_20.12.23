import UIKit

enum TrendingPeriod: String {
    case weekly = "weekly"
    case monthly = "monthly"
    case yearly = "yearly"
}

//добавить больше категорий с https://openlibrary.org/subjects
enum Categories: String {
    case love = "love"
    case fiction = "fiction"
    case horror = "horror"
    case crime = "crime"
    case drama = "drama"
    case classics = "classics"
    case forChildren = "children"
    case sci_fi = "sci-fi"
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
        let passData = (url: url, completion: searchCompletion)
        timer = Timer.scheduledTimer(timeInterval: 0.35, target: self, selector: #selector(startSearching), userInfo: url, repeats: false)
    }

    @objc func startSearching() {
        let url = timer!.userInfo as! String
        let finalUrl = getUrl(rawUrl: url)
        guard let completion = searchCompletion else { return }
        importJson(url: finalUrl, completion: completion)
    }

    // getting top books
    func getTrendingBooks(for period: TrendingPeriod, completion: @escaping (Result<[TrendingBooks.Book], Error>) -> Void) {
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
                let books = trendingBooks.works.compactMap { $0 }
                completion(.success(books))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    //
    func getCategoryCollection(for category: Categories, completion: @escaping (Result<[SubjectResponse], Error>) -> Void) {
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

//            if let jsonString = String(data: data, encoding: .utf8) {
//                print("Response JSON: \(jsonString)")
//            }

            //            do {
            //                let jsonDecoder = JSONDecoder()
            //                let decodedData = try jsonDecoder.decode([String: [SubjectResponse]].self, from: data)
            //
            //                // Извлекаем массив SubjectResponse из словаря
            //                if let subjectsResponse = decodedData["works"] {
            //                    completion(.success(subjectsResponse))
            //                } else {
            //                    // Если ключ "works" отсутствует, возвращаем ошибку
            //                    let error = NSError(domain: "Invalid Response", code: 0, userInfo: nil)
            //                    completion(.failure(error))
            //                }
            //            } catch {
            //                completion(.failure(error))
            //            }
            //        }.resume()

            //где-то здесь кажется есть лишний код
            do {
                let jsonDecoder = JSONDecoder()

                // Попытка декодировать массив SubjectResponse
                if let subjectsResponse = try? jsonDecoder.decode([SubjectResponse].self, from: data) {
                    completion(.success(subjectsResponse))
                    return
                }

                // Если декодирование массива не удалось, попробуем декодировать как одиночный объект SubjectResponse
                if let singleSubjectResponse = try? jsonDecoder.decode(SubjectResponse.self, from: data) {
                    completion(.success([singleSubjectResponse]))
                } else {
                    // Если не удалось декодировать как массив или объект, возвращаем ошибку
                    let error = NSError(domain: "Invalid Response", code: 0, userInfo: nil)
                    completion(.failure(error))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

// MARK: - Welcome10
struct Welcome10: Codable {
    let page: Int
    let readingLogEntries: [ReadingLogEntry]
}

// MARK: - ReadingLogEntry
struct ReadingLogEntry: Codable {
    let work: Work
    let loggedEdition: String?
    let loggedDate: String
}

// MARK: - Work
struct Work: Codable {
    let title: String?
    let key: String
    let authorKeys, authorNames: [String]
    let firstPublishYear: Int?
    let lendingEditionS: String?
    let editionKey: [String]?
    let coverID: Int?
    let coverEditionKey: String?
}

struct TrendingBooks: Codable {
    let query: String
    let works: [Book]

    struct Book: Codable {
        let key: String?
        let title: String?
        let first_publish_year: Int?
        let has_fulltext: Bool?
        let ia: [String]?
        let ia_collection_s: String?
        let cover_edition_key: String?
        let cover_i: Int?
        let author_key: [String]?
        let author_name: [String]?
    }
}

struct SubjectResponse: Codable {
    let key: String?
    let name: String?
    let work_count: Int?
    let works: [Work]

    struct Work: Codable {
        let key: String?
        let title: String?
        let cover_id: Int?
//        let cover_edition_key: String?
//        let subject: [Subject] это если понадобятся ключевые слова по теме, нужна будет структурка Subject
        let edition_count: Int?
        let authors: [Author]
        let first_publish_year: Int?
        let has_fulltext: Bool? //использовать при выгрузке в читалку?
//        let ia: String?

        struct Author: Codable {
            let name: String?
            let key: String?
        }
    }
}

