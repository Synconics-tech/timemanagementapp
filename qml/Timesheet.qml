/*
 * Copyright (C) 2024  Synconics Technologies Pvt. Ltd.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * odooprojecttimesheet is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */ 

import QtQuick 2.7
import QtQuick.Controls 2.2
import Lomiri.Components 1.3
import Lomiri.Components.Pickers 1.3
import QtCharts 2.0
import QtQuick.Window 2.2
import Qt.labs.settings 1.0
import "../models/Timesheet.js" as Model
import "../models/DbInit.js" as DbInit
import "../models/DemoData.js" as DemoData


Page{
    id: timeSheet
    title: "Timesheet"
        header: PageHeader {
        title: timeSheet.title
        ActionBar {
                numberOfSlots: 1
                anchors.right: parent.right
            //    enable: true
                actions: [
                    Action {
                        iconName: "save"
                        text: "Save"
                        onTriggered:{
                            save_timesheet();
                            console.log("Timesheet Save Button clicked");

                        }
                    }
                ]
        }
    }

    ListModel {
        id: projectModel1
    }    

    function prepare_subproject_list(){
        var subprojects = Model.fetch_sub_project(project_id, workpersonaSwitchState)
        console.log("In prepare_subproject_list()")  
        if (subprojects.length > 0)
        {    
            myRow9.visible = true
            for (var subproject = 0; subproject < subprojects.length; subproject++) {
//                projectModel1.append({'id': subprojects[subproject].id, 'name': subprojects[subproject].name})
                subprojectModel.append({'name': subprojects[subproject].name})
            }       
            for (var subproject = 0; subproject < subprojectModel.count; subproject++) {
                console.log("ProjectModel1 " + "id: " + projectModel1.get(project).id + " Project: " + projectModel1.get(project).name)
//                console.log("SubProjectModel " + " Subproject: " + subprojectModel.get(project).name)
            }
        }
    }




    function save_timesheet() {
        console.log("Timesheet Saved");
        var timesheet_data = {
            'dateTime': date_text.text,
            'project': selectedProjectId,
            'task': selectedTaskId,
            'subprojectId': selectedsubProjectId,
            'subTask': combo4.editText,
            'description': description_text.text,
            'manualSpentHours': hours_text.text,
            'spenthours': hours_text.text,
            'isManualTimeRecord': isManualTime
        }
        Model.create_timesheet(timesheet_data)
    }


    function set_project_id(project_name) {
        for (var project = 0; project < projectModel1.count; project++) {
            if(projectModel1.get(project).name === project_name) {
                console.log("ProjectModel1 " + "id: " + projectModel1.get(project).id + " Project: " + projectModel1.get(project).name)
                selectedProjectId = projectModel1.get(project).id            
            }
        }         
    }


    function set_subproject_id(subproject_name) {
        for (var subproject = 0; subproject < subprojectModel.count; project++) {
            if(subprojectModel.get(subproject).name === subproject_name) {
//                console.log("ProjectModel1 " + "id: " + projectModel1.get(project).id + " Project: " + projectModel1.get(project).name)
                selectedsubProjectId = subprojectModel.get(subproject).id            
            }
        }         
    }



    function prepare_project_list() {
        var projects = Model.fetch_projects(false, workpersonaSwitchState)
        console.log("In prepare_project_list()")      
        for (var project = 0; project < projects.length; project++) {
            projectModel1.append({'id': projects[project].id, 'name': projects[project].name})
            projectModel.append({'name': projects[project].name})
        }       
        for (var project = 0; project < projectModel.count; project++) {
            console.log("ProjectModel1 " + "id: " + projectModel1.get(project).id + " Project: " + projectModel1.get(project).name)
            console.log("ProjectModel " + " Project: " + projectModel.get(project).name)
        } 
    }

    function set_task_id(task_name) {
        for (var task = 0; task < taskModel1.count; task++) {
            if(taskModel1.get(task).name === task_name) {
                console.log("TaskModel1 " + "id: " + taskModel1.get(task).id + " Task: " + taskModel1.get(task).name)
                selectedTaskId = taskModel1.get(task).id            
            }
        }         
    }

    function prepare_task_list(project_id) {
        var tasks = Model.fetch_tasks_list(project_id, false, workpersonaSwitchState)
        taskModel.clear();
        taskModel1.clear();
        selectedTaskId = 0;
        console.log("Passed Project ID: " + project_id)
//        task_field.text = "Select Task";
        for (var task = 0; task < tasks.length; task++) {
            taskModel.append({'name': tasks[task].name})
            taskModel1.append({'id': tasks[task].id, 'name': tasks[task].name})
        }
        for (var task = 0; task < taskModel.count; task++) {
            console.log("TaskModel1 " + "id: " + taskModel1.get(task).id + " Task: " + taskModel1.get(task).name)
            console.log("TaskModel " + " Task: " + taskModel.get(task).name)
        } 
     }



    function prepare_subtask_list(task_id) {
        var tasks = Model.fetch_sub_tasks(task_id, workpersonaSwitchState)
        subtaskModel.clear();
//        taskModel1.clear();
        selectedTaskId = 0;
        console.log("Passed Task ID: " + task_id)
        for (var task = 0; task < tasks.length; task++) {
            subtaskModel.append({'name': tasks[task].name})
//            taskModel1.append({'id': tasks[task].id, 'name': tasks[task].name})
        }
        for (var task = 0; task < taskModel.count; task++) {
//            console.log("TaskModel1 " + "id: " + taskModel1.get(task).id + " Task: " + taskModel1.get(task).name)
            console.log("SubTaskModel " + " Task: " + subtaskModel.get(task).name)
        } 
     }

    function formatTime(seconds) {
        var hours = Math.floor(seconds / 3600);  
        var minutes = Math.floor((seconds % 3600) / 60);  
        var secs = seconds % 60; 

        return (hours < 10 ? "0" + hours : hours) + ":" +  
            (minutes < 10 ? "0" + minutes : minutes) + ":" +
            (secs < 10 ? "0" + secs : secs);
    }



    ListModel {
        id: taskModel1
    }

    property bool workpersonaSwitchState: false
    property bool isTimesheetClicked: false
    property bool isManualTime: false
    property var currentTime: false
    property int elapsedTime: 0
    property int storedElapsedTime: 0
    property bool running: false
    property int selectedProjectId: 0
    property int selectedTaskId: 0 
    property bool hasSubProject: false;
    property bool edithasSubProject: false;
    property bool hasSubTask: false;
    property bool edithasSubTask: false;
    property int selectedSubTaskId: 0

    Timer {
        id: stopwatchTimer
        interval: 1000  
        repeat: true
        onTriggered: {
            elapsedTime += 1
        }
    }

    LomiriShape {
        id: rect1
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        radius: "large"
        width: parent.width
        height: parent.height

        Row{
                id: myRow1
                anchors.horizontalCenter:parent.horizontalCenter 
                topPadding: 40
                Column{
                        leftPadding: units.gu(5)
                        Rectangle {
                            width: units.gu(10)
                            height: units.gu(5)
                             Label {
                                id: date_label                            
                                text: "Date"
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                //textSize: Label.Large
                            }
                        }
                }
                Column{
                       leftPadding: units.gu(5)
                        TextField {
                            id: date_text
                            width: Screen.desktopAvailableWidth < units.gu(250) ? units.gu(30) : units.gu(60)
                            text: Qt.formatDate(date_field.date, "dddd, dd-MMMM-yyyy")
                            MouseArea {
                                anchors.fill: parent
                                onClicked: { date_field.visible = !date_field.visible }
                            }
                    }
                    DatePicker {
                            id: date_field
                            visible: false
                            z: 1
//                            anchors.top: date_label.bottom
//                            anchors.left:date_label.left
                            minimum: {
                                var d = new Date();
                                d.setFullYear(d.getFullYear() - 1);
                                return d;
                            }
                            maximum: Date.prototype.getInvalidDate.call()
        //                    Component.onCompleted: set(new Date()) // 12022025 GM: commented out for testing 
                    }

                }       
        }
        Row{
                id: myRow2
                anchors.top: myRow1.bottom
                anchors.horizontalCenter:parent.horizontalCenter 
                topPadding: 10
                Column{
                    id: myCol
                        leftPadding: units.gu(5)
                        Rectangle {
                            width: units.gu(10)
                            height: units.gu(5)
                            Label {
                                id: project_label                             
                                text: "Project"
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                //textSize: Label.Large
                        }
                    }
                }
                Column{
                    id: myCol1
                    leftPadding: units.gu(5)
                    LomiriShape{                        
                        width: Screen.desktopAvailableWidth < units.gu(250) ? units.gu(30) : units.gu(60)
                        height: 40
                        ComboBox {
                            id: combo1
                            editable: true
                            width: parent.width
                            height: parent.height
                            anchors.centerIn: parent.centerIn
                            flat: true
                            model:  ListModel {
                                        id: projectModel
                                    }  

                            onActivated: {
                                console.log("In onActivated")
                                set_project_id(editText) 
//                                prepare_subproject_list()
                                prepare_task_list(selectedProjectId)
                                console.log("Project ID: " + selectedProjectId + " edittext: " + editText)                        
                            }        
                            onHighlighted: {
                                console.log("In onHighlighted")
                                console.log("Combobox height: " + combo1.height)
                            }
                            onAccepted: {
                                console.log("In onAccepted")
                                if (find(editText) != -1)
                                {
                                    set_project_id(editText) 
                                    prepare_task_list(selectedProjectId)
                                    console.log("Project ID: " + selectedProjectId)                        
                                }
                            } 

                        }
                }

                }       
        }
/************************************************************
*       Added Sub Project below                             *
************************************************************/
        Row{
                id: myRow9
                anchors.top: myRow2.bottom
                anchors.horizontalCenter:parent.horizontalCenter 
                topPadding: 10
                visible: false
                Column{
                    id: myCol8
                        leftPadding: units.gu(5)
                        Rectangle {
                            width: units.gu(10)
                            height: units.gu(5)
                            Label {
                                id: subproject_label                             
                                text: "Sub Project"
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                //textSize: Label.Large
                        }
                    }
                }
                Column{
                    id: myCol9
                    leftPadding: units.gu(5)
                    LomiriShape{                        
                        width: Screen.desktopAvailableWidth < units.gu(250) ? units.gu(30) : units.gu(60)
                        height: 40
                        ComboBox {
                            id: combo3
                            editable: true
                            width: parent.width
                            height: parent.height
                            anchors.centerIn: parent.centerIn
                            flat: true
                            model:  ListModel {
                                        id: subprojectModel
                                    }  

                            onActivated: {
                                console.log("In onActivated")
                                set_subproject_id(editText) 
//                                prepare_task_list(selectedProjectId)
                                console.log("Sub Project ID: " + selectedsubProjectId + " edittext: " + editText)                        
                            }        
                            onHighlighted: {
                                console.log("In onHighlighted")
                                console.log("Combobox height: " + combo1.height)
                            }
                            onAccepted: {
                                console.log("In onAccepted")
                                if (find(editText) != -1)
                                {
                                    set_subproject_id(editText) 
//                                    prepare_task_list(selectedProjectId)
                                    console.log("Sub Project ID: " + selectedsubProjectId)                        
                                }
                            } 

                        }
                }

                }       
        }


/**********************************************************/

        Row{
                id: myRow3
                anchors.top: myRow9.bottom
                anchors.horizontalCenter:parent.horizontalCenter 
                topPadding: 10
                Column{
                        leftPadding: units.gu(5)
                        Rectangle {
                            width: units.gu(10)
                            height: units.gu(5)
                            Label {
                                id: task_label                             
                                text: "Task"
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                //textSize: Label.Large
                        }
                    }
                }
                Column{
                       leftPadding: units.gu(5)
                        LomiriShape{                        
                            width: Screen.desktopAvailableWidth < units.gu(250) ? units.gu(30) : units.gu(60)
                            height: 40
                            ComboBox {
                                id: task_field
                                editable: true
                                width: parent.width
                                height: parent.height
                                anchors.centerIn: parent.centerIn
                                flat: true


                                model:  ListModel {
                                            id: taskModel
                                        }  

                                onActivated: {
                                    console.log("In onActivated")
                                    set_task_id(editText) 
                                    myRow10.visible = true
                                    console.log("Task ID: " + selectedTaskId)                        
                                }        
                                onHighlighted: {
                                    console.log("In onHighlighted")
                                }
                                onAccepted: {
                                    console.log("In onAccepted")
                                    if (find(editText) != -1){
                                        set_task_id(editText) 
                                        console.log("Task ID: " + selectedTaskId)                        

                                        }

                                } 

                            }
                        }
                }
    
        }

/************************************************************
*       Added Sub Task below                             *
************************************************************/
        Row{
                id: myRow10
                anchors.top: myRow3.bottom
                anchors.horizontalCenter:parent.horizontalCenter 
                topPadding: 10
                visible: false
               Column{
                    id: myCol10
                        leftPadding: units.gu(5)
                        Rectangle {
                            width: units.gu(10)
                            height: units.gu(5)
                            Label {
                                id: subtask_label                             
                                text: "Sub Task"
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                //textSize: Label.Large
                        }
                    }
                }
                Column{
                    id: myCol11
                    leftPadding: units.gu(5)
                    LomiriShape{                        
                        width: Screen.desktopAvailableWidth < units.gu(250) ? units.gu(30) : units.gu(60)
                        height: 40
                        ComboBox {
                            id: combo4
                            editable: true
                            width: parent.width
                            height: parent.height
                            anchors.centerIn: parent.centerIn
                            flat: true
                            model:  ListModel {
                                        id: subtaskModel
                                    }  

                            onActivated: {
                                console.log("In onActivated")
                            }        
                            onHighlighted: {
                                console.log("In onHighlighted")
                            }
                            onAccepted: {
                                console.log("In onAccepted")
                                if (find(editText) != -1)
                                {
                                    console.log("Sub Task: " + editText)                        
                                }
                            } 

                        }
                }

                }       
        }


/**********************************************************/


        Row{
                id: myRow4
                anchors.top: myRow10.bottom
                anchors.horizontalCenter:parent.horizontalCenter 
                topPadding: 10
                Column{
                        leftPadding: units.gu(5)
                        Rectangle {
                            width: units.gu(10)
                            height: units.gu(5)
                            Label {
                                id: description_label                             
                                text: "Description"
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                //textSize: Label.Large
                        }
                    }
                }
                Column{
                       leftPadding: units.gu(5)
                        TextField {
                            id: description_text
                            width: Screen.desktopAvailableWidth < units.gu(250) ? units.gu(30) : units.gu(60)
                            text: "Enter Description"
                        }
                }       
        }
        Row{
                id: myRow5
                anchors.top: myRow4.bottom
                anchors.horizontalCenter:parent.horizontalCenter 
                topPadding: 10
                Column{
                        leftPadding: units.gu(5)
                        Rectangle {
                            width: units.gu(10)
                            height: units.gu(5)
                            Label {
                                id: hours_label                             
                                text: "Spent Hours"
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                //textSize: Label.Large
                        }
                    }
                }
                Column{
                       leftPadding: units.gu(5)
                        TextField {
                            id: hours_text
                            width: Screen.desktopAvailableWidth < units.gu(250) ? units.gu(30) : units.gu(60)
                            text: formatTime(elapsedTime)
                        }
                }       
        }
        Row{
                id: myRow6
                anchors.top: myRow5.bottom
                anchors.horizontalCenter:parent.horizontalCenter 
                topPadding: units.gu(5)
                Column{
                       leftPadding: units.gu(5)
                        Button {
                                objectName: "button_start"
                                width: units.gu(10)
                                iconName: "media-playback-start"
                                action: Action {
                                    text: i18n.tr("Start")
                                    property bool flipped
                                    onTriggered: flipped = !flipped
                                }
                                color: action.flipped ? LomiriColors.blue : LomiriColors.green
                                onClicked: {
                                    if (running) {
                                        currentTime = false;
                                        storedElapsedTime = elapsedTime;
                                        stopwatchTimer.stop();
                                    } else {
                                        console.log("Started")
                                        currentTime = new Date()
                                        stopwatchTimer.start();
                                    }
                                    running = !running
/*                                    if (taskssmartBtn != null) {
                                        timestart = true
                                        idstarttime = selectedTaskId
                                    }*/                                
                                }
                        }
                }
                Column{
                       leftPadding: units.gu(5)
                        Button {
                                objectName: "button_stop"
                                width: units.gu(10)
                                action: Action {
                                    text: i18n.tr("Stop")
                                    property bool flipped
                                    onTriggered: flipped = !flipped
                                }
                                color: action.flipped ? LomiriColors.green : LomiriColors.red
                                onClicked: {
                                                running = !running
                                                 stopwatchTimer.stop();
//                                                 hours_text.text = formatTime(elapsedTime)
                                }
                        }
                }
                Column{
                       leftPadding: units.gu(5)
                        Button {
                                objectName: "button_manual"
                                width: units.gu(10)
                                action: Action {
                                    text: i18n.tr("Manual")
                                    property bool flipped
                                    onTriggered: {flipped = !flipped
                                    isManualTime = true}
                                }
                                color: action.flipped ? LomiriColors.blue : LomiriColors.slate
                        }
                }       
        }

/**********************************************************
* 18022025: Added Slider for the Quadrants         *
**********************************************************/

                            Row {
                                id: myRow7
                                anchors.top: myRow6.bottom
                                topPadding: units.gu(5)                                
                                leftPadding: units.gu(5)
//                                spacing: isDesktop() ? 10 : phoneLarg() ? 15 : 20

                                Label {
                                    id: priority
                                    height: units.gu(10)
                                    text: "Select Priority Quadrant"
//                                    font.pixelSize: isDesktop() ? 18 : phoneLarg() ? 30 : 40
                                    
                                }
                                Row{
                                    id: myRow11
                                    width: units.gu(20)
                                    anchors.top: priority.bottom
                                    topPadding: units.gu(5)                                
                                    leftPadding: units.gu(10)
                                    Column{
                                           leftPadding: units.gu(5)
                                    }
                                    Column{
                                           leftPadding: units.gu(5)
                                        Slider {
                                            id: mySlider
    //                                        function formatValue(v) { return v.toFixed(2) }
                                            anchors.centerIn: parent
                                            minimumValue: 1
                                            maximumValue: 4
                                            value: 0
                                            live: false
                                        }
                                    }
                                }

                            }

/*********************************************************/

    /********************************
    * The Legends for the slider *
    ********************************/

        LomiriShape {
            id: rect3
            anchors.top: myRow7.bottom
            width: parent.width
            height: units.gu(10)

                Column{
                        id: myCollegend1
                        topPadding: units.gu(5)
                        spacing: 2
                        leftPadding: 10
                        Row{
                                spacing: 2
                                 Label {
                                        id: myLabel_1
                                        text: qsTr("1: ")
                                    }
                            
                                Label {
                                        id: myLabel_2
                                        text: qsTr("Important, Urgent")
                                    }
                            }
                        Row{
                                spacing: 2
                                 Label {
                                        id: myLabel_3
                                        text: qsTr("2: ")
                                    }
                            
                                Label {
                                        id: myLabel_4
                                        text: qsTr("Important, Not Urgent")
                                    }
                        }       

                }
                Column{
                        id: myCollegend2
                        anchors.left: myCollegend1.right
                        topPadding: units.gu(5)
                        spacing: 2
                        leftPadding: 10
                        Row{
                                spacing: 2
                                    Label {
                                            id: myLabel_5
                                            text: qsTr("3: ")
                                        }
                                
                                Label {
                                        id: myLabel_6
                                        text: qsTr("Not Important, Urgent")
                                    }
                        }       
                        Row{
                                spacing: 2
                                    Label {
                                            id: myLabel_7
                                            text: qsTr("4: ")
                                        }
                                
                                Label {
                                        id: myLabel_8
                                        text: qsTr("Not Important, Not Urgent")
                                    }
                        }       

                }

        }   
/**********************************************************/


        Component.onCompleted: {
            console.log("From Timesheet " + columns);
//            console.log("From Timesheet myRow2 " + myRow2);
//            console.log("From Timesheet myRow2.myCol1 " + myRow2.myCol1);
//            console.log("From Timesheet myRow2.myCol1.combo1 " + myRow2.myCol1.combo1);
//            console.log("From Timesheet myRow2.myCol1.combo1.projectModel " + myRow2.myCol1.combo1.projectModel);
            console.log("From Timesheet projectModel " + projectModel);
            prepare_project_list()

        }

    }




}