/*
 * Copyright (C) 2025  Monk Consulting
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * scrollbarex is distributed in the hope that it will be useful,
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
import QtQuick.Window 2.2
import Ubuntu.Components 1.3 as Ubuntu
import QtQuick.LocalStorage 2.7
import "../models/Timesheet.js" as Model
import "../models/Project.js" as Project

Page{
    id: project
    title: "Project"
    header: PageHeader {
        title: project.title
        trailingActionBar.actions: [
            Action {
                iconName: "add"
                onTriggered: {
                    rightPanelVisible = true;
                }
            }
        ]
    }
    property var filterprojectlistData: []
    property var listData: []
    property int currentRecordId: 0
    property var rightPanelVisible: false;
    property var workpersonaSwitchState: true;
    property bool isProjectEdit: false
    property bool isEditProjectClicked: false
    property string selectedColor: ''
    property int selectedAccountUserId: 0 
    property int selectedparentProjectId: 0 
    property var color_indexes: ["#ffffff","#111111","#960334","#FB3778", "#7C0396","#D937FB", "#030396","#3737FB", "#008585","#33FFFF", "#038203","#37FB37", "#787802","#FBFB37", "#964D03","#FB9937"]
    function fetch_projects_list() {
        var projectsList = Project.fetch_projects_list(workpersonaSwitchState);
        listData = projectsList;
        projectListView.model = projectsList;
    }
    Rectangle {
        width: parent.width
        visible: !rightPanelVisible
        anchors.top: header.bottom
        anchors.fill: parent
        anchors.topMargin: header.height
        // height: parent.height
        Flickable {
            id: projectFlickable
            anchors.fill: parent
            contentHeight: column.height
            flickableDirection: Flickable.VerticalFlick
            // clip: true 
            width: parent.width
            property string edit_id: ""
            Column {
                id: column
                width: parent.width
                spacing: 0
                
                Repeater {
                    id: projectListView
                    model: listData
                    delegate: Column {
                        width: parent.width
                        Rectangle {
                            id: menRow
                            width: parent.width
                            height: units.gu(10)
                            color: currentRecordId === modelData.id ? "#F5F5F5" : "#FFFFFF"  
                            border.color: "#CCCCCC"
                            border.width: 2

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    currentRecordId = modelData.id;
                                    // rightPanel.visible = true
                                    rightPanelVisible = true;
                                    projectFlickable.edit_id= modelData.id;
                                    rightPanel.loadprojectData();
                                }
                            }

                            Row {
                                width: parent.width
                                height: units.gu(5)
                                spacing: 0  

                                ToolButton {
                                    id: down_next
                                    width: units.gu(5)
                                    height: units.gu(5)
                                    anchors.top: parent.top
                                    anchors.topMargin: 1
                                    background: Rectangle {
                                        color: "transparent"  
                                    }
                                    contentItem: Ubuntu.Icon {
                                        name: dataId.shown ? "down" : "next"
                                    }
                                    onClicked: {
                                        onClicked:{
                                            dataId.shown = !dataId.shown
                                        }
                                    }
                                }

                                Column {
                                    width: parent.width - (units.gu(5))  
                                    spacing: 0

                                    Row {
                                        width: parent.width
                                        height: units.gu(5)
                                        spacing: units.gu(5) 

                                        Rectangle {
                                            width: 10  
                                            height: units.gu(10)
                                            anchors.top: parent.top
                                            anchors.topMargin: 1
                                            color: modelData.color_pallet != null ? modelData.color_pallet : '#FFFFFF'
                                        }
                                        Row {
                                            spacing: 10
                                            anchors.left: parent.left
                                            anchors.leftMargin: units.gu(2)
                                            anchors.verticalCenter: parent.verticalCenter
                                            width: parent.width * 0.4
                                            id: left_row


                                            Image {
                                                id: starImageList
                                                source: modelData.favorites > 0 ? "images/star-active.svg" : "images/starinactive.svg" 
                                                width: units.gu(2)
                                                height: units.gu(2)
                                                smooth: true  
                                            }

                                            Text {
                                                text: "Project: " + modelData.name
                                                
                                                font.pixelSize: units.gu(1)
                                                color: "#000000"
                                                anchors.verticalCenter: parent.verticalCenter
                                                width: parent.width * 0.8  
                                                elide: Text.ElideRight
                                            }
                                        }

                                        Text {
                                            text: " "
                                            font.pixelSize: units.gu(1)
                                            color: "#000000"  
                                            anchors.verticalCenter: parent.verticalCenter
                                            anchors.left: left_row.right
                                            // anchors.leftMargin: units.gu(5)
                                            width: parent.width * 0.4
                                            elide: Text.ElideRight
                                        }
                                        
                                        Text {
                                            text: modelData.status
                                            font.pixelSize: units.gu(1)
                                            color: "#000000"  
                                            anchors.verticalCenter: parent.verticalCenter
                                            anchors.right: parent.right
                                            horizontalAlignment: Text.AlignRight 
                                            anchors.rightMargin: units.gu(5)
                                            width: parent.width * 0.3
                                        }
                                    }

                                    Row {
                                        width: parent.width
                                        height: units.gu(5)  
                                        spacing: units.gu(5)

                                        
                                        Text {
                                            id: enddate_id
                                            text: "End Date: " + modelData.planned_end_date
                                            font.pixelSize: units.gu(1)
                                            color: "#000000"
                                            anchors.verticalCenter: parent.verticalCenter
                                            anchors.left: parent.left
                                            anchors.leftMargin: units.gu(5)
                                            width: parent.width * 0.4

                                        }

                                        
                                        Text {
                                            text: "Allocated Hours: " + modelData.allocated_hours
                                            font.pixelSize: units.gu(1)
                                            color: "#000000"
                                            anchors.verticalCenter: parent.verticalCenter
                                            anchors.left: enddate_id.right
                                            // anchors.leftMargin: units.gu(5)
                                            width: parent.width * 0.4
                                        }

                                        
                                        Text {
                                            text: "(" + modelData.total_tasks + ") Tasks"
                                            font.pixelSize: units.gu(1)
                                            color: "#000000"
                                            anchors.verticalCenter: parent.verticalCenter
                                            anchors.right: parent.right
                                            horizontalAlignment: Text.AlignRight 
                                            anchors.rightMargin: units.gu(5)
                                            width: parent.width * 0.3
                                        }
                                    }
                                }
                            }

                        }
                        Repeater {
                            model: modelData.children
                            id: dataId
                            property bool shown: false
                            delegate:Rectangle{
                                width: parent.width - (units.gu(5))
                                height: dataId.shown ?  units.gu(5) : 0
                                color: currentRecordId === modelData.id ? "#F5F5F5" : "#FFFFFF"  
                                border.color: "#CCCCCC"
                                border.width:1
                                id: paneSettingsList
                                visible: height > 0
                                anchors.left: parent.left
                                anchors.leftMargin: units.gu(5)

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        currentRecordId = modelData.id;
                                        rightPanelVisible = true;
                                        projectFlickable.edit_id= modelData.id;
                                        rightPanel.loadprojectData();
                                    }
                                }

                                Row {
                                    height: units.gu(5)
                                    width: parent.width
                                    
                                    spacing: 0  
                                    

                                    Column {
                                        width: parent.width
                                         // - units.gu(5)  
                                        spacing: 0

                                        Row {
                                            width: parent.width
                                            height: units.gu(5)
                                            spacing: units.gu(5) 
                                            Rectangle {
                                                width: units.gu(1)  
                                                height: units.gu(5)
                                                anchors.top: parent.top
                                                anchors.leftMargin: units.gu(1)
                                                color: modelData.color_pallet != null ? modelData.color_pallet : '#FFFFFF'
                                            }

                                            Row {
                                                spacing: 10
                                                anchors.left: parent.left
                                                anchors.leftMargin: units.gu(1)
                                                anchors.verticalCenter: parent.verticalCenter
                                                width: parent.width * 0.4
                                                id: left_row

                                                Image {
                                                    id: starImageList
                                                    source: modelData.favorites > 0 ? "images/star-active.svg" : "images/starinactive.svg" 
                                                    width: units.gu(2)
                                                    height: units.gu(2)
                                                    smooth: true
                                                }

                                                Text {
                                                    text: "Project: " + modelData.name
                                                    font.pixelSize: units.gu(1)
                                                    color: "#000000"
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    width: parent.width * 0.8  
                                                    elide: Text.ElideRight
                                                }
                                            }
                                            
                                            Text {
                                                text: modelData.parentProject
                                                font.pixelSize: units.gu(1)
                                                color: "#000000"  
                                                anchors.verticalCenter: parent.verticalCenter
                                                anchors.left: left_row.right
                                                anchors.leftMargin: units.gu(5)
                                                width: parent.width * 0.4
                                                elide: Text.ElideRight
                                            }
                                            
                                            Text {
                                                text: modelData.status
                                                font.pixelSize: units.gu(1)
                                                color: "#000000"  
                                                anchors.verticalCenter: parent.verticalCenter
                                                anchors.right: parent.right
                                                horizontalAlignment: Text.AlignRight 
                                                anchors.rightMargin: units.gu(5)
                                                width: parent.width * 0.3
                                            }
                                        }

                                        Row {
                                            width: parent.width
                                            height: units.gu(5)
                                            spacing: units.gu(5)

                                            
                                            Text {
                                                id: enddate_id
                                                text: "End Date: " + modelData.planned_end_date
                                                font.pixelSize: units.gu(1)
                                                color: "#000000"
                                                anchors.verticalCenter: parent.verticalCenter
                                                anchors.left: parent.left
                                                anchors.leftMargin: units.gu(5)
                                                width: parent.width * 0.4

                                            }

                                            
                                            Text {
                                                text: "Allocated Hours: " + modelData.allocated_hours
                                                font.pixelSize: units.gu(1)
                                                color: "#000000"
                                                anchors.verticalCenter: parent.verticalCenter
                                                anchors.left: enddate_id.right
                                                anchors.leftMargin: units.gu(5)
                                                width: parent.width * 0.4
                                            }

                                            
                                            Text {
                                                text: "(" + modelData.total_tasks + ") Tasks"
                                                font.pixelSize: units.gu(1)
                                                color: "#000000"
                                                anchors.verticalCenter: parent.verticalCenter
                                                anchors.right: parent.right
                                                horizontalAlignment: Text.AlignRight 
                                                anchors.rightMargin: units.gu(5)
                                                width: parent.width * 0.3
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
    }

    Rectangle {
        id: rightPanel
        z: 20
        visible: rightPanelVisible
        height: parent.height
        anchors.top: header.bottom
        color: "#EFEFEF"
        anchors.bottom: parent.bottom
        function loadprojectData() {
            var rowId = projectFlickable.edit_id;
            var project_details = Project.get_project_detail(rowId, workpersonaSwitchState);
            startDateInput.text = project_details.start_date;
            endDateInput.text = project_details.end_date;
            accountInput.text = project_details.account_name;
            nameInput.text = project_details.name;
            allocatedhoursInput.text = project_details.allocated_hours;
            selectedAccountUserId = project_details.account_id;
            selectedColor = project_details.selected_color;
            parentProjectInput.text = project_details.parent_project_name;
            selectedparentProjectId = project_details.parent_id;
            img_star.selectedPriority = project_details.favorites;
            descriptionProject.text = project_details.description;
        }
        
        Column {
            anchors.fill: parent
            
            Row {
                width: parent.width
                anchors.top: parent.top
                spacing: 5  

                Button {
                    id: crossButton
                    width: units.gu(2)
                    height: units.gu(2)
                    anchors.leftMargin: units.gu(2)
                    
                    

                    Image {
                        source: "images/cross.svg" 
                        width: units.gu(2)
                        height: units.gu(2)
                    }

                    onClicked: {
                        // rightPanel.visible = false 
                        rightPanelVisible = false;
                        currentRecordId = -1
                    }
                } 
                Timer {
                    id: projectEditTimer
                    interval: 2000  
                    repeat: false
                    onTriggered: {
                        isProjectEdit = false;
                        isEditProjectClicked = false;
                    }
                }
                Button {
                    // visible: !workpersonaSwitchState
                    visible: false
                    id: rightButton
                    anchors.right: crossButton.right
                    // anchors.top: parent.top
                    // anchors.topMargin: 10
                    width: units.gu(2)
                    height: units.gu(2)
                    // anchors.rightMargin: units.gu(30)

                    Image {
                        source: "images/right.svg" 
                        width: units.gu(2)
                        height: units.gu(2)
                    }

                    // background: Rectangle {
                    //     color: "transparent"
                    //     radius: 10
                    //     border.color: "transparent"
                    // }

                    onClicked: {
                        var rowId = projectFlickable.edit_id;
                        const editData = {
                            updatedProject: nameInput.text ,
                            updatedAccount: selectedAccountUserId,
                            updatedDescription: descriptionProject.text,
                            updatedstartDate: startDateInput.text,
                            updatedendDate: endDateInput.text,
                            updatedparentProject: selectedparentProjectId,                                            
                            updateallocatedhoursInput:allocatedhoursInput.text,
                            img_star: img_star.selectedPriority,
                            rowId: rowId,
                            color_pallet: selectedColor
                        }
                        if(nameInput.text){
                            isProjectEdit = true
                            isEditProjectClicked = true
                            editprojectData(editData)
                            filterProjectList(searchField.text)
                            projectEditTimer.start()
                            

                        }else{
                            isProjectEdit = false
                            isEditProjectClicked = true
                            projectEditTimer.start()
                        }
                    }
                }
            }

            Flickable {
                id: flickableContainerProject
                width: parent.width
                
                height: parent.height  
                contentHeight: projectItemedit.childrenRect.height
                anchors.fill: parent
                flickableDirection: Flickable.VerticalFlick  
                anchors.top: parent.top
                Item {
                    id: projectItemedit
                    height: projectItemedit.childrenRect.height
                     // + 100
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.leftMargin: 0
                    anchors.topMargin: units.gu(5)
                    Row {
                        anchors.left: parent.left
                        Column {
                            spacing: 10
                            width: units.gu(20)
                            Label { text: "Name" 
                            width: units.gu(10)
                            height: units.gu(3)
                            // height: isDesktop() ? 25 : phoneLarg()?50:80
                            font.pixelSize: units.gu(2)
                            }
                            Label { text: "Planned Start Date"
                            width: units.gu(10)
                            height: units.gu(3)
                            // height: isDesktop() ? 25 : phoneLarg()?50:80
                            font.pixelSize: units.gu(2)
                            }
                            Label { text: "Planned End Date " 
                            width: units.gu(10)
                            height: units.gu(3)
                            // height: isDesktop() ? 25 : phoneLarg()?50:80
                            font.pixelSize: units.gu(2)
                            }
                            Label { text: "Instance" 
                            width: units.gu(10)
                            height: units.gu(3)
                            visible: workpersonaSwitchState
                            // height: isDesktop() ? 25 : phoneLarg()?50:80
                            font.pixelSize: units.gu(2)
                            }
                            Label { text: "Parent Project" 
                            width: units.gu(10)
                            height: units.gu(3)
                            // height: isDesktop() ? 25 : phoneLarg()?50:80
                            font.pixelSize: units.gu(2)
                            }
                            Label { text: "Allocated Hours" 
                            width: units.gu(10)
                            height: units.gu(3)
                            // height: isDesktop() ? 25 : phoneLarg()?50:80
                            font.pixelSize: units.gu(2)
                            }
                            
                            Label { text: "Description" 
                            width: units.gu(10)
                            height: units.gu(3)
                            // height: descriptionProject.height
                            font.pixelSize: units.gu(2)
                            }

                            Label { text: "Favorites" 
                                width: units.gu(10)
                                height: units.gu(3)
                                // height: isDesktop() ? 25 : phoneLarg()?50:80
                                font.pixelSize: units.gu(2)
                            }
                            Label { text: "Color Pallet" 
                                width: units.gu(10)
                                height: units.gu(3)
                                // height: isDesktop() ? 25 : phoneLarg()?50:80
                                font.pixelSize: units.gu(2)
                            }
                        }
                        Column {
                            spacing: 10
                            
                            Rectangle {
                                width: units.gu(20)
                                height: units.gu(3)
                                color: "transparent"

                                Rectangle {
                                    height: 1
                                    width: parent.width
                                    color: "black"
                                    anchors.bottom: parent.bottom
                                }

                                TextInput {
                                    id: nameInput
                                    font.pixelSize: units.gu(2)
                                    anchors.fill: parent
                                    readOnly: workpersonaSwitchState

                                    Text {
                                        id: namePlaceholder
                                        text: "Name"
                                        font.pixelSize: units.gu(2)
                                        color: "#aaa"
                                        anchors.fill: parent
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    onTextChanged: {
                                        namePlaceholder.visible = nameInput.text.length === 0;
                                    }
                                }
                            }
                            Rectangle {
                                width: units.gu(20)
                                height: units.gu(3)
                                color: "transparent"

                                Rectangle {
                                    height: 1
                                    width:  parent.width
                                    color: "black"
                                    anchors.bottom: parent.bottom
                                }
                                TextInput {
                                    font.pixelSize: units.gu(2)
                                    anchors.fill: parent
                                    id: startDateInput
                                    readOnly: workpersonaSwitchState
                                    Text {
                                        id: startDateplaceholder
                                        text: "Date"
                                        font.pixelSize: units.gu(2)
                                        color: "#aaa"
                                        anchors.fill: parent
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    Dialog {
                                        id: startDateDialog
                                        width: units.gu(10)
                                        height: units.gu(10)
                                        padding: 0
                                        margins: 0
                                        visible: false

                                        DatePicker {
                                            id: datePickerstartDate
                                            onClicked: {
                                                startDateInput.text = Qt.formatDate(date, 'M/d/yyyy').toString()
                                            }
                                        }
                                    }
                                    MouseArea {
                                        visible: !workpersonaSwitchState
                                        anchors.fill: parent
                                        onClicked: {
                                            var now = new Date()
                                            datePickerstartDate.selectedDate = now
                                            datePickerstartDate.currentIndex = now.getMonth()
                                            datePickerstartDate.selectedYear = now.getFullYear()
                                            startDateDialog.visible = true
                                        }
                                    }

                                    onTextChanged: {
                                        if (startDateInput.text.length > 0) {
                                            startDateplaceholder.visible = false
                                        } else {
                                            startDateplaceholder.visible = true
                                        }
                                    }
                                    function formatDate(date) {
                                        var month = date.getMonth() + 1; 
                                        var day = date.getDate();
                                        var year = date.getFullYear();
                                        return month + '/' + day + '/' + year;
                                    }

                                    
                                    Component.onCompleted: {
                                        var currentDate = new Date();
                                        startDateInput.text = formatDate(currentDate);
                                    }

                                }
                            }
                            Rectangle {
                                width: units.gu(20)
                                height: units.gu(3)
                                color: "transparent"

                                Rectangle {
                                    height: 1
                                    width:  parent.width
                                    color: "black"
                                    anchors.bottom: parent.bottom
                                }
                                TextInput {
                                    width: parent.width
                                    height: parent.height
                                    anchors.fill: parent
                                    readOnly: workpersonaSwitchState
                                    id: endDateInput
                                    Text {
                                        id: endDateplaceholder
                                        text: "Date"
                                        color: "#aaa"
                                        anchors.fill: parent
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    Dialog {
                                        id: endDateDialog
                                        padding: 0
                                        margins: 0
                                        visible: false

                                        DatePicker {
                                            id: datePickerendDate
                                            onClicked: {
                                                endDateInput.text = Qt.formatDate(date, 'M/d/yyyy').toString()
                                            }
                                        }
                                    }
                                    MouseArea {
                                        visible: !workpersonaSwitchState
                                        anchors.fill: parent
                                        onClicked: {
                                            var now = new Date()
                                            datePickerendDate.selectedDate = now
                                            datePickerendDate.currentIndex = now.getMonth()
                                            datePickerendDate.selectedYear = now.getFullYear()
                                            endDateDialog.visible = true
                                        }
                                    }
                                    onTextChanged: {
                                        if (endDateInput.text.length > 0) {
                                            endDateplaceholder.visible = false
                                        } else {
                                            endDateplaceholder.visible = true
                                        }
                                    }
                                    function formatDate(date) {
                                        var month = date.getMonth() + 1; 
                                        var day = date.getDate();
                                        var year = date.getFullYear();
                                        return month + '/' + day + '/' + year;
                                    }

                                    
                                    Component.onCompleted: {
                                        var currentDate = new Date();
                                        endDateInput.text = formatDate(currentDate);
                                    }

                                }
                            }
                            Rectangle {
                                width: units.gu(20)
                                height: units.gu(3)
                                color: "transparent"
                                visible: workpersonaSwitchState

                                Rectangle {
                                    height: 1
                                    width:  parent.width
                                    color: "black"
                                    anchors.bottom: parent.bottom
                                }

                                ListModel {
                                    id: accountList
                                }

                                TextInput {
                                    width: parent.width
                                    height: parent.height
                                    anchors.fill: parent
                                    
                                    id: accountInput
                                    Text {
                                        id: accountplaceholder
                                        text: "Instance"
                                        color: "#aaa"
                                        anchors.fill: parent
                                        verticalAlignment: Text.AlignVCenter
                                        
                                    }

                                    MouseArea {
                                        anchors.fill: parent                                                        
                                    }

                                    Menu {
                                        id: menuAccount
                                        x: accountInput.x
                                        y: accountInput.y + accountInput.height
                                        width: accountInput.width  

                                        Repeater {
                                            model: accountList

                                            MenuItem {
                                                width: parent.width
                                                height: units.gu(5)
                                                property int accountId: model.id  
                                                property string accuntName: model.name || ''
                                                Text {
                                                    text: accuntName
                                                    // font.pixelSize: isDesktop() ? 18 : 40
                                                    bottomPadding: 5
                                                    topPadding: 5
                                                    color: "#000"
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    anchors.left: parent.left
                                                    anchors.leftMargin: 10
                                                    wrapMode: Text.WordWrap
                                                    elide: Text.ElideRight   
                                                    maximumLineCount: 2      
                                                }

                                                onClicked: {
                                                    accountInput.text = accuntName
                                                    selectedAccountUserId = accountId
                                                    
                                                }
                                            }
                                        }
                                    }

                                    onTextChanged: {
                                        if (accountInput.text.length > 0) {
                                            accountplaceholder.visible = false
                                        } else {
                                            accountplaceholder.visible = true
                                        }
                                    }
                                }
                            }
                            Rectangle {
                                width: units.gu(20)
                                height: units.gu(3)
                                color: "transparent"

                                Rectangle {
                                    height: 1
                                    width:  parent.width
                                    color: "black"
                                    anchors.bottom: parent.bottom
                                }

                                ListModel {
                                    id: parentProject
                                }

                                TextInput {
                                    width: parent.width
                                    height: parent.height
                                    anchors.fill: parent
                                    readOnly: workpersonaSwitchState
                                    id: parentProjectInput
                                    Text {
                                        id: parentProjectplaceholder
                                        text: "Parent Project"
                                        color: "#aaa"
                                        anchors.fill: parent
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        visible: !workpersonaSwitchState
                                        onClicked: {
                                            parentProject.clear();
                                            var result = Model.fetch_projects(false, workpersonaSwitchState);
                                            for (var i = 0; i < result.length; i++) {
                                                if (projectFlickable.edit_id != result[i].id) {
                                                    parentProject.append({'id': result[i].id, 'name': result[i].name});
                                                }
                                            }
                                            parentProjectmenu.open();
                                        }
                                    }

                                    Menu {
                                        id: parentProjectmenu
                                        x: parentProjectInput.x
                                        y: parentProjectInput.y + parentProjectInput.height
                                        width: parentProjectInput.width
                                        Repeater {
                                            model: parentProject

                                            MenuItem {
                                                width: parent.width
                                                property int parentProjectId: model.id  
                                                property string parentProjectName: model.name || ''
                                                Text {
                                                    text: parentProjectName
                                                    bottomPadding: 5
                                                    topPadding: 5
                                                    color: "#000"
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    anchors.left: parent.left
                                                    anchors.leftMargin: 10
                                                    wrapMode: Text.WordWrap
                                                    elide: Text.ElideRight
                                                    maximumLineCount: 2
                                                }

                                                onClicked: {
                                                    parentProjectInput.text = parentProjectName
                                                    selectedparentProjectId = parentProjectId
                                                    parentProjectmenu.close()
                                                }
                                            }
                                        }
                                    }

                                    onTextChanged: {
                                        if (parentProjectInput.text.length > 0) {
                                            parentProjectplaceholder.visible = false
                                        } else {
                                            parentProjectplaceholder.visible = true
                                        }
                                    }
                                }
                            }
                            Rectangle {
                                width: units.gu(20)
                                height: units.gu(3)
                                color: "transparent"

                                Rectangle {
                                    height: 1
                                    width:  parent.width
                                    color: "black"
                                    anchors.bottom: parent.bottom
                                }
                                TextInput {
                                    width: parent.width
                                    height: parent.height
                                    anchors.fill: parent
                                    readOnly: workpersonaSwitchState
                                    
                                    id: allocatedhoursInput
                                    
                                    Text {
                                        id: allocatedhoursInputPlaceholder
                                        text: "00:00"
                                        color: "#aaa"
                                        anchors.fill: parent
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    onTextChanged: {
                                        if (allocatedhoursInput.text.length > 0) {
                                            allocatedhoursInputPlaceholder.visible = false
                                        } else {
                                            allocatedhoursInputPlaceholder.visible = true
                                        }
                                    }
                                }
                            }
                            Rectangle {
                                width: units.gu(20)
                                height: units.gu(3)
                                color: "transparent"

                                Rectangle {
                                    height: 1
                                    width:  parent.width
                                    color: "black"
                                    anchors.bottom: parent.bottom
                                }
                                TextInput {
                                    width: parent.width
                                    height: parent.height
                                    anchors.fill: parent
                                    readOnly: workpersonaSwitchState
                                    
                                    id: descriptionProject
                                    
                                    Text {
                                        id: descriptionProjectPlaceholder
                                        text: "Description"
                                        color: "#aaa"
                                        anchors.fill: parent
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    onTextChanged: {
                                        if (descriptionProject.text.length > 0) {
                                            descriptionProjectPlaceholder.visible = false
                                        } else {
                                            descriptionProjectPlaceholder.visible = true
                                        }
                                    }
                                }
                            }
                            Row {
                                width: units.gu(10)
                                height: units.gu(3)
                                id: img_star
                                property int selectedPriority: 0

                                Repeater {
                                    model: 1  
                                    delegate: Item {
                                        width: units.gu(2)
                                        height: units.gu(2)
                                        Image {
                                            id: starImage
                                            source: (index < img_star.selectedPriority) ? "images/star-active.svg" : "images/starinactive.svg"
                                            width: units.gu(2)
                                            height: units.gu(2)
                                            smooth: true  
                                        }
                                        MouseArea {
                                            visible: !workpersonaSwitchState
                                            anchors.fill: parent
                                            onClicked: {
                                                
                                                if (index + 1 === img_star.selectedPriority) {
                                                    img_star.selectedPriority = 0;  
                                                } else {
                                                    img_star.selectedPriority = index + 1;  
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            Rectangle {
                                width: units.gu(20)
                                height: units.gu(3)
                                color: "transparent"

                                Rectangle {
                                    height: 5
                                    width:  parent.width
                                    color: "black"
                                    anchors.topMargin: units.gu(3)
                                    anchors.bottom: parent.bottom
                                }

                                TextInput {
                                    width: parent.width
                                    anchors.fill: parent
                                    
                                    id: colorInput
                                    Item {
                                        id: buttonHeaderAreaSelected
                                        anchors {
                                            left: parent.left
                                            right: parent.right
                                        }
                                        height: parent.height
                                        clip: true

                                        Rectangle {
                                            anchors {
                                                fill: parent
                                                bottomMargin: -10
                                            }
                                            radius: 10
                                            color: selectedColor
                                        }
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            console.log('\n\n colorListModel', colorListModel)
                                            colorListModel.clear();
                                            for (var i = 0; i < color_indexes.length; i++) {
                                                colorListModel.append({'name': color_indexes[i]})
                                            }
                                            menuColor.open();
                                        }
                                    }

                                    ListModel {
                                        id: colorListModel
                                    }

                                    Menu {
                                        id: menuColor
                                        x: colorInput.x
                                        y: colorInput.y + colorInput.height
                                        width: colorInput.width

                                        Repeater {
                                            model: colorListModel

                                            MenuItem {
                                                width: parent.width
                                                // height: isDesktop() ? 40 : 80

                                                property string sColor: model.name;

                                                Item {
                                                    id: buttonHeaderArea
                                                    anchors {
                                                        top: parent.top
                                                        left: parent.left
                                                        right: parent.right
                                                    }
                                                    height: parent.height
                                                    clip: true

                                                    Rectangle{
                                                        anchors{
                                                            fill: parent
                                                            bottomMargin: -10
                                                        }
                                                        radius: 10
                                                        color: sColor
                                                    }
                                                }

                                                onClicked: {
                                                    selectedColor = model.name;
                                                    menuColor.close();
                                                }
                                            }
                                        }
                                    }

                                    onTextChanged: {
                                        if (colorInput.text.length > 0) {
                                            colorplaceholder.visible = false
                                        } else {
                                            colorplaceholder.visible = true
                                        }
                                    }
                                }
                            }
                            Rectangle {
                                width: parent.width
                                height: 50
                                anchors.left: parent.left
                                anchors.topMargin: 20
                                color: "#FFF"

                                Text {
                                    id: timesheedSavedMessage
                                    text: isProjectEdit ? "Project is Edit successfully!" : "Project could not be Edit!"
                                    color: isProjectEdit ? "green" : "red"
                                    visible: isEditProjectClicked
                                    // font.pixelSize: isDesktop() ? 18 : 40
                                    horizontalAlignment: Text.AlignHCenter 
                                    anchors.centerIn: parent

                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        fetch_projects_list();
        console.log('\n\n 1111111111111111111111')
        // issearchHeader = false
    }

}