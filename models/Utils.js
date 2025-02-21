function initializeDatabase() {
    var db = LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);

    db.transaction(function(tx) {
        
        tx.executeSql('CREATE TABLE IF NOT EXISTS users (\
            id INTEGER PRIMARY KEY AUTOINCREMENT,\
            name TEXT NOT NULL,\
            link TEXT NOT NULL,\
            last_modified datetime,\
            database TEXT NOT NULL,\
            connectwith_id INTEGER,\
            api_key TEXT,\
            username TEXT NOT NULL\
        )');

    });
}

function insertData(name, link, database, username, selectedconnectwithId, apikey) {
    var db = LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);

    db.transaction(function(tx) {
        var result = tx.executeSql('SELECT id, COUNT(*) AS count FROM users WHERE link = ? AND database = ? AND username = ?', [link, database, username]);
        if (result.rows.item(0).count === 0) {
            var api_key_text = ' ';
            if (selectedconnectwithId == 1) {
                api_key_text = apikey;
            }
            tx.executeSql('INSERT INTO users (name, link, database, username, connectwith_id, api_key) VALUES (?, ?, ?, ?, ?, ?)', [name, link, database, username, selectedconnectwithId, api_key_text]);
            var newResult = tx.executeSql('SELECT id FROM users WHERE link = ? AND database = ? AND username = ?', [link, database, username]);
            currentUserId = newResult.rows.item(0).id;
        } else {
            currentUserId = result.rows.item(0).id;
        }
    });
}

function queryData() {
    var db = LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);

    db.transaction(function(tx) {
        var result = tx.executeSql('SELECT * FROM users');
        accountsList = [];
        for (var i = 0; i < result.rows.length; i++) {
            accountsList.push({'user_id': result.rows.item(i).id, 'name': result.rows.item(i).name, 'link': result.rows.item(i).link, 'database': result.rows.item(i).database, 'username': result.rows.item(i).username})
        }
    });
    selectedconnectwithId = 1;
    connectwith.text = 'Connect With Api Key'
}

function prepare_database() {
    var db = LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);

    db.transaction(function(tx) {
        tx.executeSql('CREATE TABLE IF NOT EXISTS users (\
            id INTEGER PRIMARY KEY AUTOINCREMENT,\
            name TEXT NOT NULL,\
            link TEXT NOT NULL,\
            last_modified datetime,\
            database TEXT NOT NULL,\
            connectwith_id INTEGER,\
            api_key TEXT,\
            username TEXT NOT NULL\
        )');
    });

    db.transaction(function(tx) {
        
        tx.executeSql('CREATE TABLE IF NOT EXISTS project_project_app (\
            id INTEGER PRIMARY KEY AUTOINCREMENT,\
            name TEXT NOT NULL,\
            account_id INTEGER,\
            parent_id INTEGER,\
            planned_start_date date,\
            planned_end_date date,\
            allocated_hours FLOAT,\
            favorites INTEGER,\
            last_update_status TEXT,\
            description TEXT,\
            last_modified datetime,\
            color_pallet TEXT,\
            odoo_record_id INTEGER,\
            FOREIGN KEY (account_id) REFERENCES users(id) ON DELETE CASCADE,\
            FOREIGN KEY (parent_id) REFERENCES project_project_app(id) ON DELETE CASCADE\
        )');
    });

    db.transaction(function(tx) {
        tx.executeSql('CREATE TABLE IF NOT EXISTS res_users_app (\
            id INTEGER PRIMARY KEY AUTOINCREMENT,\
            account_id INTEGER,\
            name Text,\
            share INTEGER,\
            active INTEGER,\
            odoo_record_id INTEGER,\
            FOREIGN KEY (account_id) REFERENCES users(id) ON DELETE CASCADE\
        )');
    });

    db.transaction(function(tx) {
        
        tx.executeSql('CREATE TABLE IF NOT EXISTS project_task_app (\
            id INTEGER PRIMARY KEY AUTOINCREMENT,\
            name TEXT NOT NULL,\
            account_id INTEGER,\
            project_id INTEGER,\
            sub_project_id INTEGER,\
            parent_id INTEGER,\
            start_date date,\
            end_date date,\
            deadline date,\
            initial_planned_hours FLOAT,\
            favorites INTEGER,\
            state TEXT,\
            description TEXT,\
            last_modified datetime,\
            user_id INTEGER,\
            odoo_record_id INTEGER,\
            FOREIGN KEY (account_id) REFERENCES users(id) ON DELETE CASCADE,\
            FOREIGN KEY (project_id) REFERENCES project_project_app(id) ON DELETE CASCADE,\
            FOREIGN KEY (sub_project_id) REFERENCES project_project_app(id) ON DELETE CASCADE,\
            FOREIGN KEY (user_id) REFERENCES res_users_app(id) ON DELETE CASCADE,\
            FOREIGN KEY (parent_id) REFERENCES project_task_app(id) ON DELETE CASCADE\
        )');
    });

    db.transaction(function(tx) {
        
        tx.executeSql('CREATE TABLE IF NOT EXISTS account_analytic_line_app (\
            id INTEGER PRIMARY KEY AUTOINCREMENT,\
            account_id INTEGER,\
            project_id INTEGER,\
            sub_project_id INTEGER,\
            task_id INTEGER,\
            sub_task_id INTEGER,\
            name TEXT,\
            unit_amount FLOAT,\
            last_modified datetime,\
            quadrant_id INTEGER,\
            record_date date,\
            odoo_record_id INTEGER,\
            FOREIGN KEY (account_id) REFERENCES users(id) ON DELETE CASCADE,\
            FOREIGN KEY (project_id) REFERENCES project_project_app(id) ON DELETE CASCADE,\
            FOREIGN KEY (task_id) REFERENCES project_task_app(id) ON DELETE CASCADE\
        )');
    });

    db.transaction(function(tx) {
        tx.executeSql('CREATE TABLE IF NOT EXISTS mail_activity_type_app (\
            id INTEGER PRIMARY KEY AUTOINCREMENT,\
            account_id INTEGER,\
            name TEXT,\
            odoo_record_id INTEGER,\
            FOREIGN KEY (account_id) REFERENCES users(id) ON DELETE CASCADE\
        )');
    });

    db.transaction(function(tx) {
        
        tx.executeSql('CREATE TABLE IF NOT EXISTS mail_activity_app (\
            id INTEGER PRIMARY KEY AUTOINCREMENT,\
            account_id INTEGER,\
            activity_type_id INTEGER,\
            summary TEXT,\
            due_date DATE,\
            user_id INTEGER,\
            notes TEXT,\
            odoo_record_id INTEGER,\
            last_modified datetime,\
            link_id INTEGER,\
            project_id INTEGER,\
            task_id INTEGER,\
            resId INTEGER,\
            resModel TEXT,\
            state TEXT,\
            FOREIGN KEY (account_id) REFERENCES users(id) ON DELETE CASCADE,\
            FOREIGN KEY (user_id) REFERENCES res_users_app(id) ON DELETE CASCADE,\
            FOREIGN KEY (activity_type_id) REFERENCES mail_activity_type_app(id) ON DELETE CASCADE\
            FOREIGN KEY (project_id) REFERENCES project_project_app(id) ON DELETE CASCADE,\
            FOREIGN KEY (task_id) REFERENCES project_task_app(id) ON DELETE CASCADE\
        )');
    });
}

function accountlistDataGet(){
    var db = LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);
    var accountlist = [];

    db.transaction(function(tx) {
            var result = tx.executeSql('SELECT * FROM users');
            for (var i = 0; i < result.rows.length; i++) {
                accountlist.push({'id': result.rows.item(i).id, 'name': result.rows.item(i).name})
            }
        })
    return accountlist

}

function fetch_projects(selectedAccountUserId) {
    var db = LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);
    var projectList = []
    db.transaction(function(tx) {
        if(workpersonaSwitchState){
            var result = tx.executeSql('SELECT * FROM project_project_app WHERE account_id = ? AND parent_id IS 0', [selectedAccountUserId]);
        }else{
            var result = tx.executeSql('SELECT * FROM project_project_app WHERE id != ? AND account_id IS NULL AND parent_id IS 0', [selectedAccountUserId]);
        }
        for (var i = 0; i < result.rows.length; i++) {
            var child_projects = tx.executeSql('SELECT count(*) as count FROM project_project_app where parent_id = ?', [result.rows.item(i).id]);
            projectList.push({'id': result.rows.item(i).id, 'name': result.rows.item(i).name, 'projectkHasSubProject': true ? child_projects.rows.item(0).count > 0 : false})
        }
    })
    return projectList;
}

function fetch_sub_project(project_id) {
    var db = LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);
    var subProjectsList = []
    db.transaction(function(tx) {
        if(workpersonaSwitchState){
            var child_projects = tx.executeSql('SELECT * FROM project_project_app where parent_id = ?', [project_id]);
        }else{
            var child_projects = tx.executeSql('SELECT * FROM project_project_app where account_id IS NULL AND parent_id = ?', [project_id]);
        }
        for (var i = 0; i < child_projects.rows.length; i++) {
            subProjectsList.push({'id': child_projects.rows.item(i).id, 'name': child_projects.rows.item(i).name})
        }
    })
    return subProjectsList;
}

function fetch_tasks_list(project_id, sub_project_id) {
    var db = LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);
    var tasks_list = []
    db.transaction(function(tx) {
        if(workpersonaSwitchState){
            var result = tx.executeSql('SELECT * FROM project_task_app where project_id = ? AND account_id != 0 AND sub_project_id = ?', [project_id, sub_project_id]);
        }else{
            var result = tx.executeSql('SELECT * FROM project_task_app where account_id = 0 AND project_id = ? AND sub_project_id = ?', [project_id, sub_project_id]);
        }
        for (var i = 0; i < result.rows.length; i++) {
            var child_tasks = tx.executeSql('SELECT count(*) as count FROM project_task_app where parent_id = ?', [result.rows.item(i).id]);
            
            tasks_list.push({'id': result.rows.item(i).id, 'name': result.rows.item(i).name, 'taskHasSubTask': true ? child_tasks.rows.item(0).count > 0 : false,'parent_id':result.rows.item(i).parent_id})
        }
    })
    return tasks_list;
}

function fetch_sub_tasks(task_id) {
    var db = LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);
    
    var sub_tasks_list = []
    db.transaction(function(tx) {
        if(workpersonaSwitchState){
            var child_tasks = tx.executeSql('SELECT * FROM project_task_app where parent_id = ?', [task_id]);
        }else{
            var child_tasks = tx.executeSql('SELECT * FROM project_task_app where account_id IS NULL AND parent_id = ?', [task_id]);
        }
        for (var i = 0; i < child_tasks.rows.length; i++) {
            sub_tasks_list.push({'id': child_tasks.rows.item(i).id, 'name': child_tasks.rows.item(i).name})
        }
    })
    return sub_tasks_list
}

function timesheetData(data) {
    var db = LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);
    db.transaction(function(tx) {
        var unitAmount = 0
        if (data.isManualTimeRecord) {
            unitAmount = convTimeFloat(data.manualSpentHours)
        } else {
            unitAmount = convTimeFloat(data.spenthours)
        }
        tx.executeSql('INSERT INTO account_analytic_line_app \
            (account_id, record_date, project_id, task_id, name, sub_project_id, sub_task_id, quadrant_id,  \
            unit_amount, last_modified) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
             [data.instance_id, data.dateTime, data.project, data.task, data.description, data.subprojectId, data.subTask, data.quadrant, unitAmount, new Date().toISOString()]);

        datesmartBtnStart = ""
    });

}
