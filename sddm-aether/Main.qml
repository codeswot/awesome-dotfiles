import QtQuick 2.12
import QtGraphicalEffects 1.0
import SddmComponents 2.0

Rectangle {
    id: container
    width: 1920
    height: 1080
    color: "black"

    TextConstants { id: textConstants }

    Connections {
        target: sddm
        onLoginSucceeded: {
        }
        onLoginFailed: {
            passwordField.text = ""
            passwordField.focus = true
            errorMessage.visible = true
        }
    }

    // Blurred Background
    Image {
        id: backgroundImage
        anchors.fill: parent
        source: "background.png"
        fillMode: Image.PreserveAspectCrop
        visible: false 
    }

    FastBlur {
        id: blurredBackground
        anchors.fill: backgroundImage
        source: backgroundImage
        radius: 64 
        cached: true
    }

    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: 0.3
    }

    Rectangle {
        id: mainFrame
        anchors.fill: parent
        color: "transparent"

        // Clock - matching hyprlock position
        Text {
            id: timeLabel
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -130
            anchors.horizontalCenterOffset: -20
            text: Qt.formatDateTime(new Date(), "h:mm")
            color: "#ffffff"
            font.pixelSize: 300
            font.family: "SF Pro Display"
            font.bold: true
        }

        // Date
        Text {
            id: dateLabel
            anchors.centerIn: parent
            anchors.verticalCenterOffset: 115
            anchors.horizontalCenterOffset: -20
            text: Qt.formatDateTime(new Date(), "dddd, dd MMMM")
            color: "#ffffff"
            font.pixelSize: 24
            font.family: "SF Pro Display"
            font.bold: true
        }

        // Error message
        Text {
            id: errorMessage
            anchors.centerIn: parent
            anchors.verticalCenterOffset: 160
            color: "#ff8888"
            text: "Login failed"
            visible: false
            font.pixelSize: 18
            font.family: "SF Pro Display"
        }

        // Input Field Container
        Rectangle {
            id: inputContainer
            width: 400
            height: 60
            anchors.centerIn: parent
            anchors.verticalCenterOffset: 200
            anchors.horizontalCenterOffset: -20
            color: "#a8080308" // matches hyprlock inner_color
            border.color: "#c19dc8" // matches hyprlock outer_color
            border.width: 2
            radius: 15

            TextInput {
                id: passwordField
                anchors.fill: parent
                anchors.margins: 10
                verticalAlignment: TextInput.AlignVCenter
                horizontalAlignment: TextInput.AlignHCenter
                color: "#ffffff"
                font.pixelSize: 18
                font.family: "SF Pro Display"
                echoMode: TextInput.Password
                focus: true
                clip: true

                Keys.onPressed: {
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        sddm.login(userModel.lastUser, passwordField.text, sessionModel.lastIndex)
                    }
                }
            }
            
            Text {
                id: placeholder
                anchors.fill: parent
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                text: "Enter Password"
                color: "#99ffffff"
                font.italic: true
                font.pixelSize: 18
                font.family: "SF Pro Display"
                visible: passwordField.text === ""
            }
        }
        
        // Timer to update clock
        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: {
                timeLabel.text = Qt.formatDateTime(new Date(), "h:mm")
                dateLabel.text = Qt.formatDateTime(new Date(), "dddd, dd MMMM")
            }
        }
    }
}
