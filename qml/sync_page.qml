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
import QtQuick.Window 2.2
import QtQuick.LocalStorage 2.7
import Ubuntu.Components 1.3 as Ubuntu
import io.thp.pyotherside 1.4
import "../models/sync.js" as SyncData


Page{
    id: sync_page
    title: "Sync"
        header: PageHeader {
        title: sync_page.title
    }

    property bool loading: false;
    // property bool issearchHeader: false
    property string loadingMessage: "";
    property bool isPasswordVisible: false;

    function queryData() {
        var accountsList = SyncData.get_accounts_list();
        // console.log('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>.', JSON.stringify(accountsList))
        for (var account = 0; account < accountsList.length; account++) {
            // console.log('>>>>>>>>>>>>>>>> accountsList[account]', JSON.stringify(accountsList[account]))
            // accountsListModel.append(accountsList[account]);
            console.log('\n\n >>>>>>>>>>>>>>>>>>>>', accountsList[account].api_key, accountsList[account].connect_with)
            var api_key = '';
            if (accountsList[account].connect_with == 1) {
                api_key = accountsList[account].api_key;
            }
            accountsListModel.append({'user_id': accountsList[account].user_id,
                                     'name': accountsList[account].name,
                                     'link': accountsList[account].link,
                                     'database': accountsList[account].database,
                                     'username': accountsList[account].username,
                                     'connect_with': accountsList[account].connect_with,
                                     'api_key': api_key,})
        }
    }

    Python {
        id: python

        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('../src/'));
            importModule_sync("backend");
        }

        onError: {
        }
    }

    ListModel {
        id: accountsListModel
    }

    Rectangle {
        width: parent.width
        height: parent.height
        anchors.top: parent.top
        anchors.topMargin: units.gu(3)
        anchors.left: parent.left
        anchors.leftMargin: units.gu(3)
        anchors.right: parent.right
        anchors.rightMargin: units.gu(1)
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        color: "#ffffff"

        
        Rectangle {
            // spacing: 0
            anchors.fill: parent
            // anchors.top: searchId.bottom  
            anchors.topMargin: units.gu(2)
            border.color: "#CCCCCC"
            border.width: 1

            Flickable {
                id: listView
                anchors.fill: parent
                width: parent.width
                contentHeight: column.height
                clip: true


                Column {
                    id: column
                    width: parent.width
                    spacing: 0

                    Repeater {
                        model: accountsListModel
                        delegate: Rectangle {
                            width:  parent.width
                            height: units.gu(10)
                            color: "#FFFFFF"
                            border.color: "#CCCCCC"
                            border.width: 1
                           
                            Column {
                                spacing: 0
                                anchors.fill: parent 

                                Row {
                                    width: parent.width
                                    height: units.gu(10)
                                    spacing: 20 
                                    
                                    Rectangle {
                                        id: imgmodulename
                                        width: units.gu(4)
                                        height: units.gu(4)
                                        color: "#0078d4"
                                        radius: 80
                                        border.color: "#0056a0"
                                        border.width: 2
                                        // anchors.rightMargin: 10
                                        
                                        anchors.verticalCenter:  parent.verticalCenter 
                                        anchors.left: parent.left 
                                        // anchors.leftMargin:  10

                                        
                                        Text {
                                            text: model.name.charAt(0).toUpperCase()
                                            color: "#fff"
                                            anchors.centerIn: parent
                                        }
                                    }

                                    Column {
                                        spacing: 5 
                                        // width: parent.width - 280
                                        anchors.centerIn:  parent

                                        Text {
                                            text: model.name
                                            // font.pixelSize: isDesktop() ? 20 : 40
                                            color: "#000"
                                            elide: Text.ElideRight
                                        }

                                        Text {
                                            text: (model.link.length > 40) ? model.link.substring(0, 40) + "..." : model.link
                                            // font.pixelSize: isDesktop() ? 18 : 30
                                            color: "#0078d4"
                                            elide: Text.ElideNone
                                        }
                                    }

                                    Button {
                                        width:units.gu(2)
                                        height:units.gu(2)
                                        // width: isDesktop() ? 40 : 90
                                        // height: isDesktop() ? 40 : 90

                                        // background: Rectangle {
                                        //     color: "transparent"
                                        //     radius: 10
                                        //     border.color: "transparent"
                                        // }
                                        Image {
                                            source: "images/reload.png"
                                            anchors.fill: parent
                                            smooth: true
                                        }
                                        anchors.right:  parent.right
                                        anchors.rightMargin:  20
                                        anchors.verticalCenter: parent.verticalCenter
                                        onClicked: {
                                            if (model.connect_with == 1) {
                                                loading = true;
                                                var failed_sync = false;
                                                loadingMessage = 'Synchronization for ' + model.name + '!' 
                                                var filled_password = model.api_key
                                                var last_user_update = SyncData.getLastModified(model.user_id)
                                                python.call("backend.fetch_projects", [model.link, model.username, filled_password, {'isTextInputVisible': true, 'input_text': model.database}, last_user_update] , function(projects) {
                                                    if (projects === undefined) {
                                                        loading = false;
                                                        failed_sync = true;
                                                        return
                                                    }
                                                    SyncData.create_projects(projects, model.user_id);
                                                    python.call("backend.fetch_contacts", [model.link, model.username, filled_password, {'isTextInputVisible': true, 'input_text': model.database}, last_user_update] , function(contacts) {
                                                        SyncData.create_contacts(contacts, model.user_id)
                                                        var fetchedAllTasks = SyncData.get_all_tasks(model.user_id, last_user_update)
                                                        python.call('backend.create_update_tasks', [model.link, model.username, filled_password, {'isTextInputVisible': true, 'input_text': model.database}, fetchedAllTasks, last_user_update], function (obj_data) {
                                                            SyncData.set_tasks(obj_data.settled_tasks, model.user_id);
                                                            SyncData.create_tasks(obj_data.updated_tasks, model.user_id);
                                                            var timesheets = SyncData.fetchTimesheets(model.user_id)
                                                            python.call("backend.create_timesheets", [model.link, model.username, filled_password, {'isTextInputVisible': true, 'input_text': model.database}, timesheets], function (res) {
                                                                SyncData.update_timesheet_entries(res, model.user_id)
                                                            })
                                                            python.call('backend.fetch_activity_type', [model.link, model.username, filled_password, {'isTextInputVisible': true, 'input_text': model.database}, last_user_update], function(activity_types) {
                                                                SyncData.create_activity_types(activity_types, model.user_id)
                                                                var fetchedallActivities = SyncData.fetchAllActivities(model.user_id)
                                                                python.call('backend.fetch_activities', [model.link, model.username, filled_password, {'isTextInputVisible': true, 'input_text': model.database}, last_user_update, fetchedallActivities], function(activities_dict) {
                                                                    if (activities_dict === undefined) {
                                                                        loading = false;
                                                                        return
                                                                    }
                                                                    SyncData.create_activities(activities_dict.activities_list, model.user_id);
                                                                    SyncData.done_activities(activities_dict.done_activities, model.user_id);
                                                                    loading = false;
                                                                    SyncData.update_instance_date(model.user_id)
                                                                })
                                                            })
                                                            var activities = SyncData.fetchActivities(model.user_id)
                                                            python.call("backend.create_activities", [model.link, model.username, filled_password, {'isTextInputVisible': true, 'input_text': model.database}, activities], function (res) {
                                                                SyncData.update_activity_entries(res)
                                                            })
                                                        })
                                                        passwordInput.text = ""
                                                        passwordDialog.close();
                                                    })
                                                })
                                            } else {
                                                passwordDialog.open()
                                            }
                                        }
                                    }
                                    Dialog {
                                        id: passwordDialog
                                        title: "Enter Password"
                                        x: (parent.width - width) / 2
                                        y: 150
                                        standardButtons: Dialog.Ok | Dialog.Cancel
                                        
                                        contentItem: Column {
                                            spacing: 10
                                            padding: 20

                                            Row {
                                                spacing: 5

                                                TextField {
                                                    id: passwordInput
                                                    placeholderText: "Password"
                                                    echoMode: isPasswordVisible ? TextInput.Normal : TextInput.Password
                                                }

                                                Button {
                                                    height: passwordInput.height
                                                    width:passwordInput.height
                                                    Image {
                                                        source: isPasswordVisible ? "images/show.png" : "images/hide.png"
                                                        anchors.fill: parent
                                                        smooth: true
                                                    }
                                                    onClicked: {
                                                        isPasswordVisible = !isPasswordVisible
                                                    }
                                                }
                                            }
                                        }

                                        onAccepted: {
                                            loading = true;
                                            var failed_sync = false;
                                            loadingMessage = 'Synchronization for ' + model.name + '!' 
                                            var filled_password = passwordInput.text
                                            var last_user_update = SyncData.getLastModified(model.user_id)
                                            python.call("backend.fetch_projects", [model.link, model.username, filled_password, {'isTextInputVisible': true, 'input_text': model.database}, last_user_update] , function(projects) {
                                                if (projects === undefined) {
                                                    loading = false;
                                                    failed_sync = true;
                                                    return
                                                }
                                                SyncData.create_projects(projects, model.user_id);
                                                python.call("backend.fetch_contacts", [model.link, model.username, filled_password, {'isTextInputVisible': true, 'input_text': model.database}, last_user_update] , function(contacts) {
                                                    SyncData.create_contacts(contacts, model.user_id)
                                                    var fetchedAllTasks = SyncData.get_all_tasks(model.user_id, last_user_update)
                                                    python.call('backend.create_update_tasks', [model.link, model.username, filled_password, {'isTextInputVisible': true, 'input_text': model.database}, fetchedAllTasks, last_user_update], function (obj_data) {
                                                        SyncData.set_tasks(obj_data.settled_tasks, model.user_id);
                                                        SyncData.create_tasks(obj_data.updated_tasks, model.user_id);
                                                        var timesheets = SyncData.fetchTimesheets(model.user_id)
                                                        python.call("backend.create_timesheets", [model.link, model.username, filled_password, {'isTextInputVisible': true, 'input_text': model.database}, timesheets], function (res) {
                                                            SyncData.update_timesheet_entries(res, model.user_id)
                                                        })
                                                        python.call('backend.fetch_activity_type', [model.link, model.username, filled_password, {'isTextInputVisible': true, 'input_text': model.database}, last_user_update], function(activity_types) {
                                                            SyncData.create_activity_types(activity_types, model.user_id)
                                                            var fetchedallActivities = SyncData.fetchAllActivities(model.user_id)
                                                            python.call('backend.fetch_activities', [model.link, model.username, filled_password, {'isTextInputVisible': true, 'input_text': model.database}, last_user_update, fetchedallActivities], function(activities_dict) {
                                                                if (activities_dict === undefined) {
                                                                    loading = false;
                                                                    return
                                                                }
                                                                SyncData.create_activities(activities_dict.activities_list, model.user_id);
                                                                SyncData.done_activities(activities_dict.done_activities, model.user_id);
                                                                loading = false;
                                                                SyncData.update_instance_date(model.user_id)
                                                            })
                                                        })
                                                        var activities = SyncData.fetchActivities(model.user_id)
                                                        python.call("backend.create_activities", [model.link, model.username, filled_password, {'isTextInputVisible': true, 'input_text': model.database}, activities], function (res) {
                                                            SyncData.update_activity_entries(res)
                                                        })
                                                    })
                                                    passwordInput.text = ""
                                                    passwordDialog.close();
                                                })
                                            })
                                        }
                                        onRejected: {
                                            console.log("Dialog cancelled")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            Item {
                id: loader
                visible: loading
                width: parent.width
                height: parent.height

                Rectangle {
                    width: parent.width
                    height: parent.height
                    color: "lightgray"
                    opacity: 0.8
                    BusyIndicator {
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    Text {
                        anchors.centerIn: parent
                        text: loadingMessage
                        font.pixelSize: 50
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        queryData();
    }

}