import SwiftUI

struct LogView: View {
    @State var log: String = ""
    
    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    Text(log)
                        .padding(.top)
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
                        UIPasteboard.general.string = log
                    } label: {
                        Label("Copy Output", systemImage: "doc.on.doc")
                    }
                }
            }
        }
    }
}
