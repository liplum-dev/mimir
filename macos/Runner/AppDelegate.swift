import Cocoa
import FlutterMacOS
import file_open_handler

@NSApplicationMain
class AppDelegate: FlutterAppDelegate {
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func application(_ sender: NSApplication, openFile filename: String) -> Bool {
    FileOpenHandlerPlugin.instance.handleFileOpen(pathname: filename);
    // Return true if your app opened the file successfully, false otherwise
    return true
  }
}
