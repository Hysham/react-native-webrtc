import { NativeModules } from 'react-native';
import MediaStreamTrack from './MediaStreamTrack';
import RTCRtpCapabilities, { getCapabilities } from './RTCRtpCapabilities';

const { WebRTCModule } = NativeModules;

export default class RTCRtpReceiver {
    _id: string;
    _peerConnectionId: number;
    _track: MediaStreamTrack;

    constructor(info: { peerConnectionId: number, id: string, track: MediaStreamTrack }) {
        this._id = info.id;
        this._peerConnectionId = info.peerConnectionId;
        this._track = info.track;
    }

    static getCapabilities(kind: "audio" | "video"): RTCRtpCapabilities {

        if (kind == "audio") {
            throw new Error("Unimplemented capabilities for audio");
        }
        const capabilities = getCapabilities('receiver');
        if (!capabilities)
            throw new Error('Capabilities is not yet initialized');
        return capabilities;
    }

    get id() {
        return this._id;
    }

    get track() {
        return this._track;
    }
}