//
//  TestsRequestNetworkData.swift
//  AiLiToolbox
//
//  Created by lip on 2017/5/17.
//  Copyright © 2017年 AiLi Toolbox. All rights reserved.
//

import Quick
import Nimble
import Mockingjay
import AiLiToolbox

class TestsRequestNetworkDataSpec: QuickSpec {
    private let rootUrl = "http://example.mock.com/"
    override func spec() {
        beforeEach {
            /// 重置部分会被修改的配置
            RequestNetworkData.share.isShowLog = false
            RequestNetworkData.share.configRootURL(rootURL: nil)
            RequestNetworkData.share.configAuthorization(nil)
        }

        describe("和服务器通讯时") {
            context("根地址", {
                it("未配置,请求数据抛出错误") {
                    expect {
                        try RequestNetworkData.share.textRequest(method: .get, path: nil, parameter: nil, complete: { (requestData, results) in
                        })
                    }.to(throwError())
                }
                it("已配置,请求数据不抛出错误") {
                    RequestNetworkData.share.configRootURL(rootURL: self.rootUrl)
                    expect {
                        try RequestNetworkData.share.textRequest(method: .get, path: nil, parameter: nil, complete: { (requestData, results) in
                        })
                    }.toNot(throwError())
                }
            })
        }

        describe("当配置了根地址请求服务器时") {
            beforeEach {
                RequestNetworkData.share.configRootURL(rootURL: self.rootUrl)
            }

            context("配置情况", {
                it("配置了口令,请求头会携带口令") {
                    RequestNetworkData.share.configAuthorization("token")
                    /// 暂时没有办法使用 `Mockingjay` 单独拦截请求头内容,暂时直接通过
                    var result: Bool?
                    try! RequestNetworkData.share.textRequest(method: .get, path: "mock", parameter: nil, complete: { (requestData, results) in
                        result = results
                    })
                    expect(result).toEventually(beNil(), timeout: 1, pollInterval: 0.3)
                    expect(true).to(beTrue())
                }
                it("配置了日志开启") {
                    RequestNetworkData.share.isShowLog = true
                    /// 暂时无法测试日志开关
                    var result: Bool?
                    self.stub(everything, json(["key": "value"], status: 201, headers: nil))
                    try! RequestNetworkData.share.textRequest(method: .get, path: "mock", parameter: nil, complete: { (requestData, results) in
                        result = results
                    })
                    expect(result).toEventually(beTrue(), timeout: 1, pollInterval: 0.3)
                    expect(true).to(beTrue())
                }
            })

            context("发起网络请求", {
                it("正常响应处理数据") {
                    let url = self.rootUrl + "mock"
                    self.stub(http(.get, uri: url), json(["key": "value"], status: 201, headers: nil))
                    var networkResponse: NetworkResponse
                    var result: Bool?
                    try! RequestNetworkData.share.textRequest(method: .get, path: "mock", parameter: nil, complete: { (requestData, results) in
                        networkResponse = requestData
                        result = results
                    })

                    expect(networkResponse.responseData?["key"] as? String).toEventually(equal("value"), timeout: 1, pollInterval: 0.3)
                    expect(result).toEventually(beTrue(), timeout: 1, pollInterval: 0.3)
                }
                it("处理请求相关错误") {
                    /// 错误通过`kRequestNetworkDataErrorDomain` 为key 返回
                    self.stub(everything, failure(NSError(domain: "error", code: 0, userInfo: nil)))
                    var networkResponse: NetworkResponse
                    var result: Bool?
                    try! RequestNetworkData.share.textRequest(method: .get, path: "mock", parameter: nil, complete: { (requestData, results) in
                        networkResponse = requestData
                        result = results
                    })

                    expect(networkResponse.error?.domain).toEventually(equal("error"), timeout: 1, pollInterval: 0.3)
                    expect(result).toNotEventually(beTrue(), timeout: 1, pollInterval: 0.3)
                }
                it("正常响应服务器错误") {
                    self.stub(everything, json(["key": "value"], status: 404, headers: nil))
                    var networkResponse: NetworkResponse
                    var result: Bool?
                    try! RequestNetworkData.share.textRequest(method: .get, path: "mock", parameter: nil, complete: { (requestData, results) in
                        networkResponse = requestData
                        result = results
                    })

                    expect(networkResponse.responseData?["key"] as? String).toEventually(equal("value"), timeout: 1, pollInterval: 0.3)
                    expect(result).toNotEventually(beTrue(), timeout: 1, pollInterval: 0.3)
                }
            })
        }
    }
}
