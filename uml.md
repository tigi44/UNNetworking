```plantuml
NetworkManagerSendRequest <|.. NetworkManager
NetworkManagerHandleError <|.. NetworkManager

NetworkURLRequest <|.. NetworkRequest
NetworkRequestResponse <|.. NetworkRequest
MakeURLRequest <|.. NetworkRequest

NetworkURLResponse <|.. NetworkResponse
NetworkResponseDataParser <|.. NetworkResponse

NetworkResponse <-* NetworkRequest 
NetworkRequest <-o NetworkManager



interface NetworkManagerSendRequest {
+ sendRequest()
}

interface NetworkManagerHandleError {
- handleErrorHTTPURLResponse()
- handleClientError()
- handleServiceError()
- handleNetworkError()
}

class NetworkManager {}

interface NetworkURLRequest {
+ host: String
+ urlPath: String
+ method: HttpMethod
+ contentType: ContentType
+ headers: Dictionary
+ params: Dictionary
+ bodyBinary: Data
+ cachePolicy: URLRequest.CachePolicy
+ timeoutInterval: TimeInterval

+ init(urlPath: String, method: HttpMethod, contentType: ContentType)
}

interface NetworkRequestResponse {
+ networkResponse: NetworkResponse
}

interface MakeURLRequest {
- request() -> URLRequest
}

class NetworkRequest {}

interface NetworkURLResponse {
- urlResponse
}

interface NetworkResponseDataParser {
+ responseDataType
+ parseResponseData()
+ parseJsonResponseData()
+ parseObjectResponseData()
+ parseStringResponseData()
+ decodeResponseObject()
}

class NetworkResponse {}
```
