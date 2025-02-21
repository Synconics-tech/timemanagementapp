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


Page{
    id: sync_page
    title: "Sync"
        header: PageHeader {
        title: sync_page.title
    }

    function queryData() {
        var db = LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);

        db.transaction(function(tx) {
            var result = tx.executeSql('SELECT * FROM users');
            var accountsList = [];
            console.log('\n\n result', result.rows.length)
            for (var i = 0; i < result.rows.length; i++) {
                accountsList.push({'user_id': result.rows.item(i).id, 'name': result.rows.item(i).name, 'link': result.rows.item(i).link, 'database': result.rows.item(i).database, 'username': result.rows.item(i).username})
            }
            console.log('\n\n accountsList', JSON.stringify(accountsList))
            accountsListModel.clear();
            for (var i = 0; i < accountsList.length; i++) {
                accountsListModel.append(accountsList[i]);
            }
        });
    }

    ListModel {
        id: accountsListModel
    }

    Rectangle {
        width: parent.width
        anchors.top: header.bottom
        Flickable {
            id: projectFlickable
            anchors.fill: parent
            // anchors.top: header.bottom
            contentHeight: column.height
            // clip: true 
            width: parent.width
            property string edit_id: ""
            Column {
                id: column
                width: parent.width
                spacing: 0
                
                Repeater {
                    id: projectListView
                    model: accountsListModel
                    delegate: Column {
                        width: parent.width
                        Rectangle {
                            id: menRow
                            width: parent.width
                            height: units.gu(10)
                            border.color: "#CCCCCC"
                            border.width: 2

                            Row {
                                width: parent.width
                                height: units.gu(5)
                                spacing: 0  

                                Column {
                                    width: parent.width - (units.gu(5))  
                                    spacing: 0

                                    Row {
                                        width: parent.width
                                        height: units.gu(5)
                                        spacing: units.gu(5) 

                                        Row {
                                            spacing: 10
                                            anchors.left: parent.left
                                            // anchors.leftMargin: units.gu(5)
                                            anchors.verticalCenter: parent.verticalCenter
                                            width: parent.width * 0.4
                                            id: left_row

                                            Text {
                                                text: modelData.name
                                                
                                                font.pixelSize: units.gu(1)
                                                color: "#000000"
                                                anchors.verticalCenter: parent.verticalCenter
                                                width: parent.width * 0.8  
                                                elide: Text.ElideRight
                                            }
                                        }

                                    }
                                    ToolButton {
                                        id: sync_button
                                        width: units.gu(5)
                                        height: units.gu(5)
                                        anchors.top: parent.top
                                        anchors.topMargin: 1
                                        background: Rectangle {
                                            color: "transparent"  
                                        }
                                        contentItem: Ubuntu.Icon {
                                            name: "sync"
                                        }
                                        // onClicked: {
                                        //     onClicked:{
                                        //         dataId.shown = !dataId.shown
                                        //     }
                                        // }
                                    }
                                }
                            }

                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        queryData();
    }

}