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
import "../models/sync.js" as SyncData


Page{
    id: settings
    title: "Settings"
    header: PageHeader {
        id: pageHeader
        title: settings.title
        trailingActionBar.actions: [
            Action {
                iconName: "add"
                onTriggered: {
                    apLayout.addPageToNextColumn(settings, Qt.resolvedUrl('create_account_page.qml'))
                }
            }
        ]
    }

    property bool loading: false
    property string loadingMessage: ""

    ListModel {
        id: accountListModel
    }

    function fetch_accounts() {
        var accountsList = SyncData.get_accounts_list();
        for (var account = 0; account < accountsList.length; account++) {
            accountListModel.append(accountsList[account])
        }
    }

    Rectangle {
        width: parent.width
        height: parent.height
        anchors.top: parent.top
        anchors.topMargin: units.gu(1)
        anchors.left: parent.left
        anchors.leftMargin: units.gu(1)
        anchors.right: parent.right
        anchors.rightMargin: units.gu(1)
        anchors.bottom: parent.bottom
        anchors.bottomMargin: units.gu(1)
        color: "#ffffff"
        Rectangle {
            anchors.fill: parent
            anchors.top: pageHeader.bottom
            anchors.topMargin: units.gu(5)
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
                        model: accountListModel
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
                                    spacing: units.gu(1)
                                    
                                    Rectangle {
                                        id: imgmodulename
                                        width: units.gu(5)
                                        height: units.gu(5)
                                        color: "#0078d4"
                                        radius: 80
                                        border.color: "#0056a0"
                                        border.width: 1
                                        anchors.rightMargin: units.gu(1)
                                        anchors.verticalCenter:  parent.verticalCenter 
                                        anchors.left: parent.left 
                                        anchors.leftMargin:  units.gu(1) 

                                        Text {
                                            text: model.name.charAt(0).toUpperCase() 
                                            anchors.verticalCenter:  parent.verticalCenter 
                                            color: "#fff"
                                            anchors.centerIn: parent
                                            font.pixelSize: units.gu(2)
                                        }
                                    }
                                    
                                    Column {
                                        spacing: 5 
                                        anchors.centerIn:  parent  

                                        Text {
                                            text: model.name
                                            font.pixelSize: units.gu(2)
                                            color: "#000"
                                            elide: Text.ElideRight
                                        }

                                        Text {
                                            text: (model.link.length > 40) ? model.link.substring(0, 40) + "..." : model.link
                                            font.pixelSize: units.gu(2)
                                            color: "#0078d4"
                                            elide: Text.ElideNone  
                                        }
                                    }

                                    Button {
                                        
                                        width: units.gu(5)
                                        height: units.gu(5)
                                        color: "#fff"
                                        iconName: "delete"
                                        anchors.right:  parent.right  
                                        anchors.rightMargin: units.gu(1)
                                        anchors.verticalCenter: parent.verticalCenter
                                        onClicked: {
                                            
                                            // logInPage(model.user_id)
                                            
                                            SyncData.deleteAccount(model.user_id)
                                            accountListModel.remove(index)
                                            // recordModel.remove(index)
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

                Rectangle {
                    width: Screen.width
                    height: Screen.height
                    color: "lightgray"
                    radius: 10
                    opacity: 0.8
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
        fetch_accounts()
    }

}