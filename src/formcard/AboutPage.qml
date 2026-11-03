// SPDX-FileCopyrightText: 2018 Aleix Pol Gonzalez <aleixpol@blue-systems.com>
// SPDX-FileCopyrightText: 2021 Carl Schwan <carl@carlschwan.eu>
// SPDX-License-Identifier: LGPL-2.0-or-later

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Controls.Basic as Basic
import QtQuick.Templates as T
import QtQuick.Window
import QtQuick.Layouts
import org.kde.kirigamiaddons.private
import org.kde.kirigami as Kirigami
import org.kde.kirigamiaddons.components as KirigamiComponents
import org.kde.kirigamiaddons.formcard as FormCardModule
import org.kde.coreaddons as Core

import "private" as Private

/*!
   \qmltype AboutPage
   \inqmlmodule org.kde.kirigamiaddons.formcard
   \brief An AboutPage that displays the about data using Form components.

   This component consists of an internationalized "About" page with the
   metadata of your program.

   It allows one to show the copyright notice of the application together with
   the contributors and some information of which platform it's running on.

   \since 0.11.0
 */
FormCardPage {
    id: page

    /*!
       \brief This property holds an object with the same shape as KAboutData.

       Set this property to either a KAboutData instance exposed from C++, or directly via a JSON object.

       Example usage:
       \code{json}
       aboutData: {
          "displayName" : "KirigamiApp",
          "productName" : "kirigami/app",
          "componentName" : "kirigamiapp",
          "shortDescription" : "A Kirigami example",
          "homepage" : "",
          "bugAddress" : "submit@bugs.kde.org",
          "version" : "5.14.80",
          "otherText" : "",
          "authors" : [
              {
                  "name" : "...",
                  "task" : "...",
                  "emailAddress" : "somebody@kde.org",
                  "webAddress" : "",
                  "ocsUsername" : ""
              }
          ],
          "credits" : [],
          "translators" : [],
          "licenses" : [
              {
                  "name" : "GPL v2",
                  "text" : "long, boring, license text",
                  "spdx" : "GPL-2.0"
              }
          ],
          "releases" : [
              {
                  "version" : "1.0.0",
                  "date" : "2025-01-01",
                  "description" : "Initial release.",
                  "url" : "https://example.org/releases/1.0.0"
              }
          ],
          "copyrightStatement" : "© 2010-2018 Plasma Development Team",
          "desktopFileName" : "org.kde.kirigamiapp"
       }
       \endcode

       \sa KAboutData
     */
    property var aboutData: Core.AboutData

    /*!
       \brief This property holds a link to a "Get Involved" page.

       Default: "https://github.com/Sonic-DE" when the application ID
       starts with "org.sonicde." or "org.kde.", otherwise empty.
     */
    property url getInvolvedUrl: {
        if (page.aboutData.hasOwnProperty("url") && page.aboutData.url(Core.AboutUrlType.Contribute) !== "")
            return page.aboutData.url(Core.AboutUrlType.Contribute);
        return /^org\.(sonicde|kde)\./.test(page.aboutData.desktopFileName) ? "https://github.com/Sonic-DE" : "";
    }

    /*!
       \brief This property holds a link to a "Donate" page.

       Default: the application's KAboutData donation URL, otherwise empty,
       as SonicDE has no donation page yet.
     */
    property url donateUrl: {
        if (page.aboutData.hasOwnProperty("url") && page.aboutData.url(Core.AboutUrlType.Donation) !== "")
            return page.aboutData.url(Core.AboutUrlType.Donation);
        return "";
    }

    /*!
       \brief This property defines whether to show "Libraries in use".

       Default: true
     */
    property bool showLibraries: true

    Binding {
        target: FormCardModule.AboutComponent
        property: "currentVersion"
        value: page.aboutData.version
    }

    Binding {
        target: FormCardModule.AboutComponent
        property: "releaseVersions"
        value: page.aboutData.releases ? page.aboutData.releases.map(release => release.version) : []
    }

    title: I18n.i18n("About %1", page.aboutData.displayName)

    FormCard {
        Layout.topMargin: Kirigami.Units.largeSpacing * 4
        autoSeparators: true

        AbstractFormDelegate {
            id: generalDelegate

            Accessible.name: page.aboutData.displayName + " " + page.aboutData.version
            background: null
            contentItem: RowLayout {
                spacing: Kirigami.Units.smallSpacing * 2

                Kirigami.Icon {
                    Layout.preferredHeight: Kirigami.Units.iconSizes.huge
                    Layout.preferredWidth: height
                    Layout.maximumWidth: page.width / 3;
                    Layout.rightMargin: Kirigami.Units.largeSpacing
                    source: page.aboutData.programLogo || Kirigami.Settings.applicationWindowIcon || page.aboutData.componentName
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.smallSpacing

                    Kirigami.Heading {
                        Layout.fillWidth: true
                        text: page.aboutData.displayName + " " + page.aboutData.version
                        wrapMode: Text.WordWrap
                    }

                    Kirigami.Heading {
                        Layout.fillWidth: true
                        level: 3
                        type: Kirigami.Heading.Type.Secondary
                        wrapMode: Text.WordWrap
                        text: page.aboutData.shortDescription
                    }
                }
            }
        }

        FormTextDelegate {
            id: copyrightDelegate
            visible: page.aboutData.copyrightStatement.length > 0
            text: I18n.i18n("Copyright")
            descriptionItem.textFormat: Text.PlainText
            description: page.aboutData.copyrightStatement
        }
    }

    FormHeader {
        visible: page.aboutData.otherText.length > 0
        title: I18n.i18n("Description")
    }

    FormCard {
        visible: page.aboutData.otherText.length > 0
        FormTextDelegate {
            textItem.wrapMode: Text.WordWrap
            text: page.aboutData.otherText
        }
    }

    FormHeader {
        title: I18n.i18np("License", "Licenses", page.aboutData.licenses.length)
        visible: page.aboutData.licenses.length
    }

    FormCard {
        visible: page.aboutData.licenses.length

        Repeater {
            model: page.aboutData.licenses
            delegate: FormButtonDelegate {
                id: licenseDelegate

                required property var modelData

                text: licenseDelegate.modelData.name
                onClicked: licenseLoader.open(licenseDelegate.modelData.name, licenseDelegate.modelData.text)
            }
        }
    }

    FormGridContainer {
        Layout.topMargin: Kirigami.Units.gridUnit

        // Use URLs because delegate visibility also depends on this container's visibility.
        visible: getInvolvedDelegate.url.length > 0
              || donateDelegate.url.length > 0
              || homepageDelegate.url.length > 0
              || bugDelegate.url.length > 0
              || matrixRoomDelegate.url.length > 0
              || mastodonDelegate.url.length > 0
              || sourceCodeDelegate.url.length > 0

        FormLinkDelegate {
            id: getInvolvedDelegate
            icon.name: "globe-symbolic"
            text: I18n.i18n("Homepage")
            url: page.aboutData.homepage
            visible: page.aboutData.homepage.length > 0
        }

        FormLinkDelegate {
            id: donateDelegate
            icon.name: "donate-symbolic"
            text: I18n.i18n("Donate")
            url: {
                if (page.donateUrl.toString().length === 0) {
                    return "";
                }
                const url = new URL(page.donateUrl.toString());
                const query = url.search ? url.search + "&" : "?";
                url.search = query + "app=" + encodeURIComponent(page.aboutData.componentName);
                return url.toString();
            }
            visible: page.donateUrl.toString().length > 0
        }

        FormLinkDelegate {
            id: homepageDelegate
            icon.name: "applications-development-symbolic"
            text: I18n.i18n("Get Involved")
            url: page.getInvolvedUrl
            visible: page.getInvolvedUrl.toString() !== ""
        }

        FormLinkDelegate {
            id: bugDelegate
            url: {
                const bugAddress = page.aboutData.bugAddress ?? "";
                if (bugAddress !== "submit@bugs.kde.org") {
                    // A plain email address can only be opened with a mailto: scheme.
                    if (bugAddress.includes("@") && !bugAddress.includes(":")) {
                        return "mailto:" + bugAddress;
                    }
                    return bugAddress;
                }
                const elements = page.aboutData.productName.split('/');
                const url = new URL("https://bugs.kde.org/enter_bug.cgi");
                const params = new URLSearchParams();
                params.set("format", "guided");
                params.set("product", elements[0]);
                params.set("version", page.aboutData.version);
                if (elements.length === 2) {
                    params.set("component", elements[1]);
                }
                url.search = params.toString();
                return url.toString();
            }

            icon.name: "tools-report-bug-symbolic"
            text: I18n.i18n("Report a Bug")
            visible: url.length > 0
        }

        FormLinkDelegate {
            id: matrixRoomDelegate
            url: {
                if (!page.aboutData.hasOwnProperty("url")) // since KF 6.29
                    return "";
                const s = page.aboutData.url(Core.AboutUrlType.XKDEMatrixRoom);
                return s.startsWith("http") ? s : s != "" ? "https://matrix.to/#/" + s : "";
            }
            icon.name: "im-matrix"
            text: I18n.i18n("Matrix Channel")
            visible: url.length > 0
        }

        FormLinkDelegate {
            id: mastodonDelegate
            url: {
                if (!page.aboutData.hasOwnProperty("url")) // since KF 6.29
                    return "";
                const s = page.aboutData.url(Core.AboutUrlType.XKDEMastodon);
                if (s == "" || s.startsWith("http"))
                    return s;
                const m = s.match(/^(@\S*)@(\S+)$/);
                return m ? ("https://" + m[2] + "/" + m[1]) : ""
            }
            icon.name: "im-mastodon"
            text: I18n.i18n("Mastodon")
            visible: url.length > 0
        }

        FormLinkDelegate {
            id: sourceCodeDelegate
            url: {
                if (!page.aboutData.hasOwnProperty("url")) // since KF 6.29
                    return "";
                page.aboutData.url(Core.AboutUrlType.VCSBrowser)
            }
            icon.name: "code-context-symbolic"
            text: I18n.i18n("Source Code")
            visible: url.length > 0
        }
    }

    FormHeader {
        id: headerRelease

        readonly property bool hasReleases: (page.aboutData.releases?.length ?? 0) > 0

        title: I18n.i18nc("@title:group", "Releases")
        visible: hasReleases
    }

    Loader {
        active: headerRelease.hasReleases
        Layout.fillWidth: true

        sourceComponent: FormCard {
            autoSeparators: true

            AbstractFormDelegate {
                background: null
                contentItem: ColumnLayout {
                    id: releaseDelegate

                    readonly property var modelData: page.aboutData.releases[0]

                    Layout.fillWidth: true
                    Layout.preferredWidth: Kirigami.Units.gridUnit * 30
                    spacing: Kirigami.Units.smallSpacing

                    Basic.Label {
                        Layout.fillWidth: true
                        text: releaseDelegate.modelData.version
                        font.bold: true
                    }

                    Basic.Label {
                        Layout.fillWidth: true
                        text: releaseDelegate.modelData.date.toLocaleDateString()
                        wrapMode: Text.WordWrap
                        color: Kirigami.Theme.disabledTextColor
                        visible: text.length > 0
                    }

                    Basic.Label {
                        Layout.fillWidth: true
                        Layout.minimumWidth: 0
                        text: '<style>ul { margin-left: -30px; }</style>' + releaseDelegate.modelData.description
                        textFormat: Text.RichText
                        wrapMode: Text.WordWrap
                        onLinkActivated: (link) => Qt.openUrlExternally(link)
                        visible: (releaseDelegate.modelData.description?.length ?? 0) > 0
                    }

                    Basic.Label {
                        Layout.fillWidth: true
                        text: '<a href="' + releaseDelegate.modelData.url + '">' + I18n.i18n("More information") + '</a>'
                        wrapMode: Text.WordWrap
                        visible: releaseDelegate.modelData.url.toString().length > 0
                        onLinkActivated: (link) => Qt.openUrlExternally(link)
                    }
                }
            }

            FormButtonDelegate {
                text: I18n.i18nc("@action:button", "Show previous releases")
                onClicked: releasesLoader.active = true;
            }
        }
    }

    FormHeader {
        title: I18n.i18n("Libraries in use")
        visible: page.showLibraries

        actions: T.Action {
            text: I18n.i18nc("@action:button", "Copy to Clipboard")
            icon.name: 'edit-copy-symbolic'
            onTriggered: {
                FormCardModule.AboutComponent.copyToClipboard();
                (page.T.ApplicationWindow.window as Kirigami.ApplicationWindow)?.showPassiveNotification(I18n.i18nc("@info", "System information copied to clipboard."), 'short');
            }
        }
    }

    FormCard {
        visible: page.showLibraries
        autoSeparators: true
        Repeater {
            model: page.showLibraries ? FormCardModule.AboutComponent.components : null
            delegate: libraryDelegate
        }
    }

    FormHeader {
        title: I18n.i18n("Authors")
        visible: page.aboutData.authors !== undefined && page.aboutData.authors.length > 0
    }

    FormCard {
        visible: page.aboutData.authors !== undefined && page.aboutData.authors.length > 0
        autoSeparators: true

        Repeater {
            id: authorsRepeater
            model: page.aboutData.authors
            delegate: personDelegate
        }
    }

    FormHeader {
        title: I18n.i18n("Credits")
        visible: page.aboutData.credits !== undefined && page.aboutData.credits.length > 0
    }

    FormCard {
        visible: page.aboutData.credits !== undefined && page.aboutData.credits.length > 0
        autoSeparators: true

        Repeater {
            id: repCredits
            model: page.aboutData.credits
            delegate: personDelegate
        }
    }

    FormHeader {
        title: I18n.i18n("Translators")
        visible: page.aboutData.translators !== undefined && page.aboutData.translators.length > 0
    }

    FormCard {
        visible: page.aboutData.translators !== undefined && page.aboutData.translators.length > 0
        autoSeparators: true

        Repeater {
            id: repTranslators
            model: page.aboutData.translators
            delegate: personDelegate
        }
    }

    data: [
        Loader {
            id: releasesLoader
            active: false
            sourceComponent: Private.AboutReleaseDialog {
                releases: page.aboutData.releases
                onClosed: releasesLoader.active = FormCardModule.AboutComponent.hasNewReleases
            }
            onLoaded: {
                if (status === Loader.Ready) {
                    (item as T.Popup).open();
                    FormCardModule.AboutComponent.updateLastSeenVersion();
                }
            }
        },
        Loader {
            id: licenseLoader

            property string licenseTitle
            property string licenseText

            function open(title: string, text: string): void {
                licenseTitle = title;
                licenseText = text;
                active = true;
            }

            active: false
            sourceComponent: Private.AboutLicenseDialog {
                title: licenseLoader.licenseTitle
                text: licenseLoader.licenseText
                onClosed: licenseLoader.active = false
            }
            onLoaded: {
                if (status === Loader.Ready) {
                    (item as T.Popup).open();
                }
            }
        },
        Component {
            id: personDelegate

            AbstractFormDelegate {
                id: person

                required property var modelData

                background: null
                contentItem: RowLayout {
                    spacing: FormCardModule.FormCardUnits.horizontalSpacing

                    KirigamiComponents.Avatar {
                        id: avatarIcon

                        implicitWidth: Kirigami.Units.iconSizes.medium
                        implicitHeight: implicitWidth
                        name: person.modelData.name
                        source: if (!!person.modelData.avatarUrl && person.modelData.avatarUrl.toString().startsWith('https://')) {
                            const url = new URL(person.modelData.avatarUrl);
                            const params = new URLSearchParams(url.search);
                            params.append("s", avatarIcon.width);
                            url.search = params.toString();
                            return url;
                        } else {
                            return '';
                        }

                        Layout.rightMargin: FormCardModule.FormCardUnits.horizontalSpacing
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: FormCardModule.FormCardUnits.verticalSpacing

                        Basic.Label {
                            Layout.fillWidth: true
                            text: person.modelData.name
                            elide: Text.ElideRight
                        }

                        Basic.Label {
                            id: internalDescriptionItem
                            Layout.fillWidth: true
                            text: person.modelData.task
                            color: Kirigami.Theme.disabledTextColor
                            font: Kirigami.Theme.smallFont
                            elide: Text.ElideRight
                            visible: text.length > 0
                        }
                    }

                    QQC2.ToolButton {
                        id: storeButton
                        visible: typeof(person.modelData.ocsUsername) !== "undefined" && person.modelData.ocsUsername.length > 0
                        icon.name: "get-hot-new-stuff-symbolic"
                        text: I18n.i18n("Visit %1's KDE Store page", person.modelData.name)
                        display: T.AbstractButton.IconOnly
                        T.ToolTip.delay: Kirigami.Units.toolTipDelay
                        T.ToolTip.visible: storeButton.hovered
                        T.ToolTip.text: I18n.i18n("Visit %1's KDE Store page", person.modelData.name)
                        onClicked: Qt.openUrlExternally("https://store.kde.org/u/%1".arg(person.modelData.ocsUsername))
                    }

                    QQC2.ToolButton {
                        id: emailButton
                        visible: typeof(person.modelData.emailAddress) !== "undefined" && person.modelData.emailAddress.length > 0
                        icon.name: "mail-sent-symbolic"
                        text: I18n.i18n("Send an email to %1", person.modelData.emailAddress)
                        display: T.AbstractButton.IconOnly
                        T.ToolTip.delay: Kirigami.Units.toolTipDelay
                        T.ToolTip.visible: emailButton.hovered
                        T.ToolTip.text: I18n.i18n("Send an email to %1", person.modelData.emailAddress)
                        onClicked: Qt.openUrlExternally("mailto:%1".arg(person.modelData.emailAddress))
                    }

                    QQC2.ToolButton {
                        id: personWebButton
                        visible: typeof(person.modelData.webAddress) !== "undefined" && person.modelData.webAddress.length > 0
                        icon.name: "globe-symbolic"
                        text: I18n.i18nc("@action:button", "Visit %1's website", person.modelData.name)
                        display: T.AbstractButton.IconOnly
                        T.ToolTip.delay: Kirigami.Units.toolTipDelay
                        T.ToolTip.visible: personWebButton.hovered
                        T.ToolTip.text: (typeof(person.modelData.webAddress) === "undefined" && person.modelData.webAddress.length > 0) ? "" : person.modelData.webAddress
                        onClicked: Qt.openUrlExternally(person.modelData.webAddress)
                    }
                }
            }
        },
        Component {
            id: libraryDelegate

            AbstractFormDelegate {
                id: delegate

                required property var modelData

                Layout.fillWidth: true
                background: null
                contentItem: RowLayout {
                    spacing: FormCardModule.FormCardUnits.horizontalSpacing

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: FormCardModule.FormCardUnits.verticalSpacing

                        Basic.Label {
                            Layout.fillWidth: true
                            text: delegate.modelData.name + ' ' + delegate.modelData.version
                            wrapMode: Text.WordWrap
                        }

                        Basic.Label {
                            id: internalDescriptionItem
                            Layout.fillWidth: true
                            text: delegate.modelData.description
                            color: Kirigami.Theme.disabledTextColor
                            font: Kirigami.Theme.smallFont
                            wrapMode: Text.WordWrap
                            visible: text.length > 0
                        }
                    }

                    QQC2.ToolButton {
                        id: licenseButton
                        visible: delegate.modelData.licenses.key !== 0
                        icon.name: "license-symbolic"
                        text: I18n.i18nc("@action:button", "Show license for %1", delegate.modelData.name)
                        display: T.AbstractButton.IconOnly

                        T.ToolTip.delay: Kirigami.Units.toolTipDelay
                        T.ToolTip.visible: licenseButton.hovered
                        T.ToolTip.text: !licenseButton.visible ? "" : delegate.modelData.licenses.name

                        onClicked: licenseLoader.open(delegate.modelData.name, delegate.modelData.licenses.text)
                    }

                    QQC2.ToolButton {
                        id: libraryWebButton
                        visible: typeof(delegate.modelData.webAddress) !== "undefined" && delegate.modelData.webAddress.length > 0
                        icon.name: "globe-symbolic"
                        text: I18n.i18nc("@action:button", "Visit %1's website", delegate.modelData.name)
                        display: T.AbstractButton.IconOnly
                        T.ToolTip.delay: Kirigami.Units.toolTipDelay
                        T.ToolTip.visible: libraryWebButton.hovered
                        T.ToolTip.text: (typeof(delegate.modelData.webAddress) === "undefined" && delegate.modelData.webAddress.length > 0) ? "" : delegate.modelData.webAddress
                        onClicked: Qt.openUrlExternally(delegate.modelData.webAddress)
                    }
                }
            }
        }
    ]
}
