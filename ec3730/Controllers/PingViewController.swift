//
//  PingViewController.swift
//  ec3730
//
//  Created by Zachary Gorak on 8/24/18.
//  Copyright © 2018 Zachary Gorak. All rights reserved.
//

import Foundation

import AddressURL
import SwiftyPing
import UIKit

import SwiftUI

@available(iOS 14.0, *)
struct PingNumberSettings: View {
    @Binding var numberOfPings: Int
    @Binding var indefinitely: Bool

    var numberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.maximum = 1000
        formatter.minimum = 1
        return formatter
    }

    var body: some View {
        Form {
            Section {
                Toggle("Indefinitely", isOn: $indefinitely)
            }
            if !indefinitely {
                Section {
                    Stepper(value: $numberOfPings, in: ClosedRange(1 ..< 1000)) {
                        HStack {
                            Text("Number")
                            TextField("\(numberOfPings)", value: $numberOfPings, formatter: numberFormatter).foregroundColor(.gray)
                        }
                    }

                    Picker("Number of pings", selection: $numberOfPings, content: {
                        ForEach(1 ..< 1000, id: \.self) { i in
                            Text("\(i)")
                                .tag(i)
                                .id(i)
                        }
                    }).pickerStyle(WheelPickerStyle())
                }
            }
        }.navigationTitle("Ping Count")
    }
}

@available(iOS 14.0, *)
struct PingSettings: View {
    @Binding var interval: Double
    @Binding var timeout: Double
    @Binding var pingIndefinitly: Bool
    @Binding var pingCount: Int
    @Binding var savePings: Bool
    @Binding var payloadSize: Int
    @Binding var enableTTL: Bool
    @Binding var ttl: Int

    var numberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.alwaysShowsDecimalSeparator = true
        formatter.minimumFractionDigits = 2
        return formatter
    }

    var payloadSizeNumberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.alwaysShowsDecimalSeparator = false
        formatter.minimumFractionDigits = 0
        formatter.minimum = 44
        formatter.maximum = 4096
        return formatter
    }

    var ttlNumberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.alwaysShowsDecimalSeparator = false
        formatter.minimumFractionDigits = 0
        formatter.minimum = 1
        formatter.maximum = 255
        return formatter
    }

    var body: some View {
        Form {
            // TextField("Number of pings", text: $numberOfPings)
            NavigationLink(
                destination: PingNumberSettings(numberOfPings: $pingCount, indefinitely: $pingIndefinitly),
                label: {
                    HStack {
                        Text("Ping Count")
                        Spacer()
                        if pingIndefinitly {
                            Text("Indefinitely").foregroundColor(.gray)
                        } else {
                            Text("\(pingCount)").foregroundColor(.gray)
                        }
                    }
                }
            )
            Section {
                Stepper(value: $interval, in: 0 ... 10.0, step: 0.1) {
                    HStack {
                        Text("Interval")
                        let str: LocalizedStringKey = "\(interval, specifier: "%.02f")"
                        TextField(str, value: $interval, formatter: numberFormatter).foregroundColor(.gray)
                    }
                }
                Stepper(value: $timeout, in: 0 ... 10, step: 0.5) {
                    HStack {
                        Text("Timeout")
                        let str: LocalizedStringKey = "\(timeout, specifier: "%.2f")"
                        TextField(str, value: $timeout, formatter: numberFormatter).foregroundColor(.gray)
                    }
                }
            }
            Section {
                Stepper(value: $payloadSize, in: 44 ... 4096, step: 1) {
                    HStack {
                        Text("Payload Size")
                        let str: LocalizedStringKey = "\(payloadSize, specifier: "%d")"
                        TextField(str, value: $payloadSize, formatter: payloadSizeNumberFormatter).foregroundColor(.gray)
                    }
                }
            }
            Section {
                Toggle("Use TTL", isOn: $enableTTL)
                if enableTTL {
                    Stepper(value: $ttl, in: 1 ... 255, step: 1) {
                        HStack {
                            Text("TTL")
                            let str: LocalizedStringKey = "\(ttl, specifier: "%d")"
                            TextField(str, value: $ttl, formatter: ttlNumberFormatter).foregroundColor(.gray)
                        }
                    }
                }
            }
            Section {
                Toggle("Save Pings", isOn: $savePings)
            }
            Button(action: {
                enableTTL = false
                ttl = 64
                payloadSize = 44
                interval = 0.5
                timeout = 5.0
                pingCount = 5
                pingIndefinitly = false
                savePings = true
            }, label: {
                HStack {
                    Spacer()
                    Text("Reset")
                    Spacer()
                }

            })
        }.navigationBarTitle("Ping Settings", displayMode: .inline)
    }
}

struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context _: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView, context _: UIViewRepresentableContext<Self>) { uiView.effect = effect }
}

@available(iOS 14.0, *)
struct PingSetView: View {
    var ping: PingSet

    var body: some View {
        if ping.pings.isEmpty {
            Text("No pings recorded")
        } else {
            List {
                ForEach(Array(ping.pings.sorted(by: { a, b in
                    a.sequenceNumber < b.sequenceNumber
                })), id: \.self) { ping in
                    HStack {
                        Text("#\(ping.sequenceNumber)")
                        if let error = ping.error {
                            Text("\(error)")
                        } else {
                            VStack(alignment: .leading) {
                                if let address = ping.ipAddress {
                                    Text("\(address)").font(.headline)
                                    Text("\(ping.byteCount) bytes")
                                }
                            }
                            Spacer()
                            Text("\(ping.duration * 1000, specifier: "%.02f") ms")
                        }
                    }
                }
            }.navigationTitle(ping.host)
        }
    }
}

@available(iOS 14.0, *)
struct PingSetList: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State var mode: EditMode = .inactive
    @FetchRequest(fetchRequest: PingSet.fetchAllRequest()) var pings: FetchedResults<PingSet>
    @State var isPresentigDeleteConfirm = false
    var body: some View {
        VStack {
            List {
                ForEach(pings) { ping in
                    NavigationLink(
                        destination: PingSetView(ping: ping),
                        label: {
                            VStack(alignment: .leading) {
                                HStack(alignment: .center) {
                                    Text("\(ping.host)").font(.headline)
                                    Spacer()
                                    Text("\(ping.pings.count)").font(.footnote).foregroundColor(.gray)
                                }
                                Text("\(ping.timestamp)").font(.caption)
                            }
                        }
                    )
                }.onDelete(perform: deleteItems)
            }.listStyle(PlainListStyle()).navigationTitle("History").toolbar {
                #if os(iOS)
                    EditButton()
                #endif
            }.toolbar { ToolbarItem(placement: .bottomBar, content: {
                if mode == .active, pings.count > 1 {
                    Button {
                        isPresentigDeleteConfirm.toggle()
                    } label: {
                        Text("Delete All")
                    }
                }
            }) }.confirmationDialog("Are you sure?",
                                    isPresented: $isPresentigDeleteConfirm, titleVisibility: .visible) {
                Button("Delete all \(pings.count) items?", role: .destructive) {
                    deleteAllItems()
                }
            } message: {
                Text("You cannot undo this action")
            }
        }.environment(\.editMode, $mode)
    }

    private func deleteItems(offsets: IndexSet) {
        viewContext.perform {
            withAnimation {
                offsets.map { pings[$0] }.forEach(viewContext.delete)
                _ = try? viewContext.save()
            }
        }
    }

    private func deleteAllItems() {
        viewContext.perform {
            withAnimation {
                for object in pings {
                    viewContext.delete(object)
                    try? viewContext.save()
                    mode = .inactive
                }
            }
        }
    }
}

struct DeferView<Content: View>: View {
    let content: () -> Content

    init(@ViewBuilder _ content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        content() // << everything is created here
    }
}

@available(iOS 14.0, *)
struct PingSwiftUIViewController: View {
    let persistenceController = PersistenceController.shared

    @State var text: String = ""

    @State var isPinging: Bool = false

    @State var entries = [String]()

    @AppStorage("ping.indefinitly") var pingIndefinity: Bool = false
    @AppStorage("ping.count") var pingCount: Int = 5
    @AppStorage("ping.payloadSize") var pingPayloadSize: Int = 44
    @AppStorage("ping.useTTL") var pingUseTTL: Bool = false
    @AppStorage("ping.ttl") var pingTTL: Int = 64
    @AppStorage("ping.timeout") var pingTimeout: Double = 5.0
    @AppStorage("ping.interval") var pingInterval: Double = 0.5
    @AppStorage("ping.save") var pingSave: Bool = true

    @State var showSettings: Bool = false

    var defaultPing = "google.com"

    @State var dismissKeyboard = UUID()

    @State var showAlert: Bool = false
    @State var alertMessage: String?
    @FetchRequest(fetchRequest: PingSet.fetchAllRequest(limit: 1)) var pings: FetchedResults<PingSet>

    var body: some View {
        VStack(alignment: .leading, spacing: 0.0) {
            ScrollViewReader { reader in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0.0) {
                        ForEach(0 ..< entries.count, id: \.self) { i in
                            Text(entries[i]).multilineTextAlignment(.leading).foregroundColor(.green).tag(i).font(Font.system(.footnote, design: .monospaced))
                        }.onChange(of: entries, perform: { _ in
                            withAnimation {
                                reader.scrollTo(entries.count - 1, anchor: .bottom)
                            }
                        })
                    }.padding()
                }
                .background(Color.black.ignoresSafeArea(.all, edges: .horizontal))
                // Fix for the content going above the navigation
                // See !92 for more information
                .padding(.top, 0.15)
                .onTapGesture {
                    dismissKeyboard = UUID()
                }
            }
            SourceUrlBarView(text: $text, refresh: nil, go: ping, defaultText: defaultPing, goText: "ping", isQuerying: $isPinging, cancel: cancel)
        }
        .navigationBarTitle("Ping", displayMode: .inline)
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarLeading, content: {
                Button(action: { showSettings.toggle() }, label: {
                    Image(systemName: "gear")
                })
            })
            ToolbarItem(placement: .navigationBarTrailing, content: {
                NavigationLink(
                    destination: PingSetList(),
                    label: {
                        Image(systemName: "clock")
                    }
                )
                .disabled(pings.isEmpty)
            })
        }).sheet(isPresented: $showSettings, content: {
            EZPanel {
                PingSettings(interval: $pingInterval, timeout: $pingTimeout, pingIndefinitly: $pingIndefinity, pingCount: $pingCount, savePings: $pingSave, payloadSize: $pingPayloadSize, enableTTL: $pingUseTTL, ttl: $pingTTL)
            }
        }).alert(isPresented: $showAlert, content: {
            Alert(title: Text("Error"), message: Text("\(alertMessage ?? "")"), dismissButton: .none)
        }) // GeometryReader
        .onDisappear(perform: {
            pinger?.stopPinging()
        })
        .background(Color(UIColor.systemGroupedBackground))
        .navigationViewStyle(StackNavigationViewStyle())
        .environment(\.managedObjectContext, persistenceController.container.viewContext) // NavigationView
    }

    func cancel() {
        dismissKeyboard = UUID()
        isPinging = false
        pinger?.stopPinging()
    }

    @State var pinger: SwiftyPing?

    func ping() {
        print("ping")
        dismissKeyboard = UUID()
        let saveThisSession = pingSave
        let text = text.isEmpty ? defaultPing : text
        guard let host = URL(string: text)?.absoluteString else {
            alertMessage = "Unable to create URL. Please try again."
            showAlert.toggle()
            return
        }
        var config = PingConfiguration(interval: pingInterval, with: pingTimeout)
        if pingUseTTL {
            config.timeToLive = pingTTL
        }
        config.payloadSize = pingPayloadSize
        var stopPinging = false
        let workGroup = DispatchGroup()
        workGroup.enter()
        DispatchQueue.global(qos: .userInitiated).async {
            if let pinger = try? SwiftyPing(host: host, configuration: config, queue: .global()) {
                self.pinger = pinger
                workGroup.leave()
            } else {
                alertMessage = "Unable to create ping. Please try again."
                showAlert.toggle()
                stopPinging = true
                workGroup.leave()
                return
            }
        }
        workGroup.notify(queue: .main) {
            if stopPinging {
                return
            }
            var ps: PingSet?
            if saveThisSession {
                ps = PingSet(context: persistenceController.container.viewContext, configuration: config)
                ps?.host = host
                try? ps?.managedObjectContext?.save()
            }

            if !pingIndefinity {
                pinger?.targetCount = pingCount
            }

            var count = 1

            var latencySum = 0.0
            var minLatency = Double.greatestFiniteMagnitude
            var maxLatency = Double.leastNormalMagnitude
            var errorCount = 0

            entries.append("PING " + host)

            pinger?.observer = { response in
                print(response)
                if saveThisSession {
                    let item = PingItem(context: persistenceController.container.viewContext, response: response)
                    ps?.pings.insert(item)
                    do {
                        try ps?.managedObjectContext?.save()
                    } catch {
                        print("error\(error)")
                    }
                }

                if let error = response.error {
                    errorCount += 1
                    entries.append(error.localizedDescription)
                } else {
                    let duration = response.duration
                    let latency = duration * 1000
                    latencySum += latency
                    if latency > maxLatency {
                        maxLatency = latency
                    }
                    if latency < minLatency {
                        minLatency = latency
                    }
                    entries.append("\(response.byteCount ?? 0) bytes from \(response.ipAddress ?? "") icmp_seq=\(response.sequenceNumber) time=\(latency) ms")
                }

                if !pingIndefinity, count >= pingCount {
                    pinger?.stopPinging()
                    isPinging = false

                    entries.append("--- \(host) ping statistics ---")

                    // 5 packets transmitted, 5 packets received, 0.0% packet loss
                    entries.append("\(count) packets transmitted, ")
                    let received = count - errorCount
                    entries.append("\(count - errorCount) received, ")
                    if count == received {
                        entries.append("0.0% packet loss")
                    } else if received == 0 {
                        entries.append("100% packet loss")
                    } else {
                        entries.append(String(format: "%0.1f%% packet loss", Double(received) / Double(count) * 100.0))
                    }

                    // round-trip min/avg/max/stddev = 14.063/21.031/28.887/4.718 ms
                    var stats = "ronnd-trip min/avg/max = "
                    if errorCount == count {
                        stats += "n/a"
                    } else {
                        let avg = latencySum / Double(count)
                        stats += String(format: "%0.3f/%0.3f/%0.4f ms", minLatency, avg, maxLatency)
                    }
                    entries.append("\(stats)\n")
                }
                count += 1
            }

            isPinging = true
            try? pinger?.startPinging()
        }
    }
}
