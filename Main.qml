
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
                header: PageHeader { title: "Smart Planner" }

                Column {
                    anchors.centerIn: parent
                    spacing: units.gu(3)

                    Text {
                        text: "VERSION 2 🔥"
                        color: "red"
                    }

                    Text {
                        text: "Welcome 👋"
                        font.pixelSize: 30
                        color: "#2E7D32"
                    }

                    Rectangle {
                        width: units.gu(25)
                        height: units.gu(6)
                        radius: 12
                        color: "#4CAF50"

                        MouseArea {
                            anchors.fill: parent
                            onClicked: pageStack.push(plannerPage)
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "Daily Planner"
                            color: "white"
                        }
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
                        tx.executeSql(
                            'CREATE TABLE IF NOT EXISTS tasks(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, done INTEGER)'
                        );
                    });
                }

                function insertTask(name) {
                    var db = getDatabase();
                    db.transaction(function(tx) {
                        tx.executeSql(
                            'INSERT INTO tasks(name, done) VALUES(?, ?)',
                            [name, 0]
                        );
                    });
                }

                function updateTask(id, done) {
                    var db = getDatabase();
                    db.transaction(function(tx) {
                        tx.executeSql(
                            'UPDATE tasks SET done=? WHERE id=?',
                            [done, id]
                        );
                    });
                }

                function deleteTask(id) {
                    var db = getDatabase();
                    db.transaction(function(tx) {
                        tx.executeSql(
                            'DELETE FROM tasks WHERE id=?',
                            [id]
                        );
                    });
                }

                function loadTasks() {
                    var db = getDatabase();
                    taskModel.clear();

                    db.transaction(function(tx) {
                        var results = tx.executeSql('SELECT * FROM tasks');

                        for (var i = 0; i < results.rows.length; i++) {
                            var item = results.rows.item(i);
                            taskModel.append({
                                id: item.id,
                                name: item.name,
                                done: item.done
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

                    Button {
                        text: "Add Task"
                        onClicked: {
                            if (taskInput.text !== "") {
                                insertTask(taskInput.text)
                                loadTasks()
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
                            height: units.gu(6)
                            radius: 8
                            color: "#C8E6C9"

                            Row {
                                anchors.fill: parent
                                anchors.margins: units.gu(1)
                                spacing: units.gu(1)

                                CheckBox {
                                    checked: done
                                    onCheckedChanged: {
                                        updateTask(id, checked ? 1 : 0)
                                        loadTasks()
                                    }
                                }

                                Text {
                                    text: name
                                }

                                Button {
                                    text: "Delete"
                                    onClicked: {
                                        deleteTask(id)
                                        loadTasks()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
