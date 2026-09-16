// SPDX-FileCopyrightText: 2026 SonicDE contributors
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtTest
import org.kde.kirigamiaddons.formcard as FormCard

TestCase {
    id: testCase
    name: "FormDelegateContentTest"
    width: 600
    height: 300
    visible: true
    when: windowShown

    Component { id: buttonComponent; FormCard.FormButtonDelegate { width: 500; height: 100; text: "Button" } }
    Component { id: checkComponent; FormCard.FormCheckDelegate { width: 500; height: 100; text: "Check" } }
    Component { id: radioComponent; FormCard.FormRadioDelegate { width: 500; height: 100; text: "Radio" } }
    Component { id: switchComponent; FormCard.FormSwitchDelegate { width: 500; height: 100; text: "Switch" } }
    Component { id: textComponent; FormCard.FormTextDelegate { width: 500; height: 100; text: "Text" } }

    Component {
        id: extraComponent

        Rectangle {
            property bool requestedVisible: true
            visible: requestedVisible
            implicitWidth: 30
            implicitHeight: 20
            color: "red"
        }
    }

    function init() {
        failOnWarning(/Binding loop|Cannot anchor|ReferenceError|TypeError/);
    }

    function cases() {
        const delegates = [
            {name: "button", component: buttonComponent},
            {name: "check", component: checkComponent},
            {name: "radio", component: radioComponent},
            {name: "switch", component: switchComponent},
            {name: "text", component: textComponent},
        ];
        const result = [];
        for (const delegate of delegates) {
            for (const edge of ["leading", "trailing"]) {
                result.push({tag: delegate.name + "-" + edge, component: delegate.component, edge: edge});
            }
        }
        return result;
    }

    function createControl(data, extra) {
        const properties = {};
        properties[data.edge] = extra;
        const control = createTemporaryObject(data.component, testCase, properties);
        verify(control);
        return control;
    }

    function verifyVisible(extra) {
        tryVerify(() => extra.parent !== null && extra.visible, 1000);
        tryCompare(extra, "width", 30, 1000);
    }

    function test_visibility_data() { return cases(); }
    function test_visibility(data) {
        const extra = createTemporaryObject(extraComponent, testCase);
        const control = createControl(data, extra);
        verifyVisible(extra);
        wait(20);
        const initialWidth = control.contentItem.implicitWidth;
        for (let i = 0; i < 2; ++i) {
            extra.requestedVisible = false;
            tryCompare(extra, "visible", false, 1000);
            tryVerify(() => control.contentItem.implicitWidth < initialWidth, 1000);
            extra.requestedVisible = true;
            verifyVisible(extra);
            tryCompare(control.contentItem, "implicitWidth", initialWidth, 1000);
        }
    }

    function test_initiallyHidden_data() { return cases(); }
    function test_initiallyHidden(data) {
        const extra = createTemporaryObject(extraComponent, testCase, {requestedVisible: false});
        createControl(data, extra);
        tryCompare(extra, "visible", false, 1000);
        extra.requestedVisible = true;
        verifyVisible(extra);
    }

    function test_parentVisibility_data() { return cases(); }
    function test_parentVisibility(data) {
        const extra = createTemporaryObject(extraComponent, testCase);
        const control = createControl(data, extra);
        verifyVisible(extra);
        control.visible = false;
        wait(20);
        control.visible = true;
        verifyVisible(extra);
    }

    function test_replaceAndClear_data() { return cases(); }
    function test_replaceAndClear(data) {
        const extra = createTemporaryObject(extraComponent, testCase);
        const control = createControl(data, extra);
        verifyVisible(extra);
        const replacement = createTemporaryObject(extraComponent, testCase);
        control[data.edge] = replacement;
        verifyVisible(replacement);
        tryVerify(() => extra.parent === null, 1000);
        control[data.edge] = null;
        tryVerify(() => replacement.parent === null, 1000);
        control[data.edge] = extra;
        verifyVisible(extra);
    }

    function test_layoutHints_data() { return cases(); }
    function test_layoutHints(data) {
        const extra = createTemporaryObject(extraComponent, testCase);
        extra.Layout.preferredWidth = 47;
        createControl(data, extra);
        tryCompare(extra, "width", 47, 1000);
        extra.Layout.minimumWidth = 55;
        tryCompare(extra, "width", 55, 1000);
        extra.Layout.maximumWidth = 60;
        extra.Layout.preferredWidth = 70;
        tryCompare(extra, "width", 60, 1000);
    }

    function test_destroyContent_data() { return cases(); }
    function test_destroyContent(data) {
        const extra = createTemporaryObject(extraComponent, testCase);
        const control = createControl(data, extra);
        verifyVisible(extra);
        extra.destroy();
        tryCompare(control, data.edge, null, 1000);
    }

    function test_destroyControl_data() { return cases(); }
    function test_destroyControl(data) {
        const extra = createTemporaryObject(extraComponent, testCase);
        const control = createControl(data, extra);
        verifyVisible(extra);
        control.destroy();
        tryVerify(() => extra.parent === null, 1000);
        compare(extra.requestedVisible, true);
        createControl(data, extra);
        verifyVisible(extra);
    }
}
