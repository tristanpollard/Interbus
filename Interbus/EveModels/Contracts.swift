import Foundation

enum ContractError: Error {
    case alreadyFetching
    case decodeError
}

enum ContractStatus: String, Codable {
    case outstanding
    case in_progress
    case finished_issuer
    case finished_contractor
    case finished
    case cancelled
    case rejected
    case failed
    case deleted
    case reversed
}

enum ContractType: String, Codable {
    case unknown
    case item_exchange
    case auction
    case courier
    case loan
}

struct Contract: Codable {
    var acceptorId: Int
    var assigneeId: Int
    var availability: String
    var buyout: Double?
    var collateral: Double?
    var contractId: Int
    var dateAccepted: Date?
    var dateCompleted: Date?
    var dateExpired: Date
    var dateIssued: Date
    var daysToComplete: Int
    var endLocationId: Int64
    var forCorporation: Bool
    var issuerCorporation: EveCorporationData?
    var issuerCorporationId: Int64 {
        didSet {
            issuerCorporation = EveCorporationData(id: issuerCorporationId)
        }
    }
    var issuer: EveCharacter?
    var issuerId: Int64 {
        didSet {
            issuer = EveCharacter(id: issuerId)
        }
    }
    var price: Double?
    var reward: Double?
    var startLocationId: Int64?
    var status: ContractStatus
    var title: String?
    var type: ContractType
    var volume: Double?

    enum CodingKeys: String, CodingKey {
        case acceptorId
        case assigneeId
        case availability
        case buyout
        case collateral
        case contractId
        case dateAccepted
        case dateIssued
        case dateCompleted
        case dateExpired
        case daysToComplete
        case endLocationId
        case forCorporation
        case issuerCorporationId
        case issuerId
        case price
        case reward
        case startLocationId
        case status
        case title
        case type
        case volume
    }
}

class Contracts {

    weak var character: EveCharacter?
    var contracts: [Contract] = []
    var page = 1
    private(set) var isFetching = false
    private(set) var pages: Int = 1

    init(character: EveCharacter) {
        self.character = character
    }

    func fetchNextPage(completion: @escaping ([Contract]?, ContractError?) -> ()) {
        guard isFetching == false, page <= pages else {
            completion(nil, .alreadyFetching)
            return
        }
        isFetching = true

        let esi = ESIClient.sharedInstance
        let options: [ESIClientOptions: Any] = [
            .parameters: ["page": page]
        ]

        if let id = character?.character_id, let token = character?.token {
            esi.invoke(endPoint: "/v1/characters/\(id)/contracts/", token: token, options: options) { response in
                if let pages = response.rawResponse.response?.allHeaderFields["x-pages"] as? Int {
                    self.pages = pages
                }
                if let data = response.data {
                    do {
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        let df = DateFormatter()
                        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
                        decoder.dateDecodingStrategy = .formatted(df)
                        let newContracts = try decoder.decode([Contract].self, from: data)
                        let issuers: [EveCharacter] = newContracts.compactMap {
                            $0.issuer
                        }
                        let corps: [EveCorporationData] = newContracts.compactMap {
                            $0.issuerCorporation
                        }

                        let group = DispatchGroup()
                        group.enter()
                        issuers.fetchNames {
                            group.leave()
                        }

                        group.enter()
                        corps.fetchNames {
                            group.leave()
                        }

                        group.notify(queue: .main) {
                            self.contracts += newContracts
                            completion(newContracts, nil)
                        }
                    } catch {
                        completion(nil, .decodeError)
                    }
                }
                self.page += 1
                self.isFetching = false
            }
        }
    }

}
