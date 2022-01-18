//
//  NetworkAPI.swift
//  RxNetworks
//
//  Created by Condy on 2021/10/5.
//

import RxSwift
import Moya

public protocol NetworkAPI: Moya.TargetType {
    
    /// 根路径地址
    var ip: APIHost { get }
    /// 请求参数
    var parameters: APIParameters? { get }
    /// 插件
    var plugins: APIPlugins { get }
    /// 是否走测试数据
    var stubBehavior: APIStubBehavior { get }
}

extension NetworkAPI {
    
    /// Network request.
    /// Protocol oriented network request, Indicator plugin are added by default
    /// Example:
    ///
    ///     func request(_ count: Int) -> Driver<[CacheModel]> {
    ///         CacheAPI.cache(count).request()
    ///                 .mapHandyJSON(HandyDataModel<[CacheModel]>.self)
    ///                 .compactMap { $0.data }
    ///                 .observe(on: MainScheduler.instance) // The result is returned on the main thread
    ///                 .delay(.seconds(1), scheduler: MainScheduler.instance) // Delay 1 second to return
    ///                 .asDriver(onErrorJustReturn: []) // return null at the moment of error
    ///     }
    ///
    /// - Parameter callbackQueue: Callback queue. If nil - queue from provider initializer will be used.
    /// - Returns: Single sequence JSON object.
    public func request(callbackQueue: DispatchQueue? = nil) -> APISingleJSON {
        var tempPlugins: APIPlugins = self.plugins
        NetworkUtil.defaultPlugin(&tempPlugins, api: self)
        
        let target = MultiTarget.target(self)

        let (result, end) = NetworkUtil.handyConfigurationPlugin(tempPlugins, target: target)
        if end == true {
            let single = NetworkUtil.transformAPISingleJSON(result)
            return single
        }
        
        let configuration = URLSessionConfiguration.default
        configuration.headers = .default
        configuration.timeoutIntervalForRequest = 30
        let session = Moya.Session(configuration: configuration, startRequestsImmediately: false)
        let MoyaProvider = MoyaProvider<MultiTarget>(stubClosure: { _ in
            return stubBehavior
        }, session: session, plugins: tempPlugins)
        let single = MoyaProvider.rx.request(api: self, callbackQueue: callbackQueue)
        
        let angin = NetworkUtil.handyLastNeverPlugin(tempPlugins, target: target, single: single)
        if angin == true {
            return self.request(callbackQueue: callbackQueue)
        }
        return single
    }
}

extension NetworkAPI {
    public var ip: APIHost {
        return NetworkConfig.baseURL
    }
    
    public var parameters: APIParameters? {
        return nil
    }
    
    public var plugins: APIPlugins {
        return []
    }
    
    public var stubBehavior: APIStubBehavior {
        return .never
    }
    
    public var baseURL: URL {
        return URL(string: ip)!
    }
    
    public var path: APIPath {
        return ""
    }
    
    public var validationType: Moya.ValidationType {
        return .successCodes
    }
    
    public var method: APIMethod {
        return NetworkConfig.baseMethod
    }
    
    public var sampleData: Data {
        return "{\"Condy\":\"ykj310@126.com\"}".data(using: String.Encoding.utf8)!
    }
    
    public var headers: [String : String]? {
        return ["Content-type": "application/json"]
    }
    
    public var task: Moya.Task {
        var param = NetworkConfig.baseParameters
        if let parameters = parameters {
            /// 合并字典，并且取第二个值
            param = NetworkConfig.baseParameters.merging(parameters) { $1 }
        }
        switch method {
        case APIMethod.get:
            return .requestParameters(parameters: param, encoding: URLEncoding.default)
        case APIMethod.post:
            return .requestParameters(parameters: param, encoding: JSONEncoding.default)
        default:
            return .requestParameters(parameters: param, encoding: JSONEncoding.default)
        }
    }
}
