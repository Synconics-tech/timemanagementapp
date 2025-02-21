.import QtQuick.LocalStorage 2.7 as Sql

/* Name: initializeDatabase
* This function will initialize database table structure
* Table structure is as following:
* users -> for Odoo instances
* project_project_app -> for Projects
* project_task_app -> for Tasks
* res_users_app -> Users to select in activity and tasks for assignation
* account_analytic_line_app -> for Timesheet entries
* mail_activity_type_app -> type of activity to select in activity, like; call, meeting, etc.
* mail_activity_app -> for Activities
*/

function initializeDatabase() {
    var db = Sql.LocalStorage.openDatabaseSync("myDatabase", "1.0", "My Database", 1000000);
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
        var instances = tx.executeSql('PRAGMA table_info(users)');
        var existing_columns = [];
        var match_column_list = ['id INTEGER', 'name TEXT', 'link TEXT', 'last_modified datetime', 'database TEXT', 'connectwith_id INTEGER', 'api_key TEXT', 'username TEXT'];
        for (var instance = 0; instance < instances.rows.length; instance++) {
            existing_columns.push(instances.rows.item(instance).name);
        }
        for (var match_column = 0; match_column < match_column_list.length; match_column++) {
            if (!existing_columns.includes(match_column_list[match_column].split(' ')[0])) {
                tx.executeSql(`ALTER TABLE users ADD COLUMN ${match_column_list[match_column]}`)
            }
        }
    }) 

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
        var instances = tx.executeSql('PRAGMA table_info(project_project_app)');
        var existing_columns = [];
        var match_column_list = ['id INTEGER', 'name TEXT', 'account_id TEXT', 'parent_id INTEGER', 'planned_start_date date',
                         'planned_end_date date', 'allocated_hours FLOAT', 'favorites INTEGER', 'last_update_status TEXT', 'description TEXT',
                         'last_modified datetime', 'color_pallet TEXT', 'odoo_record_id INTEGER'];
        for (var instance = 0; instance < instances.rows.length; instance++) {
            existing_columns.push(instances.rows.item(instance).name);
        }
        for (var match_column = 0; match_column < match_column_list.length; match_column++) {
            if (!existing_columns.includes(match_column_list[match_column].split(' ')[0])) {
                tx.executeSql(`ALTER TABLE project_project_app ADD COLUMN ${match_column_list[match_column]}`)
            }
        }
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
        var instances = tx.executeSql('PRAGMA table_info(res_users_app)');
        var existing_columns = [];
        var match_column_list = ['id INTEGER', 'account_id INTEGER', 'name TEXT', 'share INTEGER', 'active INTEGER',
                         'odoo_record_id INTEGER'];
        for (var instance = 0; instance < instances.rows.length; instance++) {
            existing_columns.push(instances.rows.item(instance).name);
        }
        for (var match_column = 0; match_column < match_column_list.length; match_column++) {
            if (!existing_columns.includes(match_column_list[match_column].split(' ')[0])) {
                tx.executeSql(`ALTER TABLE res_users_app ADD COLUMN ${match_column_list[match_column]}`)
            }
        }
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
        var instances = tx.executeSql('PRAGMA table_info(project_task_app)');
        var existing_columns = [];
        var match_column_list = ['id INTEGER',
                                'name TEXT',
                                'account_id INTEGER',
                                'project_id INTEGER',
                                'sub_project_id INTEGER',
                                'parent_id INTEGER',
                                'start_date date',
                                'end_date date',
                                'deadline date',
                                'initial_planned_hours FLOAT',
                                'favorites INTEGER',
                                'state TEXT',
                                'description TEXT',
                                'last_modified datetime',
                                'user_id INTEGER',
                                'odoo_record_id INTEGER'];
        for (var instance = 0; instance < instances.rows.length; instance++) {
            existing_columns.push(instances.rows.item(instance).name);
        }
        for (var match_column = 0; match_column < match_column_list.length; match_column++) {
            if (!existing_columns.includes(match_column_list[match_column].split(' ')[0])) {
                tx.executeSql(`ALTER TABLE project_task_app ADD COLUMN ${match_column_list[match_column]}`)
            }
        }
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
        var instances = tx.executeSql('PRAGMA table_info(account_analytic_line_app)');
        var existing_columns = [];
        var match_column_list = ['id INTEGER',
                                'account_id INTEGER',
                                'project_id INTEGER',
                                'sub_project_id INTEGER',
                                'task_id INTEGER',
                                'sub_task_id INTEGER',
                                'name TEXT',
                                'unit_amount FLOAT',
                                'last_modified datetime',
                                'quadrant_id INTEGER',
                                'record_date date',
                                'odoo_record_id INTEGER'];
        for (var instance = 0; instance < instances.rows.length; instance++) {
            existing_columns.push(instances.rows.item(instance).name);
        }
        for (var match_column = 0; match_column < match_column_list.length; match_column++) {
            if (!existing_columns.includes(match_column_list[match_column].split(' ')[0])) {
                tx.executeSql(`ALTER TABLE account_analytic_line_app ADD COLUMN ${match_column_list[match_column]}`)
            }
        }
    });

    db.transaction(function(tx) {
        tx.executeSql('CREATE TABLE IF NOT EXISTS mail_activity_type_app (\
            id INTEGER PRIMARY KEY AUTOINCREMENT,\
            account_id INTEGER,\
            name TEXT,\
            odoo_record_id INTEGER,\
            FOREIGN KEY (account_id) REFERENCES users(id) ON DELETE CASCADE\
        )');
        var instances = tx.executeSql('PRAGMA table_info(mail_activity_type_app)');
        var existing_columns = [];
        var match_column_list = ['id INTEGER',
                                'account_id INTEGER',
                                'name TEXT',
                                'odoo_record_id INTEGER'];
        for (var instance = 0; instance < instances.rows.length; instance++) {
            existing_columns.push(instances.rows.item(instance).name);
        }
        for (var match_column = 0; match_column < match_column_list.length; match_column++) {
            if (!existing_columns.includes(match_column_list[match_column].split(' ')[0])) {
                tx.executeSql(`ALTER TABLE mail_activity_type_app ADD COLUMN ${match_column_list[match_column]}`)
            }
        }
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
        var instances = tx.executeSql('PRAGMA table_info(mail_activity_app)');
        var existing_columns = [];
        var match_column_list = ['id INTEGER',
                                'account_id INTEGER',
                                'activity_type_id INTEGER',
                                'summary TEXT',
                                'due_date DATE',
                                'user_id INTEGER',
                                'notes TEXT',
                                'odoo_record_id INTEGER',
                                'last_modified datetime',
                                'link_id INTEGER',
                                'project_id INTEGER',
                                'task_id INTEGER',
                                'resId INTEGER',
                                'resModel TEXT',
                                'state TEXT'];
        for (var instance = 0; instance < instances.rows.length; instance++) {
            existing_columns.push(instances.rows.item(instance).name);
        }
        for (var match_column = 0; match_column < match_column_list.length; match_column++) {
            if (!existing_columns.includes(match_column_list[match_column].split(' ')[0])) {
                tx.executeSql(`ALTER TABLE mail_activity_app ADD COLUMN ${match_column_list[match_column]}`)
            }
        }
    });

}
