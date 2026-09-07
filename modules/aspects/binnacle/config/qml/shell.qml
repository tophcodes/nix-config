import QtQuick
import Quickshell
import Quickshell.Io

ShellRoot {
    // Toggled from Hyprland: qs -c binnacle ipc call sheet toggle
    IpcHandler {
        target: "sheet"

        function toggle(): void {
            sheet.active = !sheet.active;
        }

        function show(): void {
            sheet.active = true;
        }

        function hide(): void {
            sheet.active = false;
        }
    }

    // The daemon holds no surface while the sheet is closed, so the sheet also
    // re-reads its files on every open.
    LazyLoader {
        id: sheet

        component: Component {
            Sheet {
                onDismissed: sheet.active = false
            }
        }
    }
}
