import QtQuick
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.kirigamiaddons.formcard as FormCard

Kirigami.ApplicationWindow {
    id: root
    width: 600
    height: 700

    Component {
        id: aboutsonicde
        FormCard.AboutKDEPage {}
    }

    Component {
        id: aboutpage
        FormCard.AboutPage {}
    }

    Component {
        id: settingspage
        SettingsPage {}
    }

    pageStack.initialPage: Kirigami.ScrollablePage {
        ColumnLayout {
            FormCard.FormCard {
                autoSeparators: true

                FormCard.FormButtonDelegate {
                    icon.name: "start-here-sonicde"
                    text: i18nc("@action:button", "About SonicDE Page")
                    onClicked: root.pageStack.layers.push(aboutsonicde)
                }

                FormCard.FormButtonDelegate {
                    icon.name: "applications-utilities"
                    text: i18nc("@action:button", "About Addons Example")
                    onClicked: root.pageStack.layers.push(aboutpage)
                }

                FormCard.FormButtonDelegate {
                    icon.name: "settings-configure"
                    text: i18nc("@action:button", "Single Settings Page")
                    onClicked: root.pageStack.layers.push(settingspage)
                }
            }
        }
    }
}
