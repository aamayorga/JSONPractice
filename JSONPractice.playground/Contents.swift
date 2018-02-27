//: Playground - noun: a place where people can play

import UIKit

// Shortened representation
struct Content: Codable {
    let id: Int
    let title: String
    let body: String
}

struct Section: Codable {
    let id: Int
    let title: String
    let contents: [Content]
}

let content = Content(id: 1, title: "Started", body: "Body of content")
let section = Section(id: 1, title: "iOS 11 Design", contents: [content])

let encoder = JSONEncoder()
do {
    let jsonData = try encoder.encode(section)
    let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments)
    print(String(describing: jsonObject))
    print("wok")
} catch {
    // Encoding error.
    print(error.localizedDescription)
}

struct Update: Decodable {
    let id: Int
    let title = "New Update!"
    let text: String
    let imageURL: URL
    let date: Date
    let postedBy: String
    
    public enum CodingKeys: String, CodingKey {
        case id
        case text
        case imageURL = "image_url"
        case timestamp
        case additionalInfo
    }
    
    enum AdditionalInfoKeys: String, CodingKey {
        case postedBy
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        text = try values.decode(String.self, forKey: .text)
        imageURL = try values.decode(URL.self, forKey: .imageURL)
        
        let unixTimestamp = try values.decode(TimeInterval.self, forKey: .timestamp)
        date = Date.init(timeIntervalSince1970: unixTimestamp)
        
        let additionalInfo = try values.nestedContainer(keyedBy: AdditionalInfoKeys.self, forKey: .additionalInfo)
        postedBy = try additionalInfo.decode(String.self, forKey: .postedBy)
    }
}

extension Update: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(text, forKey: .text)
        try container.encode(imageURL, forKey: .imageURL)
        
        let unixTimestamp = date.timeIntervalSince1970
        try container.encode(unixTimestamp, forKey: .timestamp)
        
        var additionalInfo = container.nestedContainer(keyedBy: AdditionalInfoKeys.self, forKey: .additionalInfo)
        try additionalInfo.encode(postedBy, forKey: .postedBy)
    }
}

let updateJSONString = """
{
    "id": 1,
    "text": "This is the first update of our updates elements",
    "image_url": "https://designcode.io/images.png",
    "timestamp": 1513634273,
    "additionalInfo" : {
        "postedBy" : "Marcos Griselli"
    }
}
"""

do {
    let decoder = JSONDecoder()
    let data = updateJSONString.data(using: .utf8)!
    let update = try decoder.decode(Update.self, from: data)
    print(update)
} catch {
    print(error.localizedDescription)
}
