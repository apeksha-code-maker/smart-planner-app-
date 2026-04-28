
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

                    // Button 1
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

                    // Button 2
                    Rectangle {
                        width: units.gu(25)
                        height: units.gu(6)
                        radius: 12
                        color: "#2196F3"

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

                    // Button 3
                    Rectangle {
                        width: units.gu(25)
                        height: units.gu(6)
                        radius: 12
                        color: "#FF9800"

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
                    'CREATE TABLE IF NOT EXISTS tasks(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, description TEXT, done INTEGER, priority TEXT, date TEXT, time TEXT)'
                );
            });
        }

        function insertTask(name, description, done, priority, date, time) {
            var db = getDatabase();
            db.transaction(function(tx) {
                tx.executeSql(
                    'INSERT INTO tasks(name, description, done, priority, date, time) VALUES(?, ?, ?, ?, ?, ?)',
                    [name, description, done, priority, date, time]
                );
            });
        }

        function updateTask(id, done) {
            var db = getDatabase();
            db.transaction(function(tx) {
                tx.executeSql('UPDATE tasks SET done=? WHERE id=?', [done, id]);
            });
        }

        function deleteTask(id) {
            var db = getDatabase();
            db.transaction(function(tx) {
                tx.executeSql('DELETE FROM tasks WHERE id=?', [id]);
            });
        }

        function loadTasks() {
            var db = getDatabase();
            taskModel.clear();

            db.transaction(function(tx) {
                var results = tx.executeSql('SELECT * FROM tasks ORDER BY id DESC');
                for (var i = 0; i < results.rows.length; i++) {
                    var item = results.rows.item(i);
                    taskModel.append({
                        id: item.id,
                        name: item.name,
                        description: item.description,
                        done: item.done,
                        priority: item.priority,
                        date: item.date,
                        time: item.time
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
                placeholderText: "Task title"
            }

            TextField {
                id: descInput
                placeholderText: "Description"
            }

            TextField {
                id: dateInput
                placeholderText: "Date (YYYY-MM-DD)"
            }

            TextField {
                id: timeInput
                placeholderText: "Time (HH:MM)"
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

                        insertTask(
                            taskInput.text,
                            descInput.text,
                            0,
                            priority,
                            dateInput.text,
                            timeInput.text
                        )

                        loadTasks()

                        taskInput.text = ""
                        descInput.text = ""
                        dateInput.text = ""
                        timeInput.text = ""
                    }
                }
            }

            ListModel { id: taskModel }

            ListView {
                anchors.fill: parent
                model: taskModel

                delegate: Rectangle {
                    width: parent.width
                    height: units.gu(9)
                    radius: 10
                    color: priority === "High" ? "#FFCDD2" : "#C8E6C9"

                    Column {
                        anchors.fill: parent
                        anchors.margins: units.gu(1)

                        Row {
                            spacing: units.gu(1)

                            CheckBox {
                                checked: done
                                onCheckedChanged: {
                                    taskModel.setProperty(index, "done", checked)
                                    updateTask(id, checked ? 1 : 0)
                                }
                            }

                            Text {
                                text: name
                                font.bold: true
                            }
                        }

                        Text {
                            text: description
                            font.pixelSize: 14
                            color: "#555"
                        }

                        Text {
                            text: date + "  " + time
                            font.pixelSize: 12
                            color: "#777"
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
