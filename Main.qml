import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts

Window {
    id: root
    width: 1150; height: 800; visible: true
    title: "KrosLauncher"; color: "#050505"

    readonly property color neonPurple: "#BC13FE"
    ListModel { id: gameModel }
    property int currentIndex: 0

    // --- ARKA PLAN (STABİL NEON) ---
    Rectangle {
        anchors.fill: parent; color: "#050505"; z: -1
        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#1a0033" }
                GradientStop { position: 1.0; color: "#050505" }
            }
        }
    }

    function refresh() {
        gameModel.clear();
        var games = Backend.getGames();
        for(var i=0; i<games.length; i++) gameModel.append(games[i]);
    }

    Component.onCompleted: refresh()

    // --- ÜST BAR ---
    Rectangle {
        id: header; width: parent.width; height: 60; color: "#0d0d0d"; z: 10
        RowLayout {
            anchors.fill: parent; anchors.leftMargin: 20; anchors.rightMargin: 20
            Row {
                spacing: 15
                Layout.alignment: Qt.AlignVCenter
                Rectangle {
                    width: 40; height: 40; radius: 8; color: neonPurple
                    Text { text: "KL"; anchors.centerIn: parent; color: "black"; font.bold: true }
                }
                Text {
                    text: "KROSLAUNCHER"
                    color: "white"
                    font.pixelSize: 18
                    font.bold: true
                    font.letterSpacing: 2
                }
            }
            Item { Layout.fillWidth: true }
            Button {
                text: "+ OYUN EKLE"
                onClicked: exePicker.open()
                background: Rectangle { color: "transparent"; border.color: neonPurple; border.width: 1; radius: 5 }
                contentItem: Text {
                    text: parent.text
                    color: neonPurple
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }

    // --- OYUN VİTRİNİ ---
    Rectangle {
        id: vitrinArea; anchors.top: header.bottom; width: parent.width; height: 130; color: "#cc080808"
        ListView {
            id: topView; anchors.fill: parent; orientation: ListView.Horizontal; model: gameModel; spacing: 20; leftMargin: 20; rightMargin: 20
            delegate: Rectangle {
                width: 70; height: 100; radius: 8; color: "#111"
                anchors.verticalCenter: parent.verticalCenter
                border.color: currentIndex === index ? neonPurple : "#333"
                border.width: currentIndex === index ? 3 : 1; clip: true
                scale: currentIndex === index ? 1.2 : 1.0
                Behavior on scale { NumberAnimation { duration: 200 } }
                Image {
                    anchors.fill: parent
                    source: (img && img.indexOf(".exe") === -1) ? img : ""
                    fillMode: Image.PreserveAspectCrop
                }
                Rectangle {
                    width: 22; height: 22; radius: 11; color: "red"; z: 50; anchors.top: parent.top; anchors.right: parent.right; anchors.margins: 3
                    Text { text: "×"; color: "white"; anchors.centerIn: parent; font.bold: true }
                    MouseArea { anchors.fill: parent; onClicked: { Backend.removeGame(index); refresh(); } }
                }
                MouseArea { anchors.fill: parent; onClicked: currentIndex = index }
            }
        }
    }

    // --- ANA EKRAN VE REHBER ---
    Item {
        anchors.top: vitrinArea.bottom; anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right

        // REHBER (Oyun Yoksa Gözükür)
        Column {
            anchors.centerIn: parent
            visible: gameModel.count === 0
            spacing: 20
            Text { text: "Hoş Geldin Reis!"; color: "white"; font.pixelSize: 30; font.bold: true; anchors.horizontalCenter: parent }
            Text {
                text: "1. Sağ üstteki '+ OYUN EKLE' butonuna bas.\n2. Önce oyunun .exe dosyasını seç.\n3. Sonra oyun için bir kapak fotoğrafı seç.\n4. PLAY butonuna bas ve başla!"
                color: neonPurple
                font.pixelSize: 18
                horizontalAlignment: Text.AlignHCenter
                lineHeight: 1.3
            }
        }

        // ANA PANEL (Oyun Varsa Gözükür)
        RowLayout {
            anchors.centerIn: parent; spacing: 80; visible: gameModel.count > 0
            Rectangle {
                Layout.preferredWidth: 320; Layout.preferredHeight: 450; radius: 15; color: "#111"; clip: true; border.color: neonPurple
                Image {
                    anchors.fill: parent
                    source: (gameModel.count > 0 && gameModel.get(currentIndex).img.indexOf(".exe") === -1) ? gameModel.get(currentIndex).img : ""
                    fillMode: Image.PreserveAspectCrop
                }
            }
            ColumnLayout {
                spacing: 25
                Text { text: gameModel.count > 0 ? gameModel.get(currentIndex).name : ""; color: "white"; font.pixelSize: 50; font.bold: true }
                Text { text: gameModel.count > 0 ? "Toplam Süre: " + gameModel.get(currentIndex).hours.toFixed(1) + " Saat" : ""; color: neonPurple; font.pixelSize: 20; font.bold: true }
                Rectangle {
                    id: playBtn; Layout.preferredWidth: 200; Layout.preferredHeight: 200; radius: 100; color: "transparent"; border.color: neonPurple; border.width: 5
                    Text { text: "PLAY"; color: neonPurple; font.pixelSize: 40; font.bold: true; anchors.centerIn: parent }
                    SequentialAnimation on opacity { loops: Animation.Infinite; NumberAnimation { from: 1; to: 0.3; duration: 1500 } NumberAnimation { from: 0.3; to: 1; duration: 1500 } }
                    MouseArea { anchors.fill: parent; onClicked: Backend.launchGame(currentIndex) }
                }
            }
        }
    }

    // --- DOSYA SEÇİCİLER (UZANTI HATASI DÜZELTİLDİ) ---
    FileDialog {
        id: exePicker; title: "ADIM 1: Oyunun .exe Dosyasını Seç"
        onAccepted: imgPicker.open()
    }

    FileDialog {
        id: imgPicker; title: "ADIM 2: Kapak Fotoğrafını Seç (.jpg / .png)"
        onAccepted: {
            // İsim alırken EXE dosyasının adını kullanıyoruz (.png hatasını bu çözer)
            var exePath = exePicker.selectedFile.toString()
            var cleanName = exePath.split('/').pop().replace(".exe", "").toUpperCase()

            // Resim yolu
            var imgPath = selectedFile.toString()

            Backend.addGame(cleanName, exePath, imgPath)
            refresh()
        }
    }
}