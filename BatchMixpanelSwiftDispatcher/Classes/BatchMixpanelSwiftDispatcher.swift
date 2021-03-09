//
//  BatchMixpanelSwiftDispatcher.swift
//  BatchMixpanelSwiftDispatcher
//
//  Copyright © 2020 Batch. All rights reserved.
//

import Foundation
import Batch
import Mixpanel

private struct Consts {
    static let PayloadCampaign = "utm_campaign"
    static let PayloadSource = "utm_source"
    static let PayloadMedium = "utm_medium"
    static let PayloadContent = "utm_content"

    static let MixpanelCampaign = "utm_campaign"
    static let MixpanelSource = "utm_source"
    static let MixpanelIntegrationId = "$source"
    static let MixpanelMedium = "utm_medium"
    static let MixpanelContent = "utm_content"
    static let MixpanelTrackingId = "batch_tracking_id"
    static let MixpanelWebViewAnalyticsId = "batch_webview_analytics_id"
}

/// Describes instance methods that the dispatcher will use on Mixpanel
/// Allows for easy mocking of Mixpanel's SDK
public protocol MixpanelInstanceDispatcherProtocol {
    func track(event: String?, properties: Properties?)
}

/// Extension that makes Mixpanel's SDK conform to our protocol
extension MixpanelInstance: MixpanelInstanceDispatcherProtocol {
}

fileprivate typealias MixpanelProperties = Properties

@objc
public class BatchMixpanelSwiftDispatcher : NSObject {
    
    public static let instance = BatchMixpanelSwiftDispatcher()
    
    public var mixpanelInstance: MixpanelInstanceDispatcherProtocol?
    
    private var warnedAboutNil: Bool = false
    
    override private init() {
        super.init()
    }
    
    private func inAppParams(fromPayload payload: BatchEventDispatcherPayload) -> MixpanelProperties {
        var params = MixpanelProperties()
        
        // Default values
        params[Consts.MixpanelIntegrationId] = "batch"
        params[Consts.MixpanelMedium] = "in-app"
        if let trackingId = payload.trackingId {
            params[Consts.MixpanelCampaign] = trackingId
            params[Consts.MixpanelTrackingId] = trackingId
        }
        
        if let webViewAnalyticsId = payload.webViewAnalyticsIdentifier {
            params[Consts.MixpanelWebViewAnalyticsId] = webViewAnalyticsId
        }
        
        if let deeplink = payload.deeplink {
            if let url = URL(string: deeplink.trimmingCharacters(in: .whitespacesAndNewlines)),
               let components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
                // Override with values from URL fragment parameters
                if let fragments = dictionaryForURLFragment(components.fragment) {
                    self.copyValue(from: fragments, fromKey: Consts.PayloadContent, toMixpanelProperties: &params, toKey: Consts.MixpanelContent)
                }
                
                // Override with values from URL query parameters
                self.copyValue(from: components, fromKey: Consts.PayloadContent, toMixpanelProperties: &params, toKey: Consts.MixpanelContent)
            }
        }
        
        // Override with values from custom payload
        self.copyValue(from: payload, fromKey: Consts.PayloadCampaign, toMixpanelProperties: &params, toKey: Consts.MixpanelCampaign)
        self.copyValue(from: payload, fromKey: Consts.PayloadSource, toMixpanelProperties: &params, toKey: Consts.MixpanelSource)
        self.copyValue(from: payload, fromKey: Consts.PayloadMedium, toMixpanelProperties: &params, toKey: Consts.MixpanelMedium)
        
        return params
    }
    
    private func notificationParams(fromPayload payload: BatchEventDispatcherPayload) -> MixpanelProperties {
        var params = MixpanelProperties()
        
        // Default values
        params[Consts.MixpanelIntegrationId] = "batch"
        params[Consts.MixpanelMedium] = "push"
        
        if let deeplink = payload.deeplink {
            if let url = URL(string: deeplink.trimmingCharacters(in: .whitespacesAndNewlines)),
               let components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
                // Override with values from URL fragment parameters
                if let fragments = dictionaryForURLFragment(components.fragment) {
                    self.copyValue(from: fragments, fromKey: Consts.PayloadCampaign, toMixpanelProperties: &params, toKey: Consts.MixpanelCampaign)
                    self.copyValue(from: fragments, fromKey: Consts.PayloadSource, toMixpanelProperties: &params, toKey: Consts.MixpanelSource)
                    self.copyValue(from: fragments, fromKey: Consts.PayloadMedium, toMixpanelProperties: &params, toKey: Consts.MixpanelMedium)
                    self.copyValue(from: fragments, fromKey: Consts.PayloadContent, toMixpanelProperties: &params, toKey: Consts.MixpanelContent)
                }
                
                // Override with values from URL query parameters
                self.copyValue(from: components, fromKey: Consts.PayloadCampaign, toMixpanelProperties: &params, toKey: Consts.MixpanelCampaign)
                self.copyValue(from: components, fromKey: Consts.PayloadSource, toMixpanelProperties: &params, toKey: Consts.MixpanelSource)
                self.copyValue(from: components, fromKey: Consts.PayloadMedium, toMixpanelProperties: &params, toKey: Consts.MixpanelMedium)
                self.copyValue(from: components, fromKey: Consts.PayloadContent, toMixpanelProperties: &params, toKey: Consts.MixpanelContent)
            }
        }
        
        // Override with values from custom payload
        self.copyValue(from: payload, fromKey: Consts.PayloadCampaign, toMixpanelProperties: &params, toKey: Consts.MixpanelCampaign)
        self.copyValue(from: payload, fromKey: Consts.PayloadSource, toMixpanelProperties: &params, toKey: Consts.MixpanelSource)
        self.copyValue(from: payload, fromKey: Consts.PayloadMedium, toMixpanelProperties: &params, toKey: Consts.MixpanelMedium)
        
        return params
    }
    
    private func dictionaryForURLFragment(_ fragment: String?) -> [String: String]? {
        guard let fragment = fragment else { return nil }
        
        return fragment.components(separatedBy: "&").reduce(into: [String: String]()) { (out, keyValuePair) in
            let pairComponents = keyValuePair.components(separatedBy: "=")
            let key = pairComponents.first?.removingPercentEncoding?.lowercased()
            let value = pairComponents.last?.removingPercentEncoding
            
            if let key = key, let value = value {
                out[key] = value
            }
        }
    }
    
    private func copyValue(from: [String: Any], fromKey: String, toMixpanelProperties: inout MixpanelProperties, toKey: String) {
        let value = from[fromKey]
        if let value = value as? MixpanelType {
            toMixpanelProperties[toKey] = value
        }
    }
    
    private func copyValue(from: BatchEventDispatcherPayload, fromKey: String, toMixpanelProperties: inout MixpanelProperties, toKey: String) {
        let value = from.customValue(forKey: fromKey)
        if let value = value as? MixpanelType {
            toMixpanelProperties[toKey] = value
        }
    }
    
    private func copyValue(from: URLComponents, fromKey: String, toMixpanelProperties: inout MixpanelProperties, toKey: String) {
        if let item = from.queryItems?.first(where: { fromKey.caseInsensitiveCompare($0.name) == .orderedSame }) {
            toMixpanelProperties[toKey] = item.value
        }
    }
}

//MARK: BatchEventDispatcherDelegate
extension BatchMixpanelSwiftDispatcher : BatchEventDispatcherDelegate {
    public func dispatchEvent(with type: BatchEventDispatcherType, payload: BatchEventDispatcherPayload) {
        var properties: Properties? = nil
        
        if BatchEventDispatcher.isNotificationEvent(type) {
            properties = self.notificationParams(fromPayload: payload)
        } else if BatchEventDispatcher.isMessagingEvent(type) {
            properties = self.inAppParams(fromPayload: payload)
        }
        
        if (!warnedAboutNil && self.mixpanelInstance == nil) {
            warnedAboutNil = true;
            print("BatchMixpanelObjcDispatcher - Cannot send event to Mixpanel as no instance has been configured. Did you set the mixpanelInstance property to your Mixpanel instance?")
        }
        
        mixpanelInstance?.track(event: type.mixpanelName, properties: properties)
    }
}

fileprivate extension BatchEventDispatcherType {
    var mixpanelName: String {
        switch self {
            case .notificationOpen:
                return "batch_notification_open"
            case .messagingShow:
                return "batch_in_app_show"
            case .messagingClose:
                return "batch_in_app_close"
            case .messagingAutoClose:
                return "batch_in_app_auto_close"
            case .messagingCloseError:
                return "batch_in_app_close_error"
            case .messagingWebViewClick:
                return "batch_in_app_webview_click"
            case .messagingClick:
                return "batch_in_app_click"
            @unknown default:
                return "batch_unknown"
        }
    }
}
