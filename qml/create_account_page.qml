import QtQuick 2.7
import QtQuick.Controls 2.2
import Lomiri.Components 1.3
import QtQuick.Window 2.2
import io.thp.pyotherside 1.4
import "../models/sync.js" as SyncData

Page {
	id: createAccountPage
	// id: settings
    title: "Create Account"

    header: PageHeader {
        id: pageHeader
        title: createAccountPage.title
        trailingActionBar.actions: [
            Action {
                iconName: "document-save"
                onTriggered: {
                    if (!accountNameInput.text) {
                        isValidAccount = false;
                    } else {
                        isValidAccount = true;
                        isValidLogin = true;
                        python.call("backend.login_odoo", [linkInput.text, usernameInput.text, passwordInput.text, {'input_text': dbInput.text || single_db, 'selected_db': database_combo.currentText, 'isTextInputVisible': isTextInputVisible, 'isTextMenuVisible': isTextMenuVisible}], function (result) {
                            if (result && result['result'] == 'pass') {
                                let apikey = ""
                                if(selectedconnectwithId == 1){
                                    apikey = passwordInput.text
                                }
                                var isDuplicate = SyncData.createAccount(accountNameInput.text, linkInput.text, result['database'], usernameInput.text,selectedconnectwithId,apikey)
                                if (isDuplicate) {
                                    alreadyExistAccount = true;
                                }
                                else {
                                    isValidLogin = true;
                                    alreadyExistAccount = false;
                                }
                            }
                            else {
                                isValidLogin = false;
                                alreadyExistAccount = false;
                            }
                        })
                    }
                }
            }
        ]
    }

    property bool isTextInputVisible: false
    property bool isTextMenuVisible: false
    property bool isValidUrl: true
    property bool isValidLogin: true
    property bool isValidAccount: true
    property bool isPasswordVisible: false
    property int selectedconnectwithId: 1
    property bool alreadyExistAccount: false
    property string single_db: ""

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
        id: databaseListModel
    }

    ListModel {
        id: menuconnectwithModel
        ListElement { modelData: "Connect With Api Key"; itemid:0  }
        ListElement { modelData: "Connect With Password"; itemid:1 }
    }
    Flickable {
        id: projectFlickable
        anchors.fill: parent
        contentHeight: signup_shape.height + 1500
        flickableDirection: Flickable.VerticalFlick
        anchors.top: pageHeader.bottom
        anchors.topMargin: pageHeader.height
        width: parent.width
        LomiriShape {
            id: signup_shape
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            radius: "large"
            width: parent.width
            height: parent.height

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                id: accountRow
                anchors.topMargin: 5
                Column {
                    Rectangle {
                        width: units.gu(40)
                        height: units.gu(3)
                        Label {
                            id: account_name_label
                            text: "Account Name"
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                    Rectangle {
                        width: units.gu(40)
                        anchors.horizontalCenter: parent.horizontalCenter
                        height: units.gu(5)
                        TextField {
                            id: accountNameInput
                            anchors.horizontalCenter: parent.horizontalCenter
                            placeholderText: "Account Name"
                            width: parent.width
                        }
                    }
                }
            }

            Row {
                id: linkRow
                anchors.top: accountRow.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.topMargin: 5
                Column {
                    height: units.gu(10)
                    Rectangle {
                        width: units.gu(40)
                        // anchors.left: parent.left
                        // anchors.horizontalCenter: parent.horizontalCenter
                        height: units.gu(3)
                        Label {
                            id: link_label
                            text: "Link"
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            //textSize: Label.Large
                        }
                    }
                    Rectangle {
                        width: units.gu(40)
                        height: units.gu(5)
                        
                        TextField {
                            id: linkInput
                            placeholderText: "Link"
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: parent.width
                            height: parent.height

                            onTextChanged: {
                                text = text.toLowerCase();
                            }

                            onAccepted: {
                                text = text.toLowerCase();
                                if (isValidURL(linkInput.text)) {
                                    isValidUrl = true;
                                    python.call("backend.fetch_databases", [linkInput.text], function(result) {
                                        isTextInputVisible = result.text_field
                                        isTextMenuVisible = result.menu_items
                                        if (isTextMenuVisible) {
                                            // optionList = result.menu_items
                                            for (var db = 0; db < result.menu_items.length; db++) {
                                                databaseListModel.append({'name': result.menu_items[db]})
                                            }
                                        } else if (result.single_db) {
                                            single_db = result.single_db;
                                        }
                                    });
                                } else {
                                    isValidUrl = false;
                                }
                            }

                            // Function to validate URL
                            function isValidURL(url) {
                                var pattern = new RegExp('^(https?:\\/\\/)?' + 
                                    '(([a-zA-Z0-9\\-\\.]+)\\.([a-zA-Z]{2,4})|' + 
                                    '(\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3})|' + 
                                    '\\[([a-fA-F0-9:\\.]+)\\])' + 
                                    '(\\:\\d+)?(\\/[-a-zA-Z0-9@:%_\\+.~#?&//=]*)*$', 'i');
                                return pattern.test(url);
                            }
                        }
                    }
                    Text {
                        id: errorMessage
                        text: isValidUrl ? "" : "Please enter a valid URL"
                        color: "red"
                        visible: !isValidUrl
                    }


                }
            }

            Row {
                id: databaseRow
                anchors.top: linkRow.bottom
                anchors.topMargin: 5
                anchors.horizontalCenter: parent.horizontalCenter
                Column {
                    visible: isTextInputVisible
                    Rectangle {
                        width: units.gu(40)
                        height: units.gu(3)
                        Label {
                            id: database_name_label
                            text: "Database"
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                    Rectangle {
                        width: units.gu(40)
                        // anchors.left: parent.left
                        // anchors.horizontalCenter: parent.horizontalCenter
                        height: units.gu(5)
                        TextField {
                            id: dbInput
                            placeholderText: "Database"
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: parent.width
                        }
                    }
                }

                Column {
                    visible: isTextMenuVisible
                    Rectangle {
                        width: units.gu(40)
                        height: units.gu(3)
                        Label {
                            id: database_list_label
                            text: "Database"
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                    Rectangle {
                        width: units.gu(40)
                        // anchors.left: parent.left
                        // anchors.horizontalCenter: parent.horizontalCenter
                        height: units.gu(5)
                        ComboBox {
                            id: database_combo
                            // editable: true
                            width: parent.width
                            height: parent.height
                            anchors.centerIn: parent.centerIn
                            flat: true
                            model:  databaseListModel

                            onActivated: {
                                console.log("In onActivated")
                            }        
                            onHighlighted: {
                            }
                            onAccepted: {
                                console.log("In onAccepted")
                                if (find(editText) != -1)
                                {
                                    // set_project_id(editText) 
                                    // prepare_task_list(selectedProjectId)
                                    // console.log("Project ID: " + selectedProjectId)
                                }
                            } 

                        }
                    }
                }
            }

            Row {
                id: usernameRow
                anchors.top: databaseRow.bottom
                anchors.topMargin: 5
                anchors.horizontalCenter: parent.horizontalCenter
                Column {
                    Rectangle {
                        width: units.gu(40)
                        // anchors.left: parent.left
                        // anchors.horizontalCenter: parent.horizontalCenter
                        height: units.gu(3)
                         Label {
                            id: username_label
                            text: "Username"
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            //textSize: Label.Large
                        }
                    }
                    Rectangle {
                        width: units.gu(40)
                        // anchors.left: parent.left
                        // anchors.horizontalCenter: parent.horizontalCenter
                        height: units.gu(5)
                        TextField {
                            id: usernameInput
                            placeholderText: "Username"
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: parent.width
                        }
                    }
                }
            }

            Row {
                id: connectWithRow
                anchors.top: usernameRow.bottom
                anchors.topMargin: 5
                anchors.horizontalCenter: parent.horizontalCenter
                Column {
                    Rectangle {
                        width: units.gu(40)
                        height: units.gu(3)
                         Label {
                            id: connectwith_label
                            text: "Connect With"
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            //textSize: Label.Large
                        }
                    }
                    Rectangle {
                        width: units.gu(40)
                        height: units.gu(5)
                        ComboBox {
                            id: connectWith_combo
                            width: parent.width
                            height: parent.height
                            anchors.centerIn: parent.centerIn
                            flat: true
                            model: menuconnectwithModel

                            onActivated: {
                                console.log("In onActivated")
                            }
                            onHighlighted: {
                                // console.log("In onHighlighted")
                                console.log("Combobox height: " + combo1.height)
                            }
                            onAccepted: {
                                console.log("In onAccepted")
                                if (find(editText) != -1)
                                {
                                    if (connectWith_combo.currentIndex == 0) {
                                        selectedconnectwithId = 1
                                    } else {
                                        selectedconnectwithId = 0
                                    }
                                }
                            } 

                        }
                    }
                }
            }

            Row {
                id: passwordRow
                anchors.top: connectWithRow.bottom
                anchors.topMargin: 5
                anchors.horizontalCenter: parent.horizontalCenter
                Column {
                    Rectangle {
                        width: units.gu(40)
                        // anchors.left: parent.left
                        // anchors.horizontalCenter: parent.horizontalCenter
                        height: units.gu(3)
                        Label {
                            id: password_label
                            text: connectWith_combo.currentIndex == 1 ? "Password" : "API Key"
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            //textSize: Label.Large
                        }
                    }
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 5
                        Rectangle {
                            width: units.gu(35)
                            height: units.gu(5)
                            TextField {
                                id: passwordInput
                                echoMode: isPasswordVisible ? TextInput.Normal : TextInput.Password
                                placeholderText: connectWith_combo.currentIndex == 1 ? "Password" : "API Key"
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: parent.width
                            }
                        }
                        Button {
                            width: units.gu(5)
                            height: passwordInput.height
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
            }

            Text {
                id: errorMessageAccount
                text: isValidAccount ? "" : "Please enter Account Name to save!"
                color: "red"
                anchors.top: passwordRow.bottom
                anchors.topMargin: 10
                visible: !isValidAccount
            }

            Text {
                id: errorMessageLogin
                text: isValidLogin ? "" : "Please enter valid Credentials!"
                color: "red"
                visible: !isValidLogin
                anchors.top: passwordRow.bottom
                anchors.topMargin: 10
            }

            Text {
                id: errorMessageDuplicate
                text: !alreadyExistAccount ? "" : "Account Already exist!"
                color: "red"
                anchors.top: passwordRow.bottom
                anchors.topMargin: 10
                visible: alreadyExistAccount
            }

            Label {
                text: selectedconnectwithId == 1 ? "Notes:<br/>Connect with API Key: Your API key will be securely stored on your device, enabling synchronization without requiring a password.<br/><br/>In Odoo, you can generate your API key in the <b>My Profile</b> page under the <b>Account Security</b> tab." : "Notes:<br/>Connect with Password: You will be prompted to enter your password each time synchronization is performed."
                textFormat: Text.RichText
                anchors.left: parent.left
                anchors.top: errorMessageDuplicate.bottom
                anchors.topMargin: 10
                anchors.right: parent.right
                horizontalAlignment: Label.AlignHCenter
                verticalAlignment: Label.AlignVCenter
                wrapMode: Label.Wrap
            }
        }
    }
}
