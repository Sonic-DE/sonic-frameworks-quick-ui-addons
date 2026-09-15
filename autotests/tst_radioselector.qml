// SPDX-FileCopyrightText: 2026 SonicDE contributors
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import QtTest
import org.kde.kirigamiaddons.components as Components

TestCase {
    id: testCase
    name: "RadioSelectorTest"
    width: 600
    height: 300
    visible: true
    when: windowShown

    Component {
        id: selectorComponent

        Components.RadioSelector {
            width: 500
            actions: [
                QQC2.Action { text: "First"; checkable: true },
                QQC2.Action { text: "Second"; checkable: true },
                QQC2.Action { text: "Third"; checkable: true }
            ]
        }
    }

    function init() {
        failOnWarning(/Insufficient arguments/);
    }

    function buttons(selector) {
        const layout = selector.children.find(child => child instanceof RowLayout);
        return layout.children.filter(child => child instanceof QQC2.ToolButton);
    }

    function createSelector(properties) {
        const selector = createTemporaryObject(selectorComponent, testCase, properties || {});
        verify(selector);
        tryVerify(() => buttons(selector).length === selector.actions.length);
        return selector;
    }

    function verifySelection(selector, index) {
        compare(selector.selectedIndex, index);
        const items = buttons(selector);
        for (let i = 0; i < items.length; ++i) {
            tryCompare(items[i], "checked", i === index);
            compare(selector.actions[i].checked, i === index);
        }
    }

    function test_defaultSelection() {
        const selector = createSelector();
        verifySelection(selector, 0);
    }

    function test_initialSelection_data() {
        return [{tag: "first", index: 0}, {tag: "second", index: 1}, {tag: "third", index: 2}];
    }

    function test_initialSelection(data) {
        const selector = createSelector({selectedIndex: data.index});
        verifySelection(selector, data.index);
    }

    function test_programmaticSelection() {
        const selector = createSelector();
        for (const index of [1, 2, 0]) {
            selector.selectedIndex = index;
            verifySelection(selector, index);
        }
    }

    function test_userSelection() {
        const selector = createSelector();
        waitForRendering(selector);
        mouseClick(buttons(selector)[2]);
        verifySelection(selector, 2);
    }

    function test_invalidIndices() {
        const selector = createSelector();
        for (const index of [-1, selector.actions.length, 100]) {
            selector.selectedIndex = index;
            wait(0);
            compare(buttons(selector)[0].checked, true);
        }
        selector.selectedIndex = 1;
        verifySelection(selector, 1);
    }

    function test_emptyActions() {
        const selector = createSelector({actions: []});
        compare(selector.selectedIndex, -1);
        for (const index of [-1, 0, 1]) {
            selector.selectedIndex = index;
            wait(0);
            compare(buttons(selector).length, 0);
        }
    }
}
