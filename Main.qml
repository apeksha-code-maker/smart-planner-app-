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

                property string currentFilter: "all"

                function todayStr() {
                    var d = new Date();
                    var mm = String(d.getMonth() + 1).padStart(2, '0');
                    var dd = String(d.getDate()).padStart(2, '0');
                    return d.getFullYear() + "-" + mm + "-" + dd;
                }

                function getDatabase() {
                    return LocalStorage.openDatabaseSync("SmartPlannerDB", "1.0", "Tasks DB", 1000000);
                }

                function createTable() {
                    var db = getDatabase();
                    db.transaction(function(tx) {
                        tx.executeSql('DROP TABLE IF EXISTS tasks');
                        tx.executeSql('CREATE TABLE tasks(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, description TEXT, done INTEGER, priority TEXT, date TEXT, time TEXT)');
                    });
                }

                function insertTask(name, description, done, priority, date, time) {
                    var db = getDatabase();
                    db.transaction(function(tx) {
                        tx.executeSql('INSERT INTO tasks(name, description, done, priority, date, time) VALUES(?, ?, ?, ?, ?, ?)',
                        [name, description, done, priority, date, time]);
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
                        var query = "SELECT * FROM tasks";

                        if (currentFilter === "pending") query += " WHERE done=0";
                        else if (currentFilter === "done") query += " WHERE done=1";

                        query += " ORDER BY date ASC, time ASC";

                        var results = tx.executeSql(query);

                        for (var i = 0; i < results.rows.length; i++) {
                            var item = results.rows.item(i);
                            taskModel.append(item);
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

                    TextField { id: taskInput; placeholderText: "Task title" }
                    TextField { id: descInput; placeholderText: "Description" }
                    TextField { id: dateInput; placeholderText: "YYYY-MM-DD" }
                    TextField { id: timeInput; placeholderText: "HH:MM" }

                    OptionSelector { id: priorityBox; model: ["Low", "High"] }

                    Button {
                        text: "Add Task"
                        onClicked: {
                            if (taskInput.text !== "") {
                                var priority = priorityBox.model[priorityBox.selectedIndex]
                                insertTask(taskInput.text, descInput.text, 0, priority, dateInput.text, timeInput.text)
                                loadTasks()
                                taskInput.text = ""
                                descInput.text = ""
                                dateInput.text = ""
                                timeInput.text = ""
                            }
                        }
                    }

                    Row {
                        spacing: units.gu(1)
                        Button { text: "All"; onClicked: { currentFilter="all"; loadTasks(); } }
                        Button { text: "Pending"; onClicked: { currentFilter="pending"; loadTasks(); } }
                        Button { text: "Done"; onClicked: { currentFilter="done"; loadTasks(); } }
                    }

                    ListModel { id: taskModel }

                    ListView {
                        anchors.fill: parent
                        model: taskModel

                        delegate: Rectangle {
                            width: parent.width
                            height: units.gu(10)
                            radius: 10
                            color: (date === todayStr()) ? "#FFF9C4" :
                                   (priority === "High" ? "#FFCDD2" : "#C8E6C9")

                            Column {
                                width: parent.width
                                anchors.margins: units.gu(1)

                                Row {
                                    spacing: units.gu(1)

                                    CheckBox {
                                        checked: done
                                        onCheckedChanged: {
                                            updateTask(id, checked ? 1 : 0)
                                            loadTasks()
                                        }
                                    }

                                    Text { text: name; font.bold: true }
                                }

                                Text { text: description }
                                Text { text: date + " " + time }

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
                        CheckBox { checked: done }
                        Text { text: name }
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
                    spacing: units.gu(2)

                    TextField { id: ename; placeholderText: "Expense name" }
                    TextField { id: eamt; placeholderText: "Amount" }

                    Button {
                        text: "Add"
                        onClicked: {
                            expenseModel.append({name: ename.text, amount: eamt.text})
                            ename.text = ""
                            eamt.text = ""
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
