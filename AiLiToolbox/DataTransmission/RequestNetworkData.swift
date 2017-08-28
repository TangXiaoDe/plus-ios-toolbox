//
//  RquestNetworkData.swift
//  Pods
//
//  Created by lip on 2017/5/16.
//
//  网络请求数据处理

import UIKit
import ObjectMapper
import Alamofire

public enum RquestNetworkDataError: Error {
    /// 未正常初始化
    case uninitialized
}

public enum NetworkError: String {
    /// 网络请求错误（非超时以外的一切错误都会抛出该值，具体错误信息会输出到控制台）
    case networkErrorFailing = "com.zhiyicx.www.network.erro.failing"
    /// 网络请求超时
    case networkTimedOut = "com.zhiyicx.www.network.time.out"
}

/// 网络请求协议
public protocol NetworkRequest {
    /// 网络请求路径
    ///
    /// - Warning: 该路径指的只最终发送给服务的路径,不包含根地址
    var urlPath: String { get }
    /// 网络请求方式
    var method: HTTPMethod { get }
    /// 网络请求参数
    var parameter: [String: Any]? { get }
    /// 相关的响应数据模型
    ///
    /// - Note: 该模型需要实现相对应的解析协议
    associatedtype ResponseModel: Mappable
}

/// 网络请求成功相应数据
///
/// - statusCode: 响应参数
/// - model: 响应正确的数据
/// - message: 响应错误的数据
//public typealias NetworkFullResponse<T> = (statusCode: Int, model: T?, message: String?)

/// 完整响应数据
public struct NetworkFullResponse<T: NetworkRequest> {
    /// 响应编号
    let statusCode: Int
    /// 响应数据,由请求体配置的参数决定
    var model: T.ResponseModel?
    /// 响应一组数据,由请求体配置参数决定
    var models: [T.ResponseModel]
    /// 服务器响应数据
    var message: String?
}

/// 网络请求结果
///
/// - success: 请求成功,返回数据
/// - failure: 请求失败,返回失败原因
public enum NetworkResult<T: NetworkRequest> {
    case success(NetworkFullResponse<T>)
    case failure(NetworkError)
}

/// 服务器响应数据
///
/// 服务器可能会响应 Dictionary<String, Any>; Array<Any>; 以及 空数组
/// 服务器指定使用空数组表示无数据的情况
/// - Warning: 当出现数据解析或者超时等错误时, 返回 nil
public typealias NetworkResponse = Any

public class RequestNetworkData: NSObject {
    private var rootURL: String?
    private let textRequestTimeoutInterval = 10
    private let serverResponseInfoKey = "message"
    private var authorization: String?
    private override init() {}

    public static let share = RequestNetworkData()
    /// 配置是否显示日志信息,默认是关闭的
    ///
    /// - Note: 开启后,每次网络请求都会在控制台打印请求数据和请求结果
    public var isShowLog = false

    lazy var alamofireManager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = TimeInterval(self.textRequestTimeoutInterval)
        return Alamofire.SessionManager(configuration: configuration)
    }()

    // MARK: - config
    /// 设置请求的根地址
    ///
    /// - Parameter rootURL: 根地址字符串
    /// - Note: 设置后会导致所有的请求都依照该地址发起
    public func configRootURL(rootURL: String?) {
        self.rootURL = rootURL
    }

    /// 配置请求的授权口令
    ///
    /// - Note: 配置后,每次请求的都会携带该参数
    public func configAuthorization(_ authorization: String?) {
        self.authorization = authorization
    }

    /// 文本请求
    ///
    /// - Parameters:
    ///   - request: 请求体
    ///   - complete: 响应数据
    public func text<T: NetworkRequest>(request: T, complete: @escaping (_ result: NetworkResult<T>) -> Void) {
        let (coustomHeaders, requestPath, encoding) = processParameters(self.authorization, request)

        var dataResponse: DataResponse<Any>!
        let decodeGroup = DispatchGroup()
        decodeGroup.enter()
        alamofireManager.request(requestPath, method: request.method, parameters: request.parameter, encoding: encoding, headers: coustomHeaders).responseJSON {  [unowned self] response in
            guard response.response != nil else {
                assert(false, "Server reponse empty.")
                return
            }

            if self.isShowLog == true {
                print("http respond info \(response)")
            }

            dataResponse = response
            decodeGroup.leave()
        }

        decodeGroup.notify(queue: DispatchQueue.main) {
            let result = dataResponse.result
            let statusCode = dataResponse.response!.statusCode

            if let error: NSError = result.error as NSError?, error.domain == NSURLErrorDomain && error.code == NSURLErrorTimedOut {
                let error = NetworkError.networkTimedOut
                let result = NetworkResult<T>.failure(error)
                complete(result)
                return
            } else if let error = result.error as NSError?, error.domain == NSURLErrorDomain && error.code != NSURLErrorTimedOut {
                let error = NetworkError.networkErrorFailing
                let result = NetworkResult<T>.failure(error)
                complete(result)
                return
            }

            if statusCode >= 200 && statusCode < 300 {
                if let datas = result.value as? [Any], let models = Mapper<T.ResponseModel>().mapArray(JSONObject: datas) {
                    let fullResponse = NetworkFullResponse<T>(statusCode: statusCode, model: nil, models: models, message: nil)
                    let result = NetworkResult.success(fullResponse)
                    complete(result)
                }

                if let data = result.value as? [String: Any], let model = Mapper<T.ResponseModel>().map(JSON: data) {
                    let fullResponse = NetworkFullResponse<T>(statusCode: statusCode, model: model, models: [], message: nil)
                    let result = NetworkResult<T>.success(fullResponse)
                    complete(result)
                }
                return
            }

            // json -> ["message": ["value1", "value2"...]]
            if let responseInfoDic = result.value as? Dictionary<String, Array<String>>, let messages = responseInfoDic[self.serverResponseInfoKey] {
                let fullResponse = NetworkFullResponse<T>(statusCode: statusCode, model: nil, models: [], message: messages.first)
                let result = NetworkResult<T>.success(fullResponse)
                complete(result)
                return
            }
            // josn -> ["message": "value"]
            if let responseInfoDic = result.value as? Dictionary<String, String>, let message = responseInfoDic[self.serverResponseInfoKey] {
                let fullResponse = NetworkFullResponse<T>(statusCode: statusCode, model: nil, models: [], message: message)
                let result = NetworkResult<T>.success(fullResponse)
                complete(result)
                return
            }
            // json -> ["message": ["key1": "value1", "key2": "value2"...]]
            if let responseInfoDic = result.value as? Dictionary<String, Dictionary<String, Any>>, let messageDic = responseInfoDic[self.serverResponseInfoKey] {
                let fullResponse = NetworkFullResponse<T>(statusCode: statusCode, model: nil, models: [], message: messageDic.first?.value as! String?)
                let result = NetworkResult<T>.success(fullResponse)
                complete(result)
                return
            }
            // statusCode 404 response empty
            let fullResponse = NetworkFullResponse<T>(statusCode: statusCode, model: nil, models: [], message: nil)
            let resultResponse = NetworkResult<T>.success(fullResponse)
            complete(resultResponse)
        }
    }

    private func processParameters<T: NetworkRequest>(_ authorization: String?, _ request: T) -> (HTTPHeaders, String, ParameterEncoding) {
        guard let authorization = self.authorization else {
            fatalError("Network request data error uninitialized, unallocate authorization.")
        }

        let requestPath = authorization + request.urlPath
        var coustomHeaders: HTTPHeaders = ["Accept": "application/json"]
        let token = "Bearer " + self.authorization!
        coustomHeaders.updateValue(token, forKey: "Authorization")

        var encoding: ParameterEncoding!
        request.method == .get ? (encoding = URLEncoding.default) : (encoding = JSONEncoding.default)

        if self.isShowLog == true {
            print("\nRootURL:\(requestPath)\nAuthorization: Bearer " + (authorization) + "\nRequestMethod:\(request.method.rawValue)\nParameters:\n\(request.parameter)\n")
        }
        return (coustomHeaders, requestPath, encoding)
    }

    /// 和服务器间的文本请求
    ///
    /// - Parameters:
    ///   - method: 请求方式
    ///   - path: 请求路径,拼接在根路径后
    ///   - parameter: 请求参数
    ///   - complete: 请求结果
    ///
    /// - Note:complete 返回值详细说明
    /// - responseStatus 正确: 该值为 true 时，表示服务正常想数据，NetworkResponse 按照接口约定返回不同的数据
    /// - responseStatus 错误
    ///   - 该值为 false 时: 第一种情况是请求错误(超时,数据格式错误等),该情况下 NetworkResponse 返回 NetworkError.networkErrorFailing 等值, 此时 NetworkResponse 类型为 enum
    ///   - 该值为 false 时: 第二种情况是服务器响应,但内容错误,例如服务器返回 statusCode 404 ,表示无法查询到对应数据
    ///   - 错误信息拆包: 当 responseStatus 错误时,服务器响应错误中含有服务器约定好的值‘message’时,会将对应的错误信息中的首个信息字符串通过 NetworkResponse 返回,此时 NetworkResponse 类型为 String
    /// - 所有详细的错误信息都会打印在控制台
    /// - Throws: 错误状态,如果未成功配置根地址会抛错
    public func textRequest(method: HTTPMethod, path: String?, parameter: Dictionary<String, Any>?, complete: @escaping (_ responseData: NetworkResponse?, _ responseStatus: Bool) -> Void) throws {

        let (coustomHeaders, requestPath) = try processParameters(self.authorization, path)

        if self.isShowLog == true {
            let authorization: String = self.authorization ?? "nil"
            print("\nRootURL:\(requestPath)\nAuthorization: Bearer " + (authorization) + "\nRequestMethod:\(method)\nParameters:\n\(parameter)\n")
        }

        var encoding: ParameterEncoding!
        if method == .post {
            encoding = JSONEncoding.default
        } else {
            encoding = URLEncoding.default
        }

        alamofireManager.request(requestPath, method: method, parameters: parameter, encoding: encoding, headers: coustomHeaders).responseJSON { [unowned self] response in
            if self.isShowLog == true {
                print("http respond info \(response)")
            }
            if let error: NSError = response.result.error as NSError? {
                print("http respond error \(error)")
                if error.domain == NSURLErrorDomain && error.code == NSURLErrorTimedOut {
                    complete(NetworkError.networkTimedOut, false)
                } else {
                    complete(NetworkError.networkErrorFailing, false)
                }
                return
            }
            var responseStatus: Bool = false
            guard let serverResponse = response.response else {
                assert(false, "服务器响应的数据无法解析")
                return
            }
            if serverResponse.statusCode >= 200 && serverResponse.statusCode < 300 {
                responseStatus = true
                complete(response.result.value, responseStatus)
                return
            }
            guard let responseInfoDic = response.result.value as? Dictionary<String, Array<String>> else {
                complete(response.result.value, responseStatus)
                return
            }
            if responseInfoDic.keys.contains(self.serverResponseInfoKey) {
                complete(responseInfoDic[self.serverResponseInfoKey]![0], responseStatus)
                return
            }
            complete(response.result.value, responseStatus)
        }
    }

    private func processParameters(_ authorization: String?, _ path: String?) throws -> (HTTPHeaders?, String) {
        guard let rootURL = self.rootURL else {
            throw RquestNetworkDataError.uninitialized
        }

        var coustomHeaders: HTTPHeaders = ["Accept": "application/json"]
        if let authorization = authorization {
            let token = "Bearer " + authorization
            coustomHeaders.updateValue(token, forKey: "Authorization")
        }

        var requestPath: String = ""
        if let path = path {
            requestPath = rootURL + path
        } else {
            requestPath = rootURL
        }
        return (coustomHeaders, requestPath)
    }
}
