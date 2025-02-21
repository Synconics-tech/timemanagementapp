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
import Lomiri.Components 1.3
import QtCharts 2.0
//import QtQuick.Controls 2.2
import QtQuick.Layouts 1.11
import Qt.labs.settings 1.0
import "../models/Main.js" as Model
import "../models/DbInit.js" as DbInit
import "../models/DemoData.js" as DemoData



    Page {
        id: mainPage
        title: "Timesheet"
        anchors.fill: parent

        header: PageHeader {
            id: header
            title: "Dashboard"
            ActionBar {
                numberOfSlots: 1
                anchors.right: parent.right
            //    enable: true
                actions: [
                    Action {
                        iconName: "home"
                        text: "Home"
                    },
                    Action {
                        iconName: "clock"
                        text: "Timesheet"
                        onTriggered:{
                            apLayout.addPageToCurrentColumn(mainPage, Qt.resolvedUrl("Timesheet.qml"))
                            apLayout.removePages(page4)

                        }
                    },
                    Action {
                        iconName: "calendar"
                        text: "Activities"
                        onTriggered:{
                            apLayout.addPageToCurrentColumn(mainPage, Qt.resolvedUrl("Activity_Page.qml"))
                        }
                    },
                    Action {
                        iconName: "view-list-symbolic"
                        text: "Tasks"
                        onTriggered:{
                            apLayout.addPageToCurrentColumn(mainPage, Qt.resolvedUrl("Task_Page.qml"))
                        }
                    },
                    Action {
                        iconName: "folder-symbolic"
                        text: "Projects"
                        onTriggered:{
                            apLayout.addPageToCurrentColumn(mainPage, Qt.resolvedUrl("Project_Page.qml"))
                        }
                    },
                    Action {
                        iconName: "sync"
                        text: "Sync"
                        onTriggered:{
                            apLayout.addPageToNextColumn(mainPage, Qt.resolvedUrl("sync_page.qml"))
                        }
                    },
                    Action {
                        iconName: "settings"
                        text: "Settings"
                        onTriggered:{
                            apLayout.addPageToCurrentColumn(mainPage, Qt.resolvedUrl("Settings_Page.qml"))
                        }
                    }
                ]
            }       
         }

        Flickable {
            id:flick1
            width: parent.width; height: parent.height
            anchors.horizontalCenter: parent.horizontalCenter
            contentWidth: parent.width; contentHeight: 3500

            rebound: Transition {
                NumberAnimation {
                    properties: "x,y"
                    duration: 1000
                    easing.type: Easing.OutBounce
                }
            }

            LomiriShape {
            id: rect1
            anchors.top: header.bottom
            width: parent.width
            height: units.gu(40)
            sourceFillMode: LomiriShape.PreserveAspectFit 

                ChartView {
                    id: chart
                    z: 100
                    title: "Time Spent this week"
                    margins { top: 50; bottom: 0; left: 0; right: 0 }
                    backgroundRoundness: 0
                    anchors { fill: parent; margins: 0; top: header.bottom }
                    antialiasing: true
                    legend.visible: false
        
                    property variant othersSlice: 0
                    property variant timecat: []


                    PieSeries {
                        id: pieSeries
                        size: 0.7
                        PieSlice { label: "Important, Urgent"; value: chart.timecat[0] } //  Data from Js
                        PieSlice { label: "Important, Not Urgent"; value: chart.timecat[1] }
                        PieSlice { label: "Not Important, Urgent"; value: chart.timecat[2]}
                        PieSlice { label: "Not Important, Not Urgent"; value: chart.timecat[3]}
                    }
                    Component.onCompleted: {
                        // You can also manipulate slices dynamically, like append a slice or set a slice exploded
                        //othersSlice = pieSeries.append("Others", 42.0);
                        //Any animation or labels to be added here
                        DbInit.initializeDatabase();
                        var quadrant_data = Model.get_quadrant_difference();
                        console.log('\n\n quadrant_data', quadrant_data)
                        chart.timecat = quadrant_data;

                        pieSeries.find("Important, Urgent").exploded = true;
                    }
                }

            }
    /****************
    * Chart 2 comes below
    *****************/

        LomiriShape {
            id: rect2
            anchors.top: rect1.bottom
            width: parent.width
            height: units.gu(40)

                ChartView {
                    id: chart2
                    z: 100
                    title: "Time Spent this month"
    //                            x: -10
    //                            y: -10
                    margins { top: 50; bottom: 0; left: 0; right: 0 }
                    backgroundRoundness: 0
                    anchors { fill: parent; margins: 0; top: header.bottom }
                    antialiasing: true
                    legend.visible: false
        
                    property variant othersSlice: 0
                    property variant timecat: []


                    PieSeries {
                        id: pieSeries2
                        size: 0.7
                        PieSlice { label: "Important, Urgent"; value: chart.timecat[0] } //  Data from Js
                        PieSlice { label: "Important, Not Urgent"; value: chart.timecat[1] }
                        PieSlice { label: "Not Important, Urgent"; value: chart.timecat[2]}
                        PieSlice { label: "Not Important, Not Urgent"; value: chart.timecat[3]}
                    }
                    Component.onCompleted: {
                        var quadrant_data = Model.get_quadrant_current_month();
                        console.log('\n\n quadrant_data', quadrant_data)
                        chart.timecat = quadrant_data;
                    }




                }

        }

    /********************************
    * The manually added Legend box *
    ********************************/

        LomiriShape {
            id: rect3
            anchors.top: rect2.bottom
            width: parent.width
            height: units.gu(10)

                Column{
                        id: myCol1
                        spacing: 2
                        leftPadding: 10
                        Row{
                                spacing: 2
                                Rectangle { color: "lightskyblue" 
                                            width: 20 
                                            height: 20 
                                }
                                Text {
                                        id: myLabel_1
                                        text: qsTr("Important, Urgent")
                                    }
                            }
                        Row{
                                spacing: 2
                                Rectangle { color: "deepskyblue"
                                            width: 20 
                                            height: 20 
                                }
                                Text {
                                        id: myLabel_2
                                        text: qsTr("Important, Not Urgent")
                                    }
                        }       

                }
            Column{
                    id: myCol2
                    anchors.left: myCol1.right
                    spacing: 2
                    leftPadding: 10
                    Row{
                            spacing: 2
                            Rectangle { color: "steelblue" 
                                        width: 20 
                                        height: 20 
                            }
                            Text {
                                    id: myLabel_3
                                    text: qsTr("Not Important, Urgent")
                                }
                    }       
                    Row{
                            spacing: 2
                            Rectangle { color: "#0e1a24" 
                                        width: 20 
                                        height: 20 
                            }
                            Text {
                                    id: myLabel_4
                                    text: qsTr("Not Important, Not Urgent")
                                }
                    }       

            }

        }   
/**************************
* Projectwise graph       *
**************************/
        LomiriShape {
            id: rect4
            anchors.top: rect3.bottom
            width: parent.width
            height: units.gu(40)

                ChartView {
                    id: chart3
                    title: "Projectwise Time Spent"
                    anchors.fill: parent
                    legend.alignment: Qt.AlignBottom
                    antialiasing: true

                    BarSeries {
                        id: mySeries
                        axisY: ValueAxis {
                                min: 0
                                max: 50
                                tickCount: 5
                             }
                    }
        
                    property variant othersSlice: 0
                    property variant timecat: []
                    property variant project: []



                Component.onCompleted: {
                    var quadrant_data = Model.get_projects_spent_hours();
                    chart.timecat = quadrant_data;
                    var count = 0;
                    var timeval;
                    for (var key in quadrant_data) {
                        project[count] = key;
                        timeval = quadrant_data[key];
                        count = count+1;
                    }
                    var count2 = Object.keys(quadrant_data).length;
                    for (count = 0; count < count2; count++)
                        {
                            timecat[count] = quadrant_data[project[count]];
                            console.log("Timecat: " + timecat[count]);
                    }
                    mySeries.append("Time", timecat);
                    mySeries.axisX.categories =  project;

                }
            }

        }

/************************/


/**************************
* Taskwise graph          *
**************************/
    LomiriShape {
        id: rect5
        anchors.top: rect4.bottom
        width: parent.width
        height: units.gu(40)

            ChartView {
                id: chart4
                title: "Taskwise Time Spent"
                anchors.fill: parent
                theme: ChartView.ChartThemeHighContrast
                legend.alignment: Qt.AlignBottom
                antialiasing: true

                BarSeries {
                    id: mySeries2
                    axisY: ValueAxis {
                            min: 0
                            max: 50
                            tickCount: 5
                            }
                }

    
                property variant othersSlice: 0
                property variant timecat: []
                property variant task: []



                Component.onCompleted: {
                    var quadrant_data = Model.get_tasks_spent_hours();
                    chart.timecat = quadrant_data;
                    var count = 0;
                    var timeval;
                     for (var key in quadrant_data) {
                        task[count] = key;
                        timeval = quadrant_data[key];
                        count = count+1;
                    }
                    var count2 = Object.keys(quadrant_data).length;
                    for (count = 0; count < count2; count++)
                        {
                            timecat[count] = quadrant_data[task[count]];
                    }
                    mySeries2.append("Time", timecat);
                    mySeries2.axisX.categories =  task;
                }

                }

        }



/************************/

    }
/* Splash Screen. We cann add text as well with App name */

            Rectangle{
                id: splashrect
                anchors.fill: parent
                width: units.gu(45)
                height: units.gu(75)
                color: "#ffffff"
                border.color: "black"
                border.width: 1
                Image {
                    id: image
                    anchors.centerIn: parent
                    width: units.gu(45)
                    height: units.gu(40)
                    source: "time_management_logo_4_3.jpg"
                }
                Timer {
                    interval: 2000; running: true; repeat: false
                    onTriggered: {
                        splashrect.visible = false
    //                    window.timeout()
                    }
                }

            }
/***************************************/

        Scrollbar {
            flickableItem: flick1
            align: Qt.AlignTrailing
        }
    }
