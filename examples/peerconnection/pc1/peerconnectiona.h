#ifndef PEERCONNECTIONA_H
#define PEERCONNECTIONA_H

#include <QObject>

#include "simplepeerconnection.h"

class PeerConnectionA
        : public QObject
        , public SimplePeerConnection

{
    Q_OBJECT
public:
    PeerConnectionA(QObject *parent = nullptr);
    virtual ~PeerConnectionA() override;

Q_SIGNALS:
    void CreateOffered(QString type, QString sdp);

protected:
    void OnAddTrack(
        rtc::scoped_refptr<webrtc::RtpReceiverInterface> receiver,
        const std::vector<rtc::scoped_refptr<webrtc::MediaStreamInterface>>&
            streams) override;
    void OnRemoveTrack(
        rtc::scoped_refptr<webrtc::RtpReceiverInterface> receiver) override;
    void OnIceConnectionChange(
        webrtc::PeerConnectionInterface::IceConnectionState new_state) override;
    void OnIceCandidate(const webrtc::IceCandidateInterface* candidate) override;

    void OnSuccess(webrtc::SessionDescriptionInterface* desc) override;
    void OnFailure(webrtc::RTCError error) override;
};

#endif // PEERCONNECTIONA_H
