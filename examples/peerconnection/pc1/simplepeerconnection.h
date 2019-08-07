#ifndef SIMPLEPEERCONNECTION_H
#define SIMPLEPEERCONNECTION_H

#include "api/create_peerconnection_factory.h"
#include "api/mediastreaminterface.h"

class SimplePeerConnection : public webrtc::PeerConnectionObserver,
        public webrtc::CreateSessionDescriptionObserver
{
public:
    SimplePeerConnection();
    ~SimplePeerConnection() override;

    static bool InitPeerConnectionFactory();
    static void ClearPeerConnectionFactory();
    webrtc::VideoTrackInterface* GetVideoTrack();
    webrtc::PeerConnectionInterface* GetPeerConnection();

    bool CreatePeerConnection();
    void DeletePeerConnection();
    void CreateTracks();
    void AddTracks();
    void CreateOffer();

protected:
    std::unique_ptr<cricket::VideoCapturer> OpenVideoCaptureDevice();


protected:
    //
    // PeerConnectionObserver implementation.
    //
    void OnSignalingChange(
            webrtc::PeerConnectionInterface::SignalingState new_state) override {}
    void OnAddTrack(
        rtc::scoped_refptr<webrtc::RtpReceiverInterface> receiver,
        const std::vector<rtc::scoped_refptr<webrtc::MediaStreamInterface>>&
            streams) override {}
    void OnRemoveTrack(
        rtc::scoped_refptr<webrtc::RtpReceiverInterface> receiver) override {}
    void OnDataChannel(
        rtc::scoped_refptr<webrtc::DataChannelInterface> channel) override {}
    void OnRenegotiationNeeded() override {}
    void OnIceConnectionChange(
        webrtc::PeerConnectionInterface::IceConnectionState new_state) override {}
    void OnIceGatheringChange(
        webrtc::PeerConnectionInterface::IceGatheringState new_state) override {}
    void OnIceCandidate(const webrtc::IceCandidateInterface* candidate) override {}
    void OnIceConnectionReceivingChange(bool receiving) override {}

    // CreateSessionDescriptionObserver implementation.
    void OnSuccess(webrtc::SessionDescriptionInterface* desc) override {}
    void OnFailure(webrtc::RTCError error) override {}

protected:
    rtc::scoped_refptr<webrtc::AudioTrackInterface> audio_track_;
    rtc::scoped_refptr<webrtc::VideoTrackInterface> video_track_;
    rtc::scoped_refptr<webrtc::PeerConnectionInterface> peer_connection_;

    static std::unique_ptr<rtc::Thread> s_worker_thread;
    static std::unique_ptr<rtc::Thread> s_signaling_thread;
    static rtc::scoped_refptr<webrtc::PeerConnectionFactoryInterface>
                                        s_peer_connection_factory;
};

#endif // SIMPLEPEERCONNECTION_H