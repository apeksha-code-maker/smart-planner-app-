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
                        text: "Welcome 👋"
                        font.pixelSize: 30
                        font.bold: true
                        color: "#2E7D32"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    function navButton(text, color, page) {
                        return Rectangle {
                            width: units.gu(25)
                            height: units.gu(6)
                            radius: 12
                            color: color

                            MouseArea {
                                anchors.fill: parent
                                onClicked: pageStack.push(page)
                            }

                            Text {
                                anchors.centerIn: parent
                                text: text
                                color: "white"
                                font.pixelSize: 18
                            }
                        }
                    }

                    navButton("Daily Planner", "#4CAF50", plannerPage)
                    navButton("Habit Tracker", "#2196F3", habitPage)
                    navButton("Expense Tracker", "#FF9800", expensePage)
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

                function updateTask(name, done) {
                    var db = getDatabase();
                    db.transaction(function(tx) {
                        tx.executeSql('UPDATE tasks SET done=? WHERE name=?', [done, name]);
                    });
                }

                function deleteTask(name) {
                    var db = getDatabase();
                    db.transaction(function(tx) {
                        tx.executeSql('DELETE FROM tasks WHERE name=?', [name]);
                    });
                }

                function loadTasks() {
                    var db = getDatabase();
                    taskModel.clear();
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

                    OptionSelector {
                        id: priorityBox
                        model: ["Low", "High"]
                    }

                    Button {
                        text: "Add Task"
                        onClicked: {
                            if (taskInput.text !== "") {
                                var priority = priorityBox.model[priorityBox.selectedIndex]

                                taskModel.append({
                                    name: taskInput.text,
                                    done: false,
                                    priority: priority
                                })

                                insertTask(taskInput.text, 0, priority)
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
                                        updateTask(name, checked ? 1 : 0)
                                    }
                                }

                                Text {
                                    text: name + " (" + priority + ")"
                                }

                                Button {
                                    text: "❌"
                                    onClicked: {
                                        deleteTask(name)
                                        taskModel.remove(index)
                                    }
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

                Column {
                    anchors.fill: parent
                    anchors.margins: units.gu(2)
                    spacing: units.gu(2)

                    Text {
                        text: "Track Your Habits"
                        font.pixelSize: 24
                    }

                    ListModel {
                        id: habitModel
                        ListElement { name: "Drink Water"; done: false }
                        ListElement { name: "Exercise"; done: false }
                        ListElement { name: "Read Book"; done: false }
                    }

                    ListView {
                        anchors.fill: parent
                        model: habitModel

                        delegate: Rectangle {
                            width: parent.width
                            height: units.gu(6)
                            radius: 10
                            color: "#E3F2FD"

                            Row {
                                anchors.fill: parent
                                anchors.margins: units.gu(1)

                                CheckBox {
                                    checked: done
                                    onCheckedChanged: habitModel.setProperty(index, "done", checked)
                                }

                                Text {
                                    text: name
                                    font.pixelSize: 18
                                }
                            }
                        }
                    }
                }
            }
        }

        // ---------------- EXPENSE PAGE ----------------
        Component {
            id: expensePage

            Page {
                header: PageHeader { title: "Expense Tracker" }

                Column {
                    anchors.fill: parent
                    anchors.margins: units.gu(2)
                    spacing: units.gu(2)

                    TextField {
                        id: expenseName
                        placeholderText: "Expense name"
                    }

                    TextField {
                        id: expenseAmount
                        placeholderText: "Amount"
                    }

                    Button {
                        text: "Add Expense"
                        onClicked: {
                            if (expenseName.text !== "" && expenseAmount.text !== "") {
                                expenseModel.append({
                                    name: expenseName.text,
                                    amount: expenseAmount.text
                                })
                                expenseName.text = ""
                                expenseAmount.text = ""
                            }
                        }
                    }

                    ListModel { id: expenseModel }

                    ListView {
                        anchors.fill: parent
                        model: expenseModel

                        delegate: Rectangle {
                            width: parent.width
                            height: units.gu(6)
                            radius: 10
                            color: "#FFF3E0"

                            Row {
                                anchors.fill: parent
                                anchors.margins: units.gu(1)
                                spacing: units.gu(2)

                                Text { text: name }
                                Text { text: "₹ " + amount; color: "green" }
                            }
                        }
                    }
                }
            }
        }
    }
}
