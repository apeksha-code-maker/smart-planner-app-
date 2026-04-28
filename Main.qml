
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
                        text: "Smart Planner"
                        font.pixelSize: 28
                        color: "#2E7D32"
                    }

                    // Planner
                    Rectangle {
                        width: units.gu(25); height: units.gu(6)
                        radius: 12; color: "#4CAF50"

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

                    // Habit
                    Rectangle {
                        width: units.gu(25); height: units.gu(6)
                        radius: 12; color: "#2196F3"

                        MouseArea {
                            anchors.fill: parent
                            onClicked: pageStack.push(habitPage)
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "Habit Tracker"
                            color: "white"
                        }
                    }

                    // Expense
                    Rectangle {
                        width: units.gu(25); height: units.gu(6)
                        radius: 12; color: "#FF9800"

                        MouseArea {
                            anchors.fill: parent
                            onClicked: pageStack.push(expensePage)
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "Expense Tracker"
                            color: "white"
                        }
                    }
                }
            }
        }

        // ---------------- DAILY PLANNER ----------------
        Component {
            id: plannerPage

            Page {

                function getDB() {
                    return LocalStorage.openDatabaseSync("PlannerDB", "1.0", "Tasks", 100000);
                }

                function createTable() {
                    var db = getDB();
                    db.transaction(function(tx) {
                        tx.executeSql(
                            'CREATE TABLE IF NOT EXISTS tasks(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, done INTEGER)'
                        );
                    });
                }

                function addTask(name) {
                    var db = getDB();
                    db.transaction(function(tx) {
                        tx.executeSql('INSERT INTO tasks(name, done) VALUES(?,0)', [name]);
                    });
                }

                function updateTask(id, done) {
                    var db = getDB();
                    db.transaction(function(tx) {
                        tx.executeSql('UPDATE tasks SET done=? WHERE id=?', [done, id]);
                    });
                }

                function deleteTask(id) {
                    var db = getDB();
                    db.transaction(function(tx) {
                        tx.executeSql('DELETE FROM tasks WHERE id=?', [id]);
                    });
                }

                function loadTasks() {
                    var db = getDB();
                    taskModel.clear();

                    db.transaction(function(tx) {
                        var rs = tx.executeSql('SELECT * FROM tasks');
                        for (var i = 0; i < rs.rows.length; i++) {
                            var row = rs.rows.item(i);
                            taskModel.append({
                                id: row.id,
                                name: row.name,
                                done: row.done
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
                        id: input
                        placeholderText: "Enter task..."
                    }

                    Button {
                        text: "Add Task"
                        onClicked: {
                            if (input.text !== "") {
                                addTask(input.text)
                                loadTasks()
                                input.text = ""
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
                            color: "#C8E6C9"
                            radius: 8

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

                                Text { text: name }

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

        // ---------------- HABIT TRACKER ----------------
        Component {
            id: habitPage

            Page {
                header: PageHeader { title: "Habit Tracker" }

                ListModel {
                    id: habitModel
                    ListElement { name: "Drink Water"; done: false }
                    ListElement { name: "Exercise"; done: false }
                }

                ListView {
                    anchors.fill: parent
                    model: habitModel

                    delegate: Row {
                        spacing: units.gu(1)

                        CheckBox {
                            checked: done
                            onCheckedChanged: {
                                habitModel.setProperty(index, "done", checked)
                            }
                        }

                        Text { text: name }
                    }
                }
            }
        }

        // ---------------- EXPENSE TRACKER ----------------
        Component {
            id: expensePage

            Page {
                header: PageHeader { title: "Expense Tracker" }

                Column {
                    anchors.fill: parent
                    spacing: units.gu(2)

                    TextField { id: name; placeholderText: "Expense" }
                    TextField { id: amount; placeholderText: "Amount" }

                    Button {
                        text: "Add"
                        onClicked: {
                            if (name.text !== "" && amount.text !== "") {
                                expenseModel.append({
                                    name: name.text,
                                    amount: amount.text
                                })
                                name.text = ""
                                amount.text = ""
                            }
                        }
                    }

                    ListModel { id: expenseModel }

                    ListView {
                        anchors.fill: parent
                        model: expenseModel

                        delegate: Row {
                            spacing: units.gu(2)
                            Text { text: name }
                            Text { text: "₹ " + amount }
                        }
                    }
                }
            }
        }
    }
}
