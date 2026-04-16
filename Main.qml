import QtQuick 2.7
import Lomiri.Components 1.3

MainView {
    id: root
    objectName: "mainView"
    applicationName: "smartplanner.apek"
    automaticOrientation: true

    width: units.gu(45)
    height: units.gu(75)

    PageStack {
        id: pageStack

        Component.onCompleted: {
            push(mainPage)
        }

        // MAIN PAGE
        Component {
            id: mainPage

            Page {
                header: PageHeader {
                    title: "Smart Planner"
                }

                Column {
                    anchors.centerIn: parent
                    spacing: units.gu(3)

                    Text {
                        text: "Welcome 👋"
                        font.pixelSize: 32
                        color: "#2E7D32"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Rectangle {
                        width: units.gu(25)
                        height: units.gu(6)
                        radius: 12
                        color: "#4CAF50"

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                pageStack.push(plannerPage)
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "Daily Planner"
                            color: "white"
                            font.pixelSize: 18
                        }
                    }

                    Rectangle {
                        width: units.gu(25)
                        height: units.gu(6)
                        radius: 12
                        color: "#2196F3"

                        Text {
                            anchors.centerIn: parent
                            text: "Habit Tracker"
                            color: "white"
                            font.pixelSize: 18
                        }
                    }

                    Rectangle {
                        width: units.gu(25)
                        height: units.gu(6)
                        radius: 12
                        color: "#FF9800"

                        Text {
                            anchors.centerIn: parent
                            text: "Expense Tracker"
                            color: "white"
                            font.pixelSize: 18
                        }
                    }
                }
            }
        }

        // SECOND PAGE
        Component {
            id: plannerPage

            Page {
                header: PageHeader {
                    title: "Daily Planner"
                }

                Text {
                    anchors.centerIn: parent
                    text: "This is Daily Planner Screen"
                    font.pixelSize: 24
                }
            }
        }
    }
}
