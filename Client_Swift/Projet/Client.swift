//
//  Client.swift
//  Projet
//
//  Created by HAJAR FAHSI on 18/01/2022.
//

//
//  Client.swift
//  rdncat
//
//  Created by HAJAR FAHSI on 15/01/2022.
//
import Foundation
import Network

@available(macOS 14.8.1, *)
class Client {
    let connection: ClientConnection
    let host: NWEndpoint.Host
    let port: NWEndpoint.Port

    init(host: String, port: UInt16) {
        self.host = NWEndpoint.Host(host)
        self.port = NWEndpoint.Port(rawValue: port)!
        let nwConnection = NWConnection(host: self.host, port: self.port, using: .tcp)
        connection = ClientConnection(nwConnection: nwConnection)
    }

    func start() {
        print("Client started \(host) \(port)")
        connection.didStopCallback = didStopCallback(error:)
        connection.start()
    }

    func stop() {
        connection.stop()
    }

    func send(data: Data) {
        connection.send(data: data)
    }
    
    func receive(){
        connection.setupReceive()
    }
    

    func didStopCallback(error: Error?) {
        if error == nil {
            exit(EXIT_SUCCESS)
        } else {
            exit(EXIT_FAILURE)
        }
    }
}

