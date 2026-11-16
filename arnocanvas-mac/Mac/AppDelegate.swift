import Cocoa
import WebKit

/// Finestra principale di ARNOCANVAS PROVA per Mac e menu a tendina.
/// © 2026 Maurizio Arnone. Tutti i diritti riservati.
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var window: NSWindow!
    private let controller = WebViewController()

    func applicationDidFinishLaunching(_ notification: Notification) {
        buildMenu()
        window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 1280, height: 800),
                          styleMask: [.titled, .closable, .miniaturizable, .resizable],
                          backing: .buffered, defer: false)
        window.title = "ARNOCANVAS PROVA"
        NSWindow.allowsAutomaticWindowTabbing = false
        window.tabbingMode = .disallowed
        window.minSize = NSSize(width: 720, height: 520)
        window.backgroundColor = NSColor(red: 0.051, green: 0.055, blue: 0.063, alpha: 1)
        window.contentViewController = controller
        window.setContentSize(NSSize(width: 1280, height: 800))
        window.center()
        window.setFrameAutosaveName("ArnoCanvasProvaWindow")
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }

    // MARK: - Menu

    @discardableResult
    private func add(_ menu: NSMenu, _ title: String, _ command: String,
                     _ key: String = "", _ mods: NSEvent.ModifierFlags = [.command]) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: #selector(WebViewController.menuCommand(_:)), keyEquivalent: key)
        item.keyEquivalentModifierMask = key.isEmpty ? [] : mods
        item.representedObject = command
        item.target = controller
        menu.addItem(item)
        return item
    }

    private func top(_ main: NSMenu, _ title: String, _ fill: (NSMenu) -> Void) -> NSMenu {
        let item = NSMenuItem()
        let menu = NSMenu(title: title)
        fill(menu)
        item.submenu = menu
        main.addItem(item)
        return menu
    }

    private func buildMenu() {
        let main = NSMenu()

        _ = top(main, "ARNOCANVAS") { m in
            m.addItem(withTitle: "Informazioni su ARNOCANVAS",
                      action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)), keyEquivalent: "")
            m.addItem(.separator())
            m.addItem(withTitle: "Nascondi ARNOCANVAS", action: #selector(NSApplication.hide(_:)), keyEquivalent: "h")
            m.addItem(.separator())
            m.addItem(withTitle: "Esci da ARNOCANVAS", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        }

        _ = top(main, "File") { m in
            add(m, "App e schermo…", "c:target", "o")
            m.addItem(.separator())
            add(m, "Invia le modifiche a Claude…", "m:claude", "e")
            add(m, "Importa modifiche…", "m:import", "i", [.command, .shift])
            add(m, "Elementi eliminati…", "m:deleted")
            m.addItem(.separator())
            add(m, "Ricarica l'app", "m:reload", "r")
            add(m, "Ripristina tutto…", "m:reset")
            m.addItem(.separator())
            m.addItem(withTitle: "Chiudi finestra", action: #selector(NSWindow.performClose(_:)), keyEquivalent: "w")
        }

        _ = top(main, "Modifica") { m in
            add(m, "Annulla", "c:undoB", "z")
            add(m, "Ripeti", "c:redoB", "z", [.command, .shift])
            m.addItem(.separator())
            m.addItem(withTitle: "Taglia", action: #selector(NSText.cut(_:)), keyEquivalent: "x")
            m.addItem(withTitle: "Copia", action: #selector(NSText.copy(_:)), keyEquivalent: "c")
            m.addItem(withTitle: "Incolla", action: #selector(NSText.paste(_:)), keyEquivalent: "v")
            m.addItem(withTitle: "Seleziona tutto", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a")
            m.addItem(.separator())
            add(m, "Nuovo elemento…", "c:bNew", "n")
            add(m, "Duplica", "c:bDup", "d")
            add(m, "Aspetto…", "c:bProp", "i")
            add(m, "Entra", "c:bIn")
            add(m, "Sposta in un altro riquadro…", "c:bMv")
            add(m, "Selezione multipla", "c:multiB")
            m.addItem(.separator())
            add(m, "Porta sopra", "q:#zord [data-z=up]", "]")
            add(m, "Porta sotto", "q:#zord [data-z=down]", "[")
            add(m, "In primo piano", "q:#zord [data-z=top]", "]", [.command, .shift])
            add(m, "In fondo", "q:#zord [data-z=bot]", "[", [.command, .shift])
        }

        _ = top(main, "Vista") { m in
            add(m, "① Riquadri", "q:.seg [data-l=P]", "1")
            add(m, "② Oggetti", "q:.seg [data-l=O]", "2")
            add(m, "▶ Usa", "q:.seg [data-l=U]", "3")
            m.addItem(.separator())
            add(m, "Ingrandisci", "c:zP", "=")
            add(m, "Rimpicciolisci", "c:zM", "-")
            add(m, "Adatta alla finestra", "c:zl", "0")
            m.addItem(.separator())
            add(m, "Griglia e aggancio…", "c:gridB", "g")
        }

        let winMenu = top(main, "Finestra") { m in
            m.addItem(withTitle: "Contrai", action: #selector(NSWindow.performMiniaturize(_:)), keyEquivalent: "m")
            m.addItem(withTitle: "Zoom", action: #selector(NSWindow.performZoom(_:)), keyEquivalent: "")
            let full = m.addItem(withTitle: "Schermo intero", action: #selector(NSWindow.toggleFullScreen(_:)), keyEquivalent: "f")
            full.keyEquivalentModifierMask = [.command, .control]
        }
        NSApp.windowsMenu = winMenu

        let helpMenu = top(main, "Aiuto") { m in
            add(m, "Come si usa ARNOCANVAS", "m:help", "?")
        }
        NSApp.helpMenu = helpMenu

        NSApp.mainMenu = main
    }
}
