// SPDX-FileCopyrightText: 2026 SonicDE contributors
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Controls as QQC2
import QtTest
import org.kde.kirigamiaddons.actions as Actions

TestCase {
    id: testCase
    name: "ActionMenuVisibilityTest"
    width: 600
    height: 400
    visible: true
    when: windowShown

    Actions.ActionContext { id: context }
    Actions.ActionData {
        id: backend
        name: "visibility_probe"
        text: "Visibility probe"
        checkable: true
        contexts: [context]
    }

    QtObject {
        id: menuData
        property var mergedActions: ["visibility_probe"]
        property var mergedItems: [{type: "action", action: backend}]
        property var mergedMenus: []
        property QtObject collection: null
    }

    Component { id: popupComponent; Actions.ActionMenuPopup { menu: menuData } }
    Component { id: barComponent; Actions.ActionMenuBar { width: 500 } }
    Component { id: menuComponent; QQC2.Menu { popupType: QQC2.Popup.Item; closePolicy: QQC2.Popup.NoAutoClose } }

    function init() {
        failOnWarning(/TypeError|ReferenceError|Binding loop/);
        context.active = true;
        backend.visible = true;
        backend.enabled = true;
        backend.checked = false;
    }

    function presenterCases() {
        return [{tag: "popup", presenter: "popup"}, {tag: "menubar", presenter: "menubar"}];
    }

    function createPresenter(kind) {
        if (kind === "popup") {
            const popup = createTemporaryObject(popupComponent, testCase);
            verify(popup);
            tryVerify(() => popup.generatedActions.length === 1, 1000);
            return {adapter: popup.generatedActions[0], item: null, menu: null};
        }
        const bar = createTemporaryObject(barComponent, testCase);
        verify(bar);
        wait(20); // Finish the initial empty rebuild before populating the test menu.
        const menu = createTemporaryObject(menuComponent, testCase);
        verify(menu);
        bar.populateMenu(menuData, menu);
        compare(menu.count, 1);
        if (backend.visible) {
            menu.open();
            tryCompare(menu, "opened", true, 1000);
        }
        return {adapter: menu.itemAt(0).action, item: menu.itemAt(0), menu: menu};
    }

    function verifyVisibility(presenter, visible) {
        tryCompare(presenter.adapter, "visible", visible, 1000);
        if (presenter.menu) {
            if (visible && !presenter.menu.opened) {
                presenter.menu.open();
                tryCompare(presenter.menu, "opened", true, 1000);
            }
            tryCompare(presenter.item, "visible", visible, 1000);
        }
    }

    function test_initialAndLiveVisibility_data() {
        const rows = [];
        for (const data of presenterCases()) {
            for (const visible of [false, true]) {
                rows.push({tag: data.tag + "-" + visible, presenter: data.presenter, visible: visible});
            }
        }
        return rows;
    }

    function test_initialAndLiveVisibility(data) {
        backend.visible = data.visible;
        const presenter = createPresenter(data.presenter);
        verifyVisibility(presenter, data.visible);
        for (const visible of [!data.visible, data.visible, !data.visible, data.visible]) {
            backend.visible = visible;
            verifyVisibility(presenter, visible);
        }
        if (presenter.menu) presenter.menu.close();
    }

    function test_contextVisibility_data() { return presenterCases(); }
    function test_contextVisibility(data) {
        const presenter = createPresenter(data.presenter);
        context.active = false;
        tryCompare(backend, "visible", false);
        verifyVisibility(presenter, false);
        context.active = true;
        tryCompare(backend, "visible", true);
        verifyVisibility(presenter, true);
        if (presenter.menu) presenter.menu.close();
    }

    function test_otherActionState_data() { return presenterCases(); }
    function test_otherActionState(data) {
        const presenter = createPresenter(data.presenter);
        backend.enabled = false;
        backend.checked = true;
        tryCompare(presenter.adapter, "enabled", false);
        tryCompare(presenter.adapter, "checked", true);
        compare(presenter.adapter.checkable, true);
        verifyVisibility(presenter, true);
        if (presenter.menu) presenter.menu.close();
    }
}
