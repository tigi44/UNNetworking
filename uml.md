```plantuml
NetworkManagerRequest <|.. NetworkManager
NetworkManagerHandleError <|.. NetworkManager

NetworkURLRequest <|.. NetworkRequest

NetworkURLResponse <|.. NetworkResponse
NetworkResponseDataParser <|.. NetworkResponse

NetworkResponse <-* NetworkRequest
NetworkRequest <-o NetworkManager



interface NetworkManagerRequest {
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
+ urlPath
+ method
+ contentType
+ headers
+ params
+ bodyBinary

+ init()
+ alphaHost()
+ betaHost()
+ realHost()
+ cachePolicy()
+ timeoutInterval()
+ request()
}

class NetworkRequest {
+ networkResponse: NetworkURLResponse
}

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
