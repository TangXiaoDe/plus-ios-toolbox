//
//  RquestNetworkData.swift
//  Pods
//
//  Created by lip on 2017/5/16.
//
//  网络请求数据处理

import UIKit
import Alamofire

public enum RquestNetworkDataError: Error {
    /// 未正常初始化
    case uninitialized
}

/// 服务器响应数据
public typealias NetworkResponse = (responseData: Dictionary<String, Any>?, error: NSError?)

public let kRequestNetworkDataErrorDomain = "com.zhiyicx.ios.error.network"

public class RequestNetworkData: NSObject {
    private var rootURL: String?
    private var rootParameter: Dictionary<String, Any>?
    private let networkErrorInfo: String = "网络异常，请检查网络连接"
    private let textRequestTimeoutInterval = 10
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

    /// 配置请求的根参数
    ///
    /// - Note: 配置后,每次请求的请求体都会携带该参数
    public func configRootParameter(rootParameter: Dictionary<String, Any>) {
        self.rootParameter = rootParameter
    }

    /// 配置请求的授权口令
    ///
    /// - Note: 配置后,每次请求的都会携带该参数
    public func configAuthorization(_ authorization: String?) {
        self.authorization = authorization
    }

    /// 和服务器间的文本请求
    ///
    /// - Parameters:
    ///   - method: 请求方式
    ///   - path: 请求路径,拼接在根路径后
    ///   - parameter: 请求参数
    ///   - complete: 请求结果
    /// - Note:
    ///   - responseStatus: 通过是否返回 responseStatus 判断是否请求成功,
    ///   - responseData: 如果响应数据`responseData`的 key 是`com.zhiyicx.ios.error.network` 时,错误信息转换为`NSError`格式返回
    /// - Throws: 错误状态,如果未成功配置根地址会抛错
    public func textRequest(method: HTTPMethod, path: String?, parameter: Dictionary<String, Any>?, complete: @escaping (_ responseData: NetworkResponse, _ responseStatus: Bool?) -> Void) throws {

        let (coustomHeaders, requestPath, parameters) = try processParameters(self.authorization, path, parameter)

        if self.isShowLog == true {
            let authorization: String = self.authorization ?? "nil"
            print("\nRootURL:\(requestPath)\nAuthorization:" + (authorization) + "\nRequestMethod:\(method)\nParameters:\n\(parameters)\n")
        }

        alamofireManager.request(requestPath, method: method, parameters: parameters, encoding: JSONEncoding.default, headers: coustomHeaders).responseJSON { [unowned self] response in
            if self.isShowLog == true {
                print("http respond info \(response)")
            }
            guard response.result.isSuccess else {
                let netwoekResponse = NetworkResponse(responseData: nil, error: response.result.error as? NSError)
                complete(netwoekResponse, false)
                return
            }
            let responseAllData = response.result.value as! Dictionary<String, Any>
            let netwoekResponse = NetworkResponse(responseData: responseAllData, error: nil)
            // 当服务器响应 statusCode 在 200 ~ 300 间时,处理为正确
            guard response.response!.statusCode >= 200 && response.response!.statusCode < 300 else {
                complete(netwoekResponse, false)
                return
            }
            complete(netwoekResponse, true)
        }
    }

    private func processParameters(_ authorization: String?, _ path: String?, _ parameter: Dictionary<String, Any>?) throws -> (HTTPHeaders?, String, Dictionary<String, Any>?) {
        guard let rootURL = self.rootURL else {
            throw RquestNetworkDataError.uninitialized
        }

        var coustomHeaders: HTTPHeaders? = nil
        if let authorization = authorization {
            let token = "Bearer " + authorization
            coustomHeaders = ["Authorization": token]
        }

        var requestPath: String = ""
        if let path = path {
            requestPath = rootURL + path
        } else {
            requestPath = rootURL
        }

        var parameters: Dictionary<String, Any> = [String: Any]()
        if let rootParameter = rootParameter {
            for (key, value) in rootParameter {
                parameters.updateValue(value, forKey: key)
            }
        }
        if let parameter = parameter {
            for (key, value) in parameter {
                parameters.updateValue(value, forKey: key)
            }
        }
        return (coustomHeaders, requestPath, parameters)
    }
}
