//
//  NetworkAPIOO.swift
//  RxNetworks
//
//  Created by Condy on 2021/10/5.
//

import Foundation
import Moya

/// 面向对象编程，方便OC小伙伴的使用习惯，备注下面数据必须配套使用。
/// OOP, Convenient for the usage habits of OC partners
public struct NetworkAPIOO {
    
    /// 根路径地址
    public var cdy_ip: APIHost?
    /// 请求路径
    public var cdy_path: APIPath?
    /// 请求参数
    public var cdy_parameters: APIParameters?
    /// 请求类型
    public var cdy_method: APIMethod?
    /// 插件
    public var cdy_plugins: APIPlugins?
    /// 测试数据，该属性设置值之后就只走该测试数据
    public var cdy_testJSON: String?
    /// 测试数据返回时间，默认半秒
    public var cdy_testTime: TimeInterval = 0.5
    
    /// OOP Network request.
    /// Example:
    ///
    ///     var api = NetworkAPIOO.init()
    ///     api.cdy_ip = "https://www.httpbin.org"
    ///     api.cdy_path = "/ip"
    ///     api.cdy_method = APIMethod.get
    ///     api.cdy_plugins = [NetworkLoadingPlugin.init()]
    ///     api.cdy_testJSON = "{\"Condy\":\"ykj310@126.com\"}"
    ///
    ///     api.cdy_HTTPRequest()
    ///         .asObservable()
    ///         .observe(on: MainScheduler.instance)
    ///         .subscribe { (data) in
    ///             print("\(data)")
    ///         } onError: { (error) in
    ///             print("Network failed: \(error.localizedDescription)")
    ///         }
    ///         .disposed(by: disposeBag)
    ///
    /// - Parameter callbackQueue: Callback queue. If nil - queue from provider initializer will be used.
    /// - Returns: Single sequence JSON object.
    public func cdy_HTTPRequest(_ callbackQueue: DispatchQueue? = nil) -> APISingleJSON {
        var api = NetworkObjectAPI.init()
        api.cdy_ip = cdy_ip
        api.cdy_path = cdy_path
        api.cdy_parameters = cdy_parameters
        api.cdy_method = cdy_method
        api.cdy_plugins = cdy_plugins
        if let json = cdy_testJSON {
            api.cdy_test = json
            if cdy_testTime > 0 {
                api.cdy_stubBehavior = StubBehavior.delayed(seconds: cdy_testTime)
            } else {
                api.cdy_stubBehavior = StubBehavior.immediate
            }
        } else {
            api.cdy_stubBehavior = StubBehavior.never
        }
        return api.request(callbackQueue: callbackQueue)
    }
    
    public init() { }
}


internal struct NetworkObjectAPI: NetworkAPI {
    
    var cdy_ip: APIHost?
    var cdy_path: APIPath?
    var cdy_parameters: APIParameters?
    var cdy_method: APIMethod?
    var cdy_plugins: APIPlugins?
    var cdy_stubBehavior: APIStubBehavior?
    var cdy_test: String?
    
    public var ip: APIHost {
        return cdy_ip ?? NetworkConfig.baseURL
    }
    
    public var path: String {
        return cdy_path ?? ""
    }
    
    public var parameters: APIParameters? {
        return cdy_parameters
    }
    
    public var method: APIMethod {
        return cdy_method ?? NetworkConfig.baseMethod
    }
    
    public var plugins: APIPlugins {
        return cdy_plugins ?? []
    }
    
    public var stubBehavior: APIStubBehavior {
        return cdy_stubBehavior ?? StubBehavior.never
    }
    
    public var sampleData: Data {
        if let json = cdy_test {
            return json.data(using: String.Encoding.utf8)!
        }
        return "{\"Condy\":\"ykj310@126.com\"}".data(using: String.Encoding.utf8)!
    }
}
