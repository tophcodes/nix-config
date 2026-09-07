import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
    id: root

    // `closed` collides with a QWindow property change signal.
    signal dismissed

    property var sheets: []

    // Everything is sized in these units so the sheet stays readable on a
    // 4K output at scale 1 and does not turn giant on a 1080p one.
    readonly property real u: root.screen ? Math.max(1, root.screen.height / 1080) : 1

    readonly property color bg: "#ee12161c"
    readonly property color fg: "#dfe4ea"
    readonly property color dim: "#93a0af"
    readonly property color accent: "#7fb3d5"
    readonly property color keyFg: "#e3c07b"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    WlrLayershell.namespace: "binnacle-sheet"
    exclusionMode: ExclusionMode.Ignore
    anchors {
        left: true
        right: true
        top: true
        bottom: true
    }
    color: root.bg

    // Set once rather than bound: reassigning `screen` on a mapped layer
    // surface tears it down, and focusedMonitor changes while the sheet is up.
    Component.onCompleted: {
        const focused = Hyprland.focusedMonitor;
        if (!focused)
            return;
        const match = Quickshell.screens.find(s => s.name === focused.name);
        if (match)
            root.screen = match;
    }

    Process {
        running: true
        command: [Quickshell.env("BINNACLE_SHEETS") || "binnacle-sheets"]

        stdout: StdioCollector {
            onStreamFinished: root.sheets = JSON.parse(this.text)
        }
    }

    FocusScope {
        anchors.fill: parent
        focus: true

        Keys.onEscapePressed: root.dismissed()

        Flickable {
            anchors.fill: parent
            anchors.margins: 32 * root.u
            contentHeight: content.implicitHeight
            clip: true

            ColumnLayout {
                id: content

                width: parent.width
                spacing: 26 * root.u

                Repeater {
                    model: root.sheets

                    ColumnLayout {
                        required property var modelData

                        Layout.fillWidth: true
                        spacing: 10 * root.u

                        Text {
                            text: modelData.title
                            color: root.fg
                            font.pixelSize: 21 * root.u
                            font.bold: true
                        }

                        Flow {
                            Layout.fillWidth: true
                            spacing: 26 * root.u

                            Repeater {
                                model: modelData.groups

                                ColumnLayout {
                                    required property var modelData

                                    width: 460 * root.u
                                    spacing: 3 * root.u

                                    Text {
                                        text: modelData.name
                                        color: root.accent
                                        font.pixelSize: 14 * root.u
                                        font.bold: true
                                        bottomPadding: 3 * root.u
                                    }

                                    Repeater {
                                        model: modelData.entries

                                        RowLayout {
                                            required property var modelData

                                            Layout.fillWidth: true
                                            spacing: 10 * root.u

                                            Text {
                                                text: modelData.keys
                                                color: root.keyFg
                                                font.family: "monospace"
                                                font.pixelSize: 13 * root.u
                                                Layout.minimumWidth: 150 * root.u
                                            }

                                            Text {
                                                text: modelData.note ? modelData.desc + "  (" + modelData.note + ")" : modelData.desc
                                                color: modelData.note ? root.dim : root.fg
                                                font.pixelSize: 13 * root.u
                                                elide: Text.ElideRight
                                                Layout.fillWidth: true
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
