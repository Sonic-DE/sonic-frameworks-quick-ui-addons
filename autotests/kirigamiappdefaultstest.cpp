// SPDX-FileCopyrightText: 2026 SonicDE contributors
// SPDX-License-Identifier: BSD-2-Clause

#include "kirigamiappdefaults.h"

#include <QQmlApplicationEngine>
#include <QQmlComponent>
#include <QQmlError>
#include <QSignalSpy>
#include <QTest>
#include <QUrl>

#include <memory>

class WarningCountingEngine : public QQmlApplicationEngine {
public:
    int warningReceiverCount() const
    {
        return receivers(SIGNAL(warnings(QList<QQmlError>)));
    }
};

class KirigamiAppDefaultsTest : public QObject {
    Q_OBJECT

private Q_SLOTS:
    void loadDisconnectsWarningCollector_data()
    {
        QTest::addColumn<int>("loadCount");
        QTest::newRow("single-load") << 1;
        QTest::newRow("repeated-loads") << 3;
    }

    void loadDisconnectsWarningCollector()
    {
        QFETCH(int, loadCount);

        WarningCountingEngine engine;
        engine.setOutputWarningsToStandardError(false);
        QSignalSpy warningsSpy(&engine, &QQmlApplicationEngine::warnings);
        QVERIFY(warningsSpy.isValid());
        const int initialReceiverCount = engine.warningReceiverCount();

        for (int i = 0; i < loadCount; ++i) {
            QVERIFY(KirigamiAppDefaults::load("QtQml", "QtObject", &engine));
            QCOMPARE(engine.rootObjects().size(), i + 1);
            QCOMPARE(engine.warningReceiverCount(), initialReceiverCount);
        }

        // A later binding warning must still reach existing observers without
        // touching any load() invocation's destroyed stack variables.
        QQmlComponent component(&engine);
        component.setData("import QtQml\nQtObject { property int value: undefinedLateBinding }", QUrl(QStringLiteral("file:///late-warning.qml")));
        QVERIFY2(component.isReady(), qPrintable(component.errorString()));
        const std::unique_ptr<QObject> object(component.create());
        QVERIFY(object);
        QCOMPARE(warningsSpy.count(), 1);
        const auto warnings = warningsSpy.at(0).at(0).value<QList<QQmlError>>();
        QCOMPARE(warnings.size(), 1);
        QVERIFY(warnings.first().description().contains(QStringLiteral("undefinedLateBinding")));
    }
};

QTEST_GUILESS_MAIN(KirigamiAppDefaultsTest)

#include "kirigamiappdefaultstest.moc"
