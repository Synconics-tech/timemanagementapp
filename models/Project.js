.import QtQuick.LocalStorage 2.7 as Sql

/* Name: fetch_projects_list
* This function will return list of projects which will also contain child project lists
* -> is_work_state -> in case of work mode is enable
*/

function fetch_projects_list(is_work_state) {
    var db = Sql.LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);
    listData = [];

    db.transaction(function(tx) {
        if (is_work_state) {
            var result = tx.executeSql('SELECT * FROM project_project_app where parent_id = 0 AND account_id IS NOT NULL order by last_modified desc');
        } else {
            var result = tx.executeSql('SELECT * FROM project_project_app where parent_id = 0 AND account_id IS NULL');
        }
        for (var project = 0; project < result.rows.length; project++) {
            var task_total = tx.executeSql('SELECT id, COUNT(*) AS count FROM project_task_app WHERE account_id = ? AND project_id = ?', [result.rows.item(project).account_id, result.rows.item(project).id]);
            var plannedEndDate = result.rows.item(project).planned_end_date;
            if (typeof plannedEndDate !== 'string') {
                plannedEndDate = String(plannedEndDate);
            }

            var children_list = [];
            var child_projects = tx.executeSql('select * from project_project_app where parent_id = ?', [result.rows.item(project).id]);

            for (var child = 0; child < child_projects.rows.length; child++) {

                var childtask_total = tx.executeSql('SELECT id, COUNT(*) AS count FROM project_task_app WHERE account_id = ? AND project_id = ?', [child_projects.rows.item(child).account_id, child_projects.rows.item(child).id]);

                var parent_project = tx.executeSql('SELECT name FROM project_project_app WHERE id = ?', [child_projects.rows.item(child).parent_id]);
                var parentProject = parent_project.rows.length > 0 ? parent_project.rows.item(0).name || "" : "";
                var childplannedEndDate = child_projects.rows.item(child).planned_end_date;
                if (typeof childplannedEndDate !== 'string') {
                    childplannedEndDate = String(childplannedEndDate);
                }
                children_list.push({
                    id: child_projects.rows.item(child).id,
                    total_tasks: childtask_total.rows.item(0).count,
                    name: child_projects.rows.item(child).name,
                    favorites: child_projects.rows.item(child).favorites,
                    status: child_projects.rows.item(child).last_update_status,
                    allocated_hours: child_projects.rows.item(child).allocated_hours,
                    planned_end_date: childplannedEndDate,
                    parentProject: result.rows.item(project).name,
                    color_pallet: child_projects.rows.item(child).color_pallet
                });
            }

            listData.push({
                id: result.rows.item(project).id,
                total_tasks: task_total.rows.item(0).count,
                name: result.rows.item(project).name,
                favorites: result.rows.item(project).favorites,
                status: result.rows.item(project).last_update_status,
                allocated_hours: result.rows.item(project).allocated_hours,
                planned_end_date: plannedEndDate,
                children: children_list,
                color_pallet: result.rows.item(project).color_pallet
            });

        }
    });
    return listData;
}

/* Name: get_project_detail
* This function will return project details in form of object to fill in detail view of project
* -> project_id -> for which project details needs to be fetched
* -> is_work_state -> in case of work mode is enable
*/

function get_project_detail(project_id, is_work_state) {
    var db = Sql.LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);
    var project_detail_obj = {};
    db.transaction(function (tx) {
        if(is_work_state){
            var result = tx.executeSql('SELECT * FROM project_project_app WHERE id = ?', [project_id]);
        }else{
            var result = tx.executeSql('SELECT * FROM project_project_app where account_id IS NULL AND id = ?', [project_id] );
        }
        if (result.rows.length > 0) {
            var rowData = result.rows.item(0);
            var accountId = rowData.account_id || ""; 
            project_detail_obj['account_id'] = accountId;
            if(rowData.planned_start_date != 0) {
                var rowDate = new Date(rowData.planned_start_date || "");  
                var formattedDate = formatDate(rowDate);  
                project_detail_obj['start_date'] = formattedDate;
            }else{
                project_detail_obj['start_date'] = "mm/dd/yy";
            }
            if(rowData.planned_end_date != 0) {
                var rowDate = new Date(rowData.planned_end_date || "");  
                var formattedDate = formatDate(rowDate);
                project_detail_obj['end_date'] = formattedDate;
            }else{
                project_detail_obj['end_date'] = "mm/dd/yy";
            }

            var parent_project = tx.executeSql('SELECT name FROM project_project_app WHERE id = ?',[rowData.parent_id]);
            
            if(is_work_state){
                var account = tx.executeSql('SELECT name FROM users WHERE id = ?', [accountId]);
                project_detail_obj['account_name'] = account.rows.length > 0 ? account.rows.item(0).name || "" : "";
            }
            project_detail_obj['name'] = rowData.name;
            project_detail_obj['allocated_hours'] = rowData.allocated_hours;
            project_detail_obj['selected_color'] = rowData.color_pallet != null ? rowData.color_pallet : '#FFFFFF';
            project_detail_obj['parent_project_name'] = parent_project.rows.length > 0 ? parent_project.rows.item(0).name || "" : "";
            project_detail_obj['parent_id'] = rowData.parent_id;
            project_detail_obj['favorites'] = rowData.favorites || 0;
            project_detail_obj['description'] = "";
            if (rowData.description != null) {
                project_detail_obj['description'] = rowData.description
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
    return project_detail_obj;
}
