import QtQuick 2.7
import Lomiri.Components 1.3
import QtQuick.LocalStorage 2.0

MainView {
    id: root
    applicationName: "smartplanner"
    automaticOrientation: true

    width: units.gu(45)
    height: units.gu(75)

    PageStack {
        id: pageStack

        Component.onCompleted: push(mainPage)

        // ---------------- MAIN PAGE ----------------
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
                        width: units.gu(25); height: units.gu(6); radius: 12; color: "#4CAF50"
                        MouseArea { anchors.fill: parent; onClicked: pageStack.push(plannerPage) }
                        Text { anchors.centerIn: parent; text: "Daily Planner"; color: "white" }
                    }

                    Rectangle {
                        width: units.gu(25); height: units.gu(6); radius: 12; color: "#2196F3"
                        MouseArea { anchors.fill: parent; onClicked: pageStack.push(habitPage) }
                        Text { anchors.centerIn: parent; text: "Habit Tracker"; color: "white" }
                    }

                    Rectangle {
                        width: units.gu(25); height: units.gu(6); radius: 12; color: "#FF9800"
                        MouseArea { anchors.fill: parent; onClicked: pageStack.push(expensePage) }
                        Text { anchors.centerIn: parent; text: "Expense Tracker"; color: "white" }
                    }
                }
            }
        }

        // ---------------- PLANNER PAGE ----------------
        Component {
            id: plannerPage

            Page {

                function getDatabase() {
                    return LocalStorage.openDatabaseSync("SmartPlannerDB", "1.0", "Tasks DB", 1000000);
                }

                function createTable() {
                    var db = getDatabase();
                    db.transaction(function(tx) {
                        tx.executeSql('CREATE TABLE IF NOT EXISTS tasks(name TEXT, done INTEGER, priority TEXT)');
                    });
                }

                function insertTask(name, done, priority) {
                    var db = getDatabase();
                    db.transaction(function(tx) {
                        tx.executeSql('INSERT INTO tasks VALUES(?, ?, ?)', [name, done, priority]);
                    });
                }

                function loadTasks() {
                    var db = getDatabase();
                    taskModel.clear(); // prevent duplicates
                    db.transaction(function(tx) {
                        var results = tx.executeSql('SELECT * FROM tasks');
                        for (var i = 0; i < results.rows.length; i++) {
                            taskModel.append({
                                name: results.rows.item(i).name,
                                done: results.rows.item(i).done,
                                priority: results.rows.item(i).priority
                            });
                        }
                    });
                }

                Component.onCompleted: {
                    createTable();
                    loadTasks();
                }

                header: PageHeader { title: "Daily Planner" }

                Column {
                    anchors.fill: parent
                    anchors.margins: units.gu(2)
                    spacing: units.gu(2)

                    TextField {
                        id: taskInput
                        placeholderText: "Enter task..."
                    }

                    ComboBox {
                        id: priorityBox
                        model: ["Low", "High"]
                    }

                    Button {
                        text: "Add Task"
                        onClicked: {
                            if (taskInput.text !== "") {
                                taskModel.append({
                                    name: taskInput.text,
                                    done: false,
                                    priority: priorityBox.currentText
                                })

                                insertTask(taskInput.text, 0, priorityBox.currentText)
                                taskInput.text = ""
                            }
                        }
                    }

                    ListModel { id: taskModel }

                    ListView {
                        anchors.fill: parent
                        model: taskModel

                        delegate: Rectangle {
                            width: parent.width
                            height: units.gu(7)
                            radius: 8
                            color: priority === "High" ? "#FFCDD2" : "#C8E6C9"

                            Row {
                                anchors.fill: parent
                                anchors.margins: units.gu(1)
                                spacing: units.gu(1)

                                CheckBox {
                                    checked: done
                                    onCheckedChanged: {
                                        taskModel.setProperty(index, "done", checked)
                                    }
                                }

                                Text {
                                    text: name + " (" + priority + ")"
                                    font.pixelSize: 16
                                    color: done ? "gray" : "black"
                                }

                                Button {
                                    text: "❌"
                                    onClicked: taskModel.remove(index)
                                }
                            }
                        }
                    }
                }
            }
        }

        // ---------------- HABIT PAGE ----------------
        Component {
            id: habitPage

            Page {
                header: PageHeader { title: "Habit Tracker" }

                Text {
                    anchors.centerIn: parent
                    text: "Habit system coming soon 🔥"
                    font.pixelSize: 24
                }
            }
        }

        // ---------------- EXPENSE PAGE ----------------
        Component {
            id: expensePage

            Page {
                header: PageHeader { title: "Expense Tracker" }

                Text {
                    anchors.centerIn: parent
                    text: "Expense system coming soon 💰"
                    font.pixelSize: 24
                }
            }
        }
    }
}
