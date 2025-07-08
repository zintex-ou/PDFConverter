import UIKit

struct EnvironmentModel: Decodable {
    let appId: String
    let email: String
    let adapty: String
    let privacy: String
    let terms: String
}

struct EnvironmentValues {
    static func getValue() -> EnvironmentModel {
        guard let url = Bundle.main.url(forResource: "Environment", withExtension: "plist") else {
            fatalError("Could not finde Congig.plist in your Bundle")
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = PropertyListDecoder()
            return try decoder.decode(EnvironmentModel.self, from: data)
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }
}
