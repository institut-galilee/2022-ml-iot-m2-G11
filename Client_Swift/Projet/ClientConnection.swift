//
//  ClientConnection.swift
//  Projet
//
//  Created by HAJAR FAHSI on 18/01/2022.
//

//
//  ClientConnection.swift
//  rdncat
//
//  Created by HAJAR FAHSI on 15/01/2022.
//
import Foundation
import Network

@available(macOS 14.8.1, *)
class ClientConnection {

    let  nwConnection: NWConnection
    let queue = DispatchQueue(label: "Client connection Q")

    init(nwConnection: NWConnection) {
        self.nwConnection = nwConnection
    }

    var didStopCallback: ((Error?) -> Void)? = nil

    func start() {
        print("connection will start")
        nwConnection.stateUpdateHandler = stateDidChange(to:)
        nwConnection.start(queue: queue)
       
    }
    
    private func stateDidChange(to state: NWConnection.State)
    {
        switch state {
        case .waiting(let error):
            connectionDidFail(error: error)
        case .ready:
            print("Client connection ready")
        case .failed(let error):
            connectionDidFail(error: error)
        default:
            break
        }
    }

    func setupReceive() {
        nwConnection.receive(minimumIncompleteLength: 1, maximumLength: 65536)  {
            [self] (data, _, isComplete, error) in
            if let data = data, !data.isEmpty {
                let message = String(data: data, encoding: .utf8)
                print("the client did receive, data: \(data as NSData) string: \(message ?? "-" )")
            }
            if isComplete {
                self.connectionDidEnd()
            } else if let error = error {
                self.connectionDidFail(error: error)
            } else {
                self.setupReceive()
            }
        }
    }
    
    func send(data: Data) {
        nwConnection.send(content: data, completion: .contentProcessed( { error in
            if let error = error {
                self.connectionDidFail(error: error)
                return
            }
            //print("the client did send the data: \(data as NSData)")
        }))
    }

    func stop() {
        print("the client will stop")
        stop(error: nil)
    }

    private func connectionDidFail(error: Error) {
        print("the client did fail, error: \(error)")
        self.stop(error: error)
    }

    private func connectionDidEnd() {
        print("the client did end")
        self.stop(error: nil)
    }

    private func stop(error: Error?) {
        self.nwConnection.stateUpdateHandler = nil
        self.nwConnection.cancel()
        if let didStopCallback = self.didStopCallback {
            self.didStopCallback = nil
            didStopCallback(error)
        }
    }
}

