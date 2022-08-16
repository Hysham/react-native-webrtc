#import <objc/runtime.h>

#import <React/RCTBridge.h>
#import <React/RCTBridgeModule.h>

#import <WebRTC/RTCRtpSender.h>
#import <WebRTC/RTCRtpReceiver.h>

#import "WebRTCModule.h"
#import "SerializeUtils.h"

@implementation WebRTCModule (Transceivers)

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(senderGetCapabilities)
{
    __block id params;

    dispatch_sync(self.workerQueue, ^{
        params = [NSMutableString new];
        [params appendString:@"{ \"codecs\" :["];

        for(RTCVideoCodecInfo * videoCodecInfo in [self.encoderFactory supportedCodecs]) {
            [params appendString:@"{ \"mimeType\": "];
            [params appendString:[NSString stringWithFormat:@"\"video/%@\"", videoCodecInfo.name]];
            [params appendString:@"},"];
        }
 
        [params appendString:@"] }"];
    });

    return [[NSString stringWithString:params] stringByReplacingOccurrencesOfString:@"},]" withString:@"}]"];
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(receiverGetCapabilities)
{
   __block id params;

    dispatch_sync(self.workerQueue, ^{
        params = [NSMutableString new];
        [params appendString:@"{ \"codecs\" :["];

        for(RTCVideoCodecInfo * videoCodecInfo in [self.decoderFactory supportedCodecs]) {
            [params appendString:@"{ \"mimeType\": "];
            [params appendString:[NSString stringWithFormat:@"\"video/%@\"", videoCodecInfo.name]];
            [params appendString:@"},"];
        }
 
        [params appendString:@"] }"];
    });

    return [[NSString stringWithString:params] stringByReplacingOccurrencesOfString:@"},]" withString:@"}]"];
}

RCT_EXPORT_METHOD(senderReplaceTrack:(nonnull NSNumber *) objectID
                            senderId:(NSString *)senderId
                            trackId:(NSString *)trackId
                            resolver:(RCTPromiseResolveBlock)resolve
                            rejecter:(RCTPromiseRejectBlock)reject)
{
    dispatch_sync(self.workerQueue, ^{
        RTCPeerConnection *peerConnection = self.peerConnections[objectID];

        if (peerConnection == nil) {
            RCTLogWarn(@"PeerConnection %@ not found", objectID);
            reject(@"E_INVALID", @"Peer Connection is not initialized", nil);
        }

        RTCRtpTransceiver *transceiver = nil;
        for (RTCRtpTransceiver *t in peerConnection.transceivers) {
                if (t.sender.senderId == senderId) {
                    transceiver = t;
                    break;
                }
        }

        if (transceiver == nil) {
            RCTLogWarn(@"senderReplaceTrack() transceiver is null");
            reject(@"E_INVALID", @"Could not get transceive", nil);
        }
        
        RTCRtpSender *sender = transceiver.sender;
        RTCMediaStreamTrack *track = self.localTracks[trackId];
        [sender setTrack:track];
        resolve(@true);
    });
}

RCT_EXPORT_METHOD(senderSetParameters:(nonnull NSNumber *) objectID
                            senderId:(NSString *)senderId
                            options:(NSDictionary *)options
                            resolver:(RCTPromiseResolveBlock)resolve
                            rejecter:(RCTPromiseRejectBlock)reject)
{
    dispatch_sync(self.workerQueue, ^{
        RTCPeerConnection *peerConnection = self.peerConnections[objectID];

        if (peerConnection == nil) {
            RCTLogWarn(@"PeerConnection %@ not found", objectID);
            reject(@"E_INVALID", @"Peer Connection is not initialized", nil);
        }

        RTCRtpTransceiver *transceiver = nil;
        for (RTCRtpTransceiver *t in peerConnection.transceivers) {
            if (t.sender.senderId == senderId) {
                transceiver = t;
                break;
            }
        }

        if (transceiver == nil) {
            RCTLogWarn(@"senderSetParameters() transceiver is null");
            reject(@"E_INVALID", @"Could not get transceive", nil);
        }
    });
}

RCT_EXPORT_METHOD(transceiverSetDirection:(nonnull NSNumber *) objectID
                            senderId:(NSString *)senderId
                            direction:(NSNumber *)direction)
{
    dispatch_sync(self.workerQueue, ^{
        RTCPeerConnection *peerConnection = self.peerConnections[objectID];

        if (peerConnection == nil) {
            RCTLogWarn(@"PeerConnection %@ not found", objectID);
            return;
        }

        RTCRtpTransceiver *transceiver = nil;
        for (RTCRtpTransceiver *t in peerConnection.transceivers) {
            if (t.sender.senderId == senderId) {
                transceiver = t;
                break;
            }
        }

        if (transceiver == nil) {
            RCTLogWarn(@"senderSetParameters() transceiver is null");
            return;
        }
    });
}

RCT_EXPORT_METHOD(transceiverStop:(nonnull NSNumber *) objectID
                            senderId:(NSString *)senderId)
{
     dispatch_sync(self.workerQueue, ^{
        RTCPeerConnection *peerConnection = self.peerConnections[objectID];

        if (peerConnection == nil) {
            RCTLogWarn(@"PeerConnection %@ not found", objectID);
            return;
        }

        RTCRtpTransceiver *transceiver = nil;
        for (RTCRtpTransceiver *t in peerConnection.transceivers) {
            if (t.sender.senderId == senderId) {
                transceiver = t;
                break;
            }
        }

        if (transceiver == nil) {
            RCTLogWarn(@"senderSetParameters() transceiver is null");
            return;
        }

        [transceiver stopInternal];
        [self sendEventWithName:kEventTransceiverStopSuccessful
                              body:@{
                                @"peerConnectionId": objectID,
                                @"transceiverId": senderId
                              }];
    });
}

@end
