#include <stdio.h>
#include <string.h>
#include <omnetpp.h>

using namespace omnetpp;

class Workstation: public cSimpleModule {
protected:
    int connectionNum;
    virtual void forwardMessage(cMessage *msg);
    virtual void handleMessage(cMessage *msg) override;
};

class MasterWorkstation: public Workstation {
protected:
    virtual void initialize() override;
};

class ChildWorkstation: public Workstation {
protected:
    virtual void forwardMessage(cMessage *msg) override;
};

class MeshWorkstation: public Workstation {
protected:
    virtual void initialize() override;
};

Define_Module(Workstation);

Define_Module(MasterWorkstation);

Define_Module(ChildWorkstation);

Define_Module(MeshWorkstation);

void Workstation::forwardMessage(cMessage *msg) {

    // Send a packet to a random child.
    // We draw a random number between 0 and the size of gate `out[]'.
    // This behavior is default for any module with non-specific output
    int n = gateSize("out");
    int k = intuniform(0, n - 1);

    EV << "Forwarding message " << msg << " on port out[" << k << "]\n";

    send(msg, "out", k);

}

void Workstation::handleMessage(cMessage *msg) {
    forwardMessage(msg);
}

void MasterWorkstation::initialize() {
    // Boot the process scheduling the initial message as a self-message.
    char msgname[20];
    sprintf(msgname, "dummyTraffic");
    cMessage *msg = new cMessage(msgname);
    scheduleAt(0.0, msg);

}

void ChildWorkstation::forwardMessage(cMessage *msg) {

    // Return packet to master.
    // This is valid so long as in[#] corresponds to out[#] (true if assignments are made immediately)
    int n = gateSize("out");
    int k = msg->getArrivalGate()->getIndex();

    send(msg, "out", (k + 1) % n);  //sends msg to next (other) master node

}

void MeshWorkstation::initialize() {
    if (getIndex() == 0) {
        // Boot the process scheduling the initial message as a self-message.
        char msgname[20];
        sprintf(msgname, "dummyTraffic");
        cMessage *msg = new cMessage(msgname);
        scheduleAt(0.0, msg);

    }
}

/*
void BusMasterWorkstation::initialize() {
    // Boot the process scheduling the initial message as a self-message.
    char msgname[20];
    cMessage *msg = new cMessage(msgname);
    scheduleAt(0.0, msg);

}

void BusMasterWorkstation::handleMessage(cMessage *msg) {
    forwardMessage(msg);
}

void BusMasterWorkstation::forwardMessage(cMessage *msg) {
    int n = gateSize("out");
    for (int i = 0; i < n; i++) {
        send(msg, "out", i);
    }

}

void BusChildWorkstation::forwardMessage(cMessage *msg) {
}
*/
