//
//  LogView.swift
//  dirtyZero
//
//  Created by lunginspector on 4/17/26.
//

import SwiftUI
import PartyUI

struct LogView: View {
    @State var log: String = ""
    
    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    Text(log)
                        .font(.system(size: 10, weight: .regular, design: .monospaced))
                        .multilineTextAlignment(.leading)
                    Spacer()
                        .id(0)
                }
                .onAppear {
                    pipe.fileHandleForReading.readabilityHandler = { fileHandle in
                        let data = fileHandle.availableData
                        if data.isEmpty  { // end-of-file condition
                            fileHandle.readabilityHandler = nil
                            sema.signal()
                        } else {
                            log.append(String(data: data, encoding: .utf8)!)
                            DispatchQueue.main.async {
                                proxy.scrollTo(0)
                            }
                        }
                    }
                    // Redirect
                    // print("Redirecting stdout")
                    setvbuf(stdout, nil, _IONBF, 0)
                    dup2(pipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)
                }
                .contextMenu {
                    Button {
                        Haptic.shared.play(.soft)
                        UIPasteboard.general.string = log
                    } label: {
                        Label("Copy Output", systemImage: "doc.on.doc")
                    }
                    
                    Button {
                        do {
                            let formatter = DateFormatter()
                            formatter.dateFormat = "MM-dd-yyyy-HHmmss"
                            let date = formatter.string(from: Date())
                            
                            let tempURL = URL.temporaryDirectory.appendingPathComponent("dirtyZero-Log-\(date)").appendingPathExtension("txt")
                            guard let data = log.data(using: .utf8) else {
                                throw "failed to create data from log string"
                            }
                            
                            try data.write(to: tempURL)
                            presentShareSheet(with: tempURL)
                        } catch {
                            print("[*] failed to export logs: \(error)")
                        }
                    } label: {
                        Label("Export Logs", systemImage: "square.and.arrow.up")
                    }
                }
            }
        }
    }
}
