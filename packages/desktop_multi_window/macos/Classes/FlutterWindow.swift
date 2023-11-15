//
//  FlutterWindow.swift
//  flutter_multi_window
//
//  Created by Bin Yang on 2022/1/10.
//
import Cocoa
import FlutterMacOS
import Foundation

class BaseFlutterWindow: NSObject {
  private let window: NSWindow
  let windowChannel: WindowChannel

  init(window: NSWindow, channel: WindowChannel) {
    self.window = window
    self.windowChannel = channel
    super.init()
  }

  func show() {
    window.makeKeyAndOrderFront(nil)
    NSApp.activate(ignoringOtherApps: true)
  }

  func hide() {
    window.orderOut(nil)
  }

  func center() {
    window.center()
  }

  func setFrame(frame: NSRect) {
    window.setFrame(frame, display: false, animate: true)
  }

  func setTitle(title: String) {
    window.title = title
  }

  func resizable(resizable: Bool) {
    if resizable {
      window.styleMask.insert(.resizable)
    } else {
      window.styleMask.remove(.resizable)
    }
  }

  func close() {
    window.close()
  }

  func setFrameAutosaveName(name: String) {
    window.setFrameAutosaveName(name)
  }
}

class FlutterWindow: BaseFlutterWindow {
  let windowId: Int64

  let window: NSWindow

  let timer: Timer

  weak var delegate: WindowManagerDelegate?

  init(id: Int64, arguments: String) {
    windowId = id
    let windowF = NSWindow(
      contentRect: NSRect(x: 0, y: 0, width: 480, height: 270),
      styleMask: [.miniaturizable, .closable, .resizable, .titled],
      backing: .buffered, defer: false)
    let project = FlutterDartProject()
    project.dartEntrypointArguments = ["multi_window", "\(windowId)", arguments]
    let flutterViewController = FlutterViewController(project: project)
    windowF.contentViewController = flutterViewController

    let plugin = flutterViewController.registrar(forPlugin: "FlutterMultiWindowPlugin")
    FlutterMultiWindowPlugin.registerInternal(with: plugin)
    let windowChannel = WindowChannel.register(with: plugin, windowId: id)
    // Give app a chance to register plugin.
    FlutterMultiWindowPlugin.onWindowCreatedCallback?(flutterViewController)

    timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
      windowF.contentView?.needsDisplay = true
    }
    timer.tolerance = 0.2

    window = windowF

    super.init(window: windowF, channel: windowChannel)

    window.delegate = self
    window.isReleasedWhenClosed = false
    window.titleVisibility = .visible
    window.titlebarAppearsTransparent = false
  }

  deinit {
    debugPrint("release window resource")
    timer.invalidate()
    window.delegate = nil
    if let flutterViewController = window.contentViewController as? FlutterViewController {
      flutterViewController.engine.shutDownEngine()
    }
    window.contentViewController = nil
    window.windowController = nil
  }
}

extension FlutterWindow: NSWindowDelegate {
  func windowWillClose(_ notification: Notification) {
    delegate?.onClose(windowId: windowId)
  }

  func windowShouldClose(_ sender: NSWindow) -> Bool {
    delegate?.onClose(windowId: windowId)
    return true
  }
}
