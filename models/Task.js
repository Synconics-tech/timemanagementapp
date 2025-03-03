.import QtQuick.LocalStorage 2.7 as Sql

/* Name: update_task
* This function will update details in task
* data -> object of columns and updated values
*/

function update_task(data){
    var db = Sql.LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);
    db.transaction(function (tx) {
        tx.executeSql('UPDATE project_task_app SET \
            account_id = ?, name = ?, project_id = ?, parent_id = ?, initial_planned_hours = ?, favorites = ?, description = ?, user_id = ?, sub_project_id = ?, \
            start_date = ?, end_date = ?, deadline = ?, last_modified = ? WHERE id = ?',
            [data.selectedAccountUserId, data.nameInput, data.selectedProjectId,data.selectedparentId, data.initialInput,data.img_star,data.editdescription, data.selectedassigneesUserId, data.editselectedSubProjectId,
            data.startdateInput, data.enddateInput, data.deadlineInput, new Date().toISOString(), data.rowId]  
        );
        tx.executeSql('commit');
    });
}

function fetch_tasks_lists(is_work_state) {
    var db = Sql.LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);
    tasks_list = [];
    db.transaction(function (tx) {
        if(is_work_state) {
            var tasks = tx.executeSql('SELECT * FROM project_task_app where account_id != 0 order by last_modified desc');
        }else{
            var tasks = tx.executeSql('SELECT * FROM project_task_app where account_id = 0');
        }
        for (var task = 0; task < tasks.rows.length; task++) {
            var parent_task = tx.executeSql('SELECT name FROM project_task_app WHERE id = ?',[tasks.rows.item(task).parent_id]);
            var parentTask = parent_task.rows.length > 0 ? parent_task.rows.item(0).name || "" : "";

            var accunt_id = tx.executeSql('SELECT name FROM users WHERE id = ?',[tasks.rows.item(task).account_id]);
            var accountName = accunt_id.rows.length > 0 ? accunt_id.rows.item(0).name || "" : "";

            var id = tasks.rows.item(task).id
            var timesheetEntries = tx.executeSql('SELECT unit_amount FROM account_analytic_line_app WHERE task_id = ?', [id]);

            var color_pallet = ''
            if (tasks.rows.item(task).sub_project_id != 0) {
                var project_color = tx.executeSql('select color_pallet from project_project_app where id = ?', [tasks.rows.item(task).sub_project_id])
                if (project_color.rows.length) {
                    color_pallet = project_color.rows.item(0).color_pallet;
                }
            } else {
                var project_color = tx.executeSql('select color_pallet from project_project_app where id = ?', [tasks.rows.item(task).project_id])
                if (project_color.rows.length) {
                    color_pallet = project_color.rows.item(0).color_pallet;
                }
            }

            var totalMinutes = 0;
            for (var timesheet = 0; timesheet < timesheetEntries.rows.length; timesheet++) {
                var timeString = timesheetEntries.rows.item(timesheet).unit_amount || "00:00";
                var parts = timeString.split(":");
                var hours = parseInt(parts[0], 10) || 0;
                var minutes = parseInt(parts[1], 10) || 0;

                totalMinutes += hours * 60 + minutes;  
            }

            var totalHours = Math.floor(totalMinutes / 60);
            var remainingMinutes = totalMinutes % 60;
            var spentHours =  totalHours + ":" + (remainingMinutes < 10 ? "0" : "") + remainingMinutes;

            tasks_list.push({'id': tasks.rows.item(task).id,
                            'name': tasks.rows.item(task).name,
                            'allocated_hours': tasks.rows.item(task).initial_planned_hours,
                            'state': tasks.rows.item(task).state,
                            'parentTask': parentTask,
                            'accountName':accountName,
                            'favorites':tasks.rows.item(task).favorites,
                            'spentHours':spentHours,
                            'timerRunning': false})
        }
    });
    return tasks_list;
}

function fetch_current_users_task(selectedAccountUserId) {
    var db = Sql.LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);
    var assignees_list = [];
    db.transaction(function (tx) {
        var instance_users = tx.executeSql('select * from res_users_app where account_id = ? AND share = ? AND active = ?', [selectedAccountUserId, 0, 1])
        for (var instance_user = 0; instance_user < instance_users.rows.length; instance_user++) {
            assignees_list.push({'id': instance_users.rows.item(instance_user).id,
                                'name': instance_users.rows.item(instance_user).name});
        }
    });
    return assignees_list;
}


function loadtaskData(task_id, is_work_state) {
    var db = Sql.LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);

    var task_detail_obj = {};
    db.transaction(function (tx) {
        if(is_work_state){
            var task = tx.executeSql('SELECT * FROM project_task_app WHERE id = ?', [task_id]);
        }else{
            var task = tx.executeSql('SELECT * FROM project_task_app where account_id = 0 AND id = ?', [task_id] );
        }
        if (task.rows.length > 0) {
            var task_data = task.rows.item(0);

            var projectId = task_data.project_id || "";  
            var parentId = task_data.parent_id != null ? task_data.parent_id || "":"";
            var sub_pro_Id = task_data.sub_project_id != null ? task_data.sub_project_id || "":"";
            var accountId = task_data.account_id || ""; 
            var userId = task_data.user_id || ""; 
            
            if(sub_pro_Id != 0) {
                // hasSubProject = true
                task_detail_obj['hasSubProject'] = true;
                var sub_project = tx.executeSql('SELECT name FROM project_project_app WHERE id = ?', [sub_pro_Id]);
                task_detail_obj['sub_project_name'] = sub_project.rows.length > 0 ? sub_project.rows.item(0).name || "" : "";
                // subProjectInput.text = sub_project.rows.length > 0 ? sub_project.rows.item(0).name || "" : "";
                // editselectedSubProjectId = sub_pro_Id
                task_detail_obj['sub_project_id'] = sub_pro_Id
            }else{
                task_detail_obj['sub_project_name'] = "";
                task_detail_obj['sub_project_id'] = false;
                // hasSubProject = false
                task_detail_obj['hasSubProject'] = false;
            }

            if(task_data.start_date != 0 && task_data.start_date != "mm/dd/yy") {
                var rowDate = new Date(task_data.start_date || "");  
                var formattedDate = formatDate(rowDate);  
                // startdateInput.text = formattedDate;
                task_detail_obj['start_date'] = formattedDate;
            }else{
                // startdateInput.text = "mm/dd/yy"
                task_detail_obj['start_date'] = "mm/dd/yy";
            }
            if(task_data.end_date != 0 && task_data.end_date != "mm/dd/yy") {
                var rowDate = new Date(task_data.end_date || "");  
                var formattedDate = formatDate(rowDate);  
                // enddateInput.text = formattedDate;
                task_detail_obj['end_date'] = formatDate(rowDate);
            }else{
                // enddateInput.text = "mm/dd/yy"
                task_detail_obj['end_date'] = "mm/dd/yy";
            }
            if (task_data.deadline != 0 && task_data.deadline != "mm/dd/yy") {
                var rowDate = new Date(task_data.deadline || "");  
                var formattedDate = formatDate(rowDate);  
                // deadlineInput.text = formattedDate;
                var currentDate = new Date();                    
                currentDate.setHours(0, 0, 0, 0);                
                rowDate.setHours(0, 0, 0, 0);                    

                var timeDiff = rowDate - currentDate;
                var dayLefts = Math.ceil(timeDiff / (1000 * 60 * 60 * 24));  
                // dayLeft = dayLefts
                task_detail_obj['deadline'] = formattedDate;
                task_detail_obj['days_left'] = dayLefts;
            } else {
                // deadlineInput.text = "mm/dd/yy"
                // dayLeft = ""
                task_detail_obj['deadline'] = "mm/dd/yy";
                task_detail_obj['days_left'] = "";
            }

            var project = tx.executeSql('SELECT name FROM project_project_app WHERE id = ?', [projectId]);
            var parentname = tx.executeSql('SELECT name FROM project_task_app WHERE id = ?', [parentId]);
            if (is_work_state) {
                var account = tx.executeSql('SELECT name FROM users WHERE id = ?', [accountId]);
                var user = tx.executeSql('SELECT name FROM res_users_app WHERE id = ?', [userId]);
            }
            
            // projectInput.text = project.rows.length > 0 ? project.rows.item(0).name || "" : "";
            task_detail_obj['project_name'] = project.rows.length > 0 ? project.rows.item(0).name || "" : "";
            // selectedProjectId = projectId;
            task_detail_obj['project_id'] = projectId;

            if(is_work_state){
                // accountInput.text = account.rows.length > 0 ? account.rows.item(0).name || "" : "";
                task_detail_obj['account_name'] = account.rows.length > 0 ? account.rows.item(0).name || "" : "";
                // selectedAccountUserId = accountId;
                task_detail_obj['account_id'] = accountId;

                // assigneesInput.text = user.rows.length > 0 ? user.rows.item(0).name || "" : "";
                task_detail_obj['assignee_name'] = user.rows.length > 0 ? user.rows.item(0).name || "" : "";
                // selectedassigneesUserId = userId;
                task_detail_obj['assignee_id'] = userId;
            }
            task_detail_obj['name'] = task_data.name;
            // nameInput.text = task_data.name
            parentInput.text = parentname.rows.length > 0 ? parentname.rows.item(0).name || "" : "";
            task_detail_obj['parent_name'] = parentname.rows.length > 0 ? parentname.rows.item(0).name || "" : "";
            // selectedparentId = parentId
            task_detail_obj['parent_id'] = parentId;
            // img_star.selectedPriority = task_data.favorites || 0; 
            task_detail_obj['favorites'] = task_data.favorites || 0;
            // initialInput.text = task_data.initial_planned_hours || 0;
            task_detail_obj['planned_hours'] = task_data.initial_planned_hours || 0;
            task_detail_obj['description'] = "";
            if (task_data.description != null) {
                task_detail_obj['description'] = task_data.description
                    .replace(/<[^>]+>/g, " ")
                    .replace(/&nbsp;/g, "")
                    .replace(/&lt;/g, "<")
                    .replace(/&gt;/g, ">")
                    .replace(/&amp;/g, "&")
                    .replace(/&quot;/g, "\"")
                    .replace(/&#39;/g, "'")
                    .trim() || "";
            }
        }
    });
    function formatDate(date) {
        var month = date.getMonth() + 1; 
        var day = date.getDate();
        var year = date.getFullYear();
        return month + '/' + day + '/' + year;
    }
    return task_detail_obj;
}
