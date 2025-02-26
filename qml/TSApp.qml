import QtQuick 2.6
import QtQuick.Controls 2.2
import Lomiri.Components 1.3
import QtQuick.Window 2.2
import QtQuick.Layouts 1.11

ApplicationWindow {

    id: mainView
    
    // objectName: "TS"  
    // applicationName: "timemanagementapp.synconics"

//    width: Screen.desktopAvailableWidth < units.gu(130) ? units.gu(40) : units.gu(130)
    width: units.gu(45) //GM: for testing with only one column
    height: units.gu(89)
  
    

    AdaptivePageLayout {
        id: apLayout
        anchors.fill: parent
        property bool isMultiColumn: true
        primaryPage: page1
        layouts: [
            PageColumnsLayout {
                when: width > units.gu(80) && width < units.gu(130)
                // column #0
                PageColumn {
                    minimumWidth: units.gu(45)
                    maximumWidth: units.gu(50)
                    preferredWidth: width > units.gu(90) ? units.gu(45) : units.gu(40)
                }
                // column #1
                PageColumn {
                    minimumWidth: units.gu(45)
                    maximumWidth: units.gu(50)
                    preferredWidth: width > units.gu(90) ? units.gu(45) : units.gu(40)
                }
                 // column #2
                PageColumn {
                    fillWidth: true
                }
            },
            PageColumnsLayout {
                when: width >= units.gu(130) 
                // column #0
                PageColumn {
                    minimumWidth: units.gu(45)
                    maximumWidth: units.gu(50)
                    preferredWidth: units.gu(50)
                }
                // column #1
                PageColumn {
                    minimumWidth: units.gu(45)
                    maximumWidth: units.gu(50)
                    preferredWidth: units.gu(50)
                }
                // column #2
                PageColumn {
                    fillWidth: true
                }
            }
        ]
 
        Dashboard{
            id:page1
        }
        Dashboard2{
            id:page2
        }        
        Dashboard3{
            id:page4
        }




        onColumnsChanged: {
           console.log(" column changed " + columns);
           if (columns > 1 ){
            addPageToNextColumn(page1, page2);
            addPageToNextColumn(page2, page4);
           }
            else
            {
              removePages(page2)
              removePages(page4)

            }
        }
        Component.onCompleted: {
           console.log("From OnComplete " + columns);
           if (apLayout.columns > 1){
                apLayout.addPageToNextColumn(page1, page2);
                apLayout.addPageToNextColumn(page2, page4);
            }
        }
    }
}