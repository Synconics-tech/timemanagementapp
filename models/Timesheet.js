.import QtQuick.LocalStorage 2.7 as Sql

/* Name: get_accounts_list
* This function will return accounts which are linked to Odoo
*/

function get_accounts_list() {
    var db = Sql.LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);
    var accountlist = [];
    db.transaction(function(tx) {
        var accounts = tx.executeSql('SELECT * FROM users');
        for (var account = 0; account < accounts.rows.length; account++) {
            accountlist.push({'id': accounts.rows.item(account).id,
                             'name': accounts.rows.item(account).name});
        }
    });
    return accountlist;
}

/* Name: fetch_projects
* This function will return projects based on Odoo account and work state
* instance_id -> id of users table
* is_work_state -> in case of work mode is enable
*/

function fetch_projects(instance_id, is_work_state) {
    var db = Sql.LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);
    var projectList = [];
    db.transaction(function(tx) {
        if (is_work_state) {
            var projects = tx.executeSql('SELECT * FROM project_project_app\
             WHERE account_id = ? AND parent_id IS 0', [instance_id]);
        } else {
            var projects = tx.executeSql('SELECT * FROM project_project_app\
             WHERE account_id IS NULL');
        }
        for (var project = 0; project < projects.rows.length; project++) {
            var child_projects = tx.executeSql('SELECT count(*) as count FROM project_project_app\
             where parent_id = ?', [projects.rows.item(project).id]);
            projectList.push({'id': projects.rows.item(project).id,
                             'name': projects.rows.item(project).name,
                             'projectHasSubProject': true ? child_projects.rows.item(0).count > 0 : false});
        }
    });
    return projectList;
}

/* Name: fetch_sub_project
* This function will return sub projects based on given project's id
* project_id -> id from project_project_app table
* is_work_state -> in case of work mode is enable
*/

function fetch_sub_project(project_id, is_work_state) {
    var db = Sql.LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);
    var subProjectsList = [];
    db.transaction(function(tx) {
        if (is_work_state) {
            var sub_projects = tx.executeSql('SELECT * FROM project_project_app\
                                where parent_id = ?', [project_id]);
        } else {
            var sub_projects = tx.executeSql('SELECT * FROM project_project_app\
                                where account_id IS NULL AND parent_id = ?', [project_id]);
        }
        for (var sub_project = 0; sub_project < sub_projects.rows.length; sub_project++) {
            subProjectsList.push({'id': sub_projects.rows.item(sub_project).id,
                                 'name': sub_projects.rows.item(sub_project).name});
        }
    });
    return subProjectsList;
}

/* Name: fetch_tasks_list
* This function will return tasks list
* project_id -> id from project_project_app table
* sub_project_id -> id from project_project_app table
* is_work_state -> in case of work mode is enable
*/

function fetch_tasks_list(project_id, sub_project_id, is_work_state) {
    var db = Sql.LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);
    var tasks_list = [];
    db.transaction(function(tx) {
        if (is_work_state) {
            var tasks = tx.executeSql('SELECT * FROM project_task_app\
                                 where project_id = ? AND account_id != 0 AND sub_project_id = ?',
                                [project_id, sub_project_id != 0 ? sub_project_id : null]);
            if (sub_project_id == 0) {
                tasks = tx.executeSql('SELECT * FROM project_task_app\
                                     where project_id = ? AND account_id != 0',
                                    [project_id]);
            }
        } else {
            var tasks = tx.executeSql('SELECT * FROM project_task_app\
                                     where account_id is NULL \
                                     AND project_id = ? \
                                     ',
                                     [project_id]);
        }
        for (var task = 0; task < tasks.rows.length; task++) {
            var child_tasks = tx.executeSql('SELECT count(*) as count FROM project_task_app\
                                             where parent_id = ?',
                                             [tasks.rows.item(task).id]);
            tasks_list.push({'id': tasks.rows.item(task).id,
                         'name': tasks.rows.item(task).name,
                         'taskHasSubTask': true ? child_tasks.rows.item(0).count > 0 : false,
                         'parent_id':tasks.rows.item(task).parent_id});
        }
    });
    return tasks_list;
}

/* Name: fetch_sub_tasks
* This function will return sub tasks list based on given id of the task
* task_id -> id of project_task_app table
* is_work_state -> in case of work mode is enable
*/

function fetch_sub_tasks(task_id, is_work_state) {
    var db = Sql.LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);
    var sub_tasks_list = [];
    db.transaction(function(tx) {
        if (is_work_state) {
            var sub_tasks = tx.executeSql('SELECT * FROM project_task_app\
                                         where parent_id = ?', [task_id]);
            console.log('\n\n fetch_sub_tasks >>>>>>>>>>>>>>>>>', task_id)
        } else {
            var sub_tasks = tx.executeSql('SELECT * FROM project_task_app\
                                         where account_id IS NULL AND parent_id = ?',
                                         [task_id]);
        }
        for (var sub_task = 0; sub_task < sub_tasks.rows.length; sub_task++) {
            sub_tasks_list.push({'id': sub_tasks.rows.item(sub_task).id,
                             'name': sub_tasks.rows.item(sub_task).name});
        }
    });
    return sub_tasks_list;
}

/* Name: convert_time
* This function will return formatted time HH:MM
* value -> string
*/

function convert_time(value) {
    var vals = value.split(':');
    var hours = parseInt(vals[0], 10);
    var minutes = parseInt(vals[1], 10);
    hours += Math.floor(minutes / 60);
    minutes = minutes % 60;
    return hours.toString().padStart(2, '0') + ':' + minutes.toString().padStart(2, '0');
}

/* Name: create_timesheet
* This function will create timesheet based on passed data
* data -> object of details related to timesheet entry
*/

function create_timesheet(data) {
    console.log("In create_timesheet");
    var db = Sql.LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);
    db.transaction(function(tx) {
        var unitAmount = 0;
        if (data.isManualTimeRecord) {
            unitAmount = convert_time(data.manualSpentHours);
        } else {
            unitAmount = convert_time(data.spenthours);
        }
        tx.executeSql('INSERT INTO account_analytic_line_app \
            (account_id, record_date, project_id, task_id, name, sub_project_id, sub_task_id, quadrant_id,  \
            unit_amount, last_modified) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
             [data.instance_id, data.dateTime, data.project, data.task, data.description, data.subprojectId,
              data.subTask, data.quadrant, unitAmount, new Date().toISOString()]);
    });
}
