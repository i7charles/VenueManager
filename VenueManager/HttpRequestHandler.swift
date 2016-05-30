import Foundation

public class HttpRequestHandler: NSObject, NSURLSessionDelegate {

    enum SessionConfigurationError: ErrorType {
        case SessionNotConfigure
    }

    public static let sharedInstance = HttpRequestHandler()
    override init() {
    }

    var globalUrlSession: NSURLSession?

    public func setupSession(userName: String?, password: String?) {

        //todo : Use delegate to handle session auth challenge

        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let userPasswordString = "\(userName!):\(password!)"
        let userPasswordData = userPasswordString.dataUsingEncoding(NSUTF8StringEncoding)
        let base64EncodedCredential = userPasswordData!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        let authString = "Basic \(base64EncodedCredential)"
        config.HTTPAdditionalHeaders = ["Authorization": authString, "Accept" : "application/json"]
        
        self.globalUrlSession = NSURLSession(configuration: config)

    }


    public func getWithURLString(url: String, successHandler: ((data:NSData) -> Void), errorHandler: ((error:NSError) -> Void)) {
        
        guard let url = NSURL(string: url) else {
            print("Error: cannot create URL")
            errorHandler(error: NSError(domain: "Data Error", code: 1, userInfo: [NSLocalizedDescriptionKey: "Cannot create URL"]))
            return
        }
        
        self.get(url, successHandler: successHandler, errorHandler: errorHandler)
        
    }
    public func postWithURLString(url: String, data : NSData?, successHandler: ((data:NSData) -> Void), errorHandler: ((error:NSError) -> Void)) {
        
        guard let url = NSURL(string: url) else {
            print("Error: cannot create URL")
            errorHandler(error: NSError(domain: "Data Error", code: 1, userInfo: [NSLocalizedDescriptionKey: "Cannot create URL"]))
            return
        }
        
        self.post(url, data: data, successHandler: successHandler, errorHandler: errorHandler)
        
    }

    public func get(url: NSURL, successHandler: ((data:NSData) -> Void), errorHandler: ((error:NSError) -> Void)) {
        
        print("dataForUrl : url -> \(url.description)")
        
        let urlRequest = NSMutableURLRequest(URL: url)
        urlRequest.HTTPMethod = "GET"
        
        self.request(urlRequest, successHandler: successHandler, errorHandler: errorHandler)
        

    }
    public func post(url: NSURL, data : NSData?, successHandler: ((data:NSData) -> Void), errorHandler: ((error:NSError) -> Void)) {


        print("dataForUrl : url -> \(url.description)")

        let urlRequest = NSMutableURLRequest(URL: url)
        urlRequest.HTTPMethod = "POST"
        
        if let someData = data {
            urlRequest.HTTPBody = someData
        }
        
        self.request(urlRequest, successHandler: successHandler, errorHandler: errorHandler)

    }
    public func upload(image : UIImage, named : String, atUrl urlString: String, successHandler: ((data:NSData) -> Void), errorHandler: ((error:NSError) -> Void)) {

        
        guard let url = NSURL(string: urlString) else {
            print("Error: cannot create URL")
            errorHandler(error: NSError(domain: "Data Error", code: 1, userInfo: [NSLocalizedDescriptionKey: "Cannot create URL"]))
            return
        }

        
        print("dataForUrl : url -> \(url.description)")
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.timeoutInterval = 20.0
        
        let boundary = "---------------------------14737809831466499882746641449"
        let contentType = "multipart/form-data; boundary=\(boundary)"
        
        request.addValue(contentType, forHTTPHeaderField: "Content-Type")
        request.setValue("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", forHTTPHeaderField: "Accept")
        request.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_5) AppleWebKit/536.26.14 (KHTML, like Gecko) <span id=\"IL_AD8\" class=\"IL_AD\">Version</span>/6.0.1 Safari/536.26.14", forHTTPHeaderField: "User-Agent")

        let body = NSMutableData()
        
        body.appendData("\r\n--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData("Content-Disposition: form-data; name=\"uploaded_file\"; filename=\"\(named).png\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData("Content-Type: application/octet-stream\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData(NSData(data: UIImagePNGRepresentation(image)!))
        body.appendData("\r\n--\(boundary)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        request.HTTPBody = body
        
        request.addValue("\(body.length)", forHTTPHeaderField: "Content-Length")
        
        self.request(request, successHandler: successHandler, errorHandler: errorHandler)
        
    }

    func request(urlRequest : NSMutableURLRequest, successHandler: ((data:NSData) -> Void), errorHandler: ((error:NSError) -> Void)) {
        
        if let session = self.globalUrlSession {
            
            let task = session.dataTaskWithRequest(urlRequest) {
                (data, response, error) in
                
                
                guard let responseData = data else {
                    print("Error: did not receive data")
                    dispatch_async(dispatch_get_main_queue(), {
                        errorHandler(error: NSError(domain: "Data Error", code: 1, userInfo: [NSLocalizedDescriptionKey: "Did not receive data"]))
                    })
                    return
                }
                guard error == nil else {
                    print(error)
                    dispatch_async(dispatch_get_main_queue(), {
                        errorHandler(error: error!)
                    })
                    return
                }
                
                let httpResponse = response as! NSHTTPURLResponse
                
                switch httpResponse.statusCode {
                case 200 ... 299:
                    
                    print("Data received!")
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        successHandler(data: responseData)
                    })
                    
                    break
                default:
                    dispatch_async(dispatch_get_main_queue(), {
                        errorHandler(error: NSError(domain: "Http Error", code: httpResponse.statusCode, userInfo: httpResponse.allHeaderFields))
                    })
                    break
                }
            }
            
            task.resume()
            
        } else {
            
            dispatch_async(dispatch_get_main_queue(), {
                
                errorHandler(error: NSError(domain: "Progammer Error", code: 666, userInfo: [NSLocalizedDescriptionKey: "Session need to be configure"]))
            })
            
        }
    }
}
