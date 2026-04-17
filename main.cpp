#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle> // Stil hatasını çözen kahraman
#include <QProcess>
#include <QFile>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QDateTime>
#include <QStandardPaths>
#include <QIcon>

class LauncherManager : public QObject {
    Q_OBJECT
    QString jsonPath;
    QJsonArray gamesArray;

public:
    explicit LauncherManager(QObject *parent = nullptr) : QObject(parent) {
        // Database dosyası Belgeler/kros_data.json içinde durur
        jsonPath = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation) + "/kros_data.json";
        loadFromDB();
    }

    void loadFromDB() {
        QFile file(jsonPath);
        if (file.open(QIODevice::ReadOnly)) {
            gamesArray = QJsonDocument::fromJson(file.readAll()).array();
            file.close();
        }
    }

    void saveToDB() {
        QFile file(jsonPath);
        if (file.open(QIODevice::WriteOnly)) {
            file.write(QJsonDocument(gamesArray).toJson());
            file.close();
        }
    }

    Q_INVOKABLE QVariantList getGames() {
        QVariantList list;
        for (const QJsonValue &v : gamesArray) list << v.toVariant();
        return list;
    }

    Q_INVOKABLE void addGame(QString name, QString exe, QString img) {
        QJsonObject obj;
        obj["name"] = name;
        obj["exe"] = exe;
        obj["img"] = img;
        obj["hours"] = 0.0;
        gamesArray.append(obj);
        saveToDB();
    }

    Q_INVOKABLE void removeGame(int index) {
        if (index >= 0 && index < gamesArray.size()) {
            gamesArray.removeAt(index);
            saveToDB();
        }
    }

    Q_INVOKABLE void launchGame(int index) {
        if (index < 0 || index >= gamesArray.size()) return;
        QJsonObject obj = gamesArray[index].toObject();
        QString path = QUrl(obj["exe"].toString()).toLocalFile();
        QDateTime startTime = QDateTime::currentDateTime();
        QProcess *process = new QProcess(this);

        connect(process, &QProcess::finished, [this, index, startTime]() {
            qint64 seconds = startTime.secsTo(QDateTime::currentDateTime());
            double newHours = seconds / 3600.0;
            QJsonObject game = gamesArray[index].toObject();
            game["hours"] = game["hours"].toDouble() + newHours;
            gamesArray[index] = game;
            saveToDB();
        });
        process->start(path);
    }
};

#include "main.moc"

int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);

    // Uygulama stilini 'Basic' yap ki butonlarımızı boyayabilelim
    QQuickStyle::setStyle("Basic");

    app.setWindowIcon(QIcon(":/KrosLauncher/icon.ico"));

    LauncherManager manager;
    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("Backend", &manager);
    const QUrl url(u"qrc:/KrosLauncher/Main.qml"_qs);
    engine.load(url);
    return app.exec();
}