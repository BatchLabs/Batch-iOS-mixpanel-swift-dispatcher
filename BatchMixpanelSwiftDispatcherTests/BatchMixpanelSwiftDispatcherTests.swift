//
//  BatchMixpanelSwiftDispatcherTests.swift
//  BatchMixpanelSwiftDispatcherTests
//
//  Copyright © 2020 Batch. All rights reserved.
//

import Foundation
import InstantMock
import Batch
import struct Mixpanel.Properties

@testable import BatchMixpanelSwiftDispatcher

import XCTest

class BatchMixpanelSwiftDispatcherTests : XCTestCase {
    
    var dispatcher: BatchMixpanelSwiftDispatcher! = nil
    var mixpanelMock: MixpanelInstanceMock! = nil
    
    override func setUp() {
        super.setUp()
        
        mixpanelMock = MixpanelInstanceMock()
        dispatcher = BatchMixpanelSwiftDispatcher.instance
        dispatcher.mixpanelInstance = mixpanelMock
    }
    
    override func tearDown() {
        dispatcher.mixpanelInstance = nil
        mixpanelMock = nil
    }
    
    //MARK: Notification tests
    
    func testPushNoData() {
        let testPayload = PayloadMock()
        
        dispatcher.dispatchEvent(with: .notificationOpen, payload: testPayload)

        expectTrack(event: "batch_notification_open", properties: [
            "$source": "batch",
            "medium": "push"
        ])
    }
    
    func testNotificationDeeplinkQueryVars() {
        let testPayload = PayloadMock()
        testPayload.deeplink = "https://batch.com?utm_source=batchsdk&utm_medium=push-batch&utm_campaign=yoloswag&utm_content=button1"
        
        dispatcher.dispatchEvent(with: .notificationOpen, payload: testPayload)

        expectTrack(event: "batch_notification_open", properties: [
            "$source": "batch",
            "utm_campaign": "yoloswag",
            "utm_medium": "push-batch",
            "utm_content": "button1",
            "utm_source": "batchsdk",
        ])
    }
    
    func testNotificationDeeplinkQueryVarsEncode() {
        let testPayload = PayloadMock()
        testPayload.deeplink = "https://batch.com?utm_source=%5Bbatchsdk%5D&utm_medium=push-batch&utm_campaign=yoloswag&utm_content=button1"
        
        dispatcher.dispatchEvent(with: .notificationOpen, payload: testPayload)

        expectTrack(event: "batch_notification_open", properties: [
            "$source": "batch",
            "utm_campaign": "yoloswag",
            "utm_medium": "push-batch",
            "utm_content": "button1",
            "utm_source": "[batchsdk]",
        ])
    }
    
    func testNotificationDeeplinkFragmentVars() {
        let testPayload = PayloadMock()
        testPayload.deeplink = "https://batch.com#utm_source=batch-sdk&utm_medium=pushbatch01&utm_campaign=154879548754&utm_content=notif001"
        
        dispatcher.dispatchEvent(with: .notificationOpen, payload: testPayload)

        expectTrack(event: "batch_notification_open", properties: [
            "$source": "batch",
            "utm_campaign": "154879548754",
            "utm_medium": "pushbatch01",
            "utm_content": "notif001",
            "source": "batch-sdk",
        ])
    }
    
    func testNotificationDeeplinkNonTrimmed() {
        let testPayload = PayloadMock()
        testPayload.deeplink = "    \n     https://batch.com#utm_source=batch-sdk&utm_medium=pushbatch01&utm_campaign=154879548754&utm_content=notif001     \n    "
        
        dispatcher.dispatchEvent(with: .notificationOpen, payload: testPayload)

        expectTrack(event: "batch_notification_open", properties: [
            "$source": "batch",
            "utm_campaign": "154879548754",
            "utm_medium": "pushbatch01",
            "utm_content": "notif001",
            "source": "batch-sdk",
        ])
    }
    
    func testNotificationDeeplinkFragmentVarsEncode() {
        let testPayload = PayloadMock()
        testPayload.deeplink = "https://batch.com/test#utm_source=%5Bbatch-sdk%5D&utm_medium=pushbatch01&utm_campaign=154879548754&utm_content=notif001"
        
        dispatcher.dispatchEvent(with: .notificationOpen, payload: testPayload)

        expectTrack(event: "batch_notification_open", properties: [
            "$source": "batch",
            "utm_campaign": "154879548754",
            "utm_medium": "pushbatch01",
            "utm_content": "notif001",
            "source": "batch-sdk",
        ])
    }
    
    func testNotificationCustomPayload() {
        let testPayload = PayloadMock()
        testPayload.deeplink = "https://batch.com#utm_source=batch-sdk&utm_medium=pushbatch01&utm_campaign=154879548754&utm_content=notif001"
        testPayload.customPayload = [
            "utm_medium": "654987",
            "utm_source": "jesuisuntest",
            "utm_campaign": "heinhein",
            "utm_content": "allo118218",
        ] as [AnyHashable: AnyObject]
        
        dispatcher.dispatchEvent(with: .notificationOpen, payload: testPayload)

        expectTrack(event: "batch_notification_open", properties: [
            "$source": "batch",
            "utm_medium": "654987",
            "utm_source": "jesuisuntest",
            "utm_campaign": "heinhein",
            "utm_content": "allo118218",
        ])
    }
    
    func testNotificationDeeplinkPriority() {
        let testPayload = PayloadMock()
        testPayload.deeplink = "https://batch.com?utm_source=batchsdk&utm_campaign=yoloswag#utm_source=batch-sdk&utm_medium=pushbatch01&utm_campaign=154879548754&utm_content=notif001"
        testPayload.customPayload = [
            "utm_medium": "654987",
        ] as [AnyHashable: AnyObject]
        
        dispatcher.dispatchEvent(with: .notificationOpen, payload: testPayload)

        expectTrack(event: "batch_notification_open", properties: [
            "$source": "batch",
            "utm_medium": "654987",
            "utm_source": "batchsdk",
            "utm_campaign": "yoloswag",
            "utm_content": "notif001",
        ])
    }
    
    //MARK: In-App tests
    
    func testInAppNoData() {
        let testPayload = PayloadMock()
        
        dispatcher.dispatchEvent(with: .messagingShow, payload: testPayload)

        expectTrack(event: "batch_in_app_show", properties: [
            "$source": "batch",
            "utm_medium": "in-app",
        ])
    }
    
    func testInAppTrackingID() {
        let testPayload = PayloadMock()
        testPayload.trackingId = "jesuisuntrackingid"
        
        dispatcher.dispatchEvent(with: .messagingShow, payload: testPayload)

        expectTrack(event: "batch_in_app_show", properties: [
            "$source": "batch",
            "utm_medium": "in-app",
            "utm_campaign": "jesuisuntrackingid",
            "batch_tracking_id": "jesuisuntrackingid",
        ])
    }
    
    func testInAppDeeplinkContentQueryVars() {
        let testPayload = PayloadMock()
        testPayload.deeplink = "https://batch.com/test-ios?utm_content=yoloswag"
        
        dispatcher.dispatchEvent(with: .messagingClick, payload: testPayload)

        expectTrack(event: "batch_in_app_click", properties: [
            "$source": "batch",
            "utm_medium": "in-app",
            "utm_content": "yoloswag",
        ])
    }
    
    func testInAppDeeplinkContentQueryVarsUppercase() {
        let testPayload = PayloadMock()
        testPayload.deeplink = "https://batch.com/test-ios?UtM_coNTEnt=yoloswag"
        
        dispatcher.dispatchEvent(with: .messagingClick, payload: testPayload)

        expectTrack(event: "batch_in_app_click", properties: [
            "$source": "batch",
            "utm_medium": "in-app",
            "utm_content": "yoloswag",
        ])
    }
    
    func testInAppDeeplinkFragmentQueryVars() {
        let testPayload = PayloadMock()
        testPayload.deeplink = "https://batch.com/test-ios#utm_content=yoloswag2"
        
        dispatcher.dispatchEvent(with: .messagingClick, payload: testPayload)

        expectTrack(event: "batch_in_app_click", properties: [
            "$source": "batch",
            "utm_medium": "in-app",
            "utm_content": "yoloswag2",
        ])
    }
    
    func testInAppDeeplinkFragmentQueryVarsUppercase() {
        let testPayload = PayloadMock()
        testPayload.deeplink = "https://batch.com/test-ios#uTm_CoNtEnT=yoloswag2"
        
        dispatcher.dispatchEvent(with: .messagingClick, payload: testPayload)

        expectTrack(event: "batch_in_app_click", properties: [
            "$source": "batch",
            "utm_medium": "in-app",
            "utm_content": "yoloswag2",
        ])
    }
    
    func testInAppDeeplinkContentPriority() {
        let testPayload = PayloadMock()
        testPayload.deeplink = "https://batch.com/test-ios?utm_content=testprio#utm_content=yoloswag2"
        
        dispatcher.dispatchEvent(with: .messagingClose, payload: testPayload)

        expectTrack(event: "batch_in_app_close", properties: [
            "$source": "batch",
            "utm_medium": "in-app",
            "utm_content": "testprio",
        ])
    }
    
    func testInAppDeeplinkContentNoId() {
        let testPayload = PayloadMock()
        testPayload.deeplink = "https://batch.com?utm_content=jesuisuncontent"
        
        dispatcher.dispatchEvent(with: .messagingClose, payload: testPayload)

        expectTrack(event: "batch_in_app_close", properties: [
            "$source": "batch",
            "utm_medium": "in-app",
            "utm_content": "jesuisuncontent",
        ])
    }
}

extension BatchMixpanelSwiftDispatcherTests {
    func expectTrack(event: String?, properties: Properties?, _ function: String = #function) {
        mixpanelMock.expect().call(
            mixpanelMock.track(event: Arg.eq(event), properties: Arg.eq(properties))
        )
    }
}

class MixpanelInstanceMock: Mock, MixpanelInstanceDispatcherProtocol {
    
    func track(event: String?, properties: Properties?) {
        super.call(event, properties)
    }
    
}

class PayloadMock: BatchEventDispatcherPayload {
    var trackingId: String?
    
    var deeplink: String?
    
    var isPositiveAction: Bool = false
    
    var sourceMessage: BatchMessage?
    
    var notificationUserInfo: [AnyHashable : Any]?
    
    var customPayload: [AnyHashable: AnyObject]?
    
    func customValue(forKey key: String) -> NSObject? {
        return customPayload?[key] as? NSObject
    }
    
}
