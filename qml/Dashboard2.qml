import QtQuick 2.7
import Lomiri.Components 1.3
import QtCharts 2.0
import "../models/Main.js" as Model
import "../models/DbInit.js" as DbInit
import "../models/DemoData.js" as DemoData




Page{
    id: dashboard
    title: "Project"
        header: PageHeader {
        title: dashboard.title
    }



    LomiriShape {
        id: rect1
        anchors.centerIn: parent
        width: parent.width
        height: units.gu(40)

                ChartView {
                    id: chart3
                    title: "Projectwise Time Spent"
                    anchors.fill: parent
                    theme: ChartView.ChartThemeHighContrast
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
                    property variant project: []



                Component.onCompleted: {
                    var quadrant_data = Model.get_projects_spent_hours();
                    var count = 0;
                    var timeval;
                    var timecat = [];
                    for (var key in quadrant_data) {
                        project[count] = key;
                        timeval = quadrant_data[key];
                        count = count+1;
                    }
                    var count2 = Object.keys(quadrant_data).length;
                    for (count = 0; count < count2; count++)
                        {
                            timecat[count] = quadrant_data[project[count]];
                            console.log("Dashboard2 Timecat: " + timecat[count]);
                    }
                    mySeries.append("Time", timecat);
                    mySeries.axisX.categories =  project;

                }
            }

     }




}