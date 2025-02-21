"""
Copyright (C) 2024  Synconics Technologies Pvt. Ltd.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; version 3.

odooprojecttimesheet is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
"""

import xmlrpc.client
from datetime import datetime
import urllib3
import json

urllib3.disable_warnings()

http = urllib3.PoolManager(cert_reqs="CERT_NONE")


def fetch_databases(url):
    """Get and identify the database while on the create account page."""
    database_list = get_db_list(url)
    visibility_dict = {
        "menu_items": False,
        "text_field": False,
        "single_db": False,
    }

    if not database_list:
        visibility_dict["text_field"] = True
    elif len(database_list) == 1:
        visibility_dict["single_db"] = database_list[0]
    else:
        visibility_dict["menu_items"] = database_list

    return visibility_dict


def get_db_list(url):
    """To fetch database list from Odoo."""
    try:
        response = http.request(
            "POST",
            url + "/web/database/list",
            body="{}",
            headers={"Content-type": "application/json"},
        )
        if response.status == 200:
            data = json.loads(response.data)
            return data["result"]
        else:
            return []
    except Exception:
        return []
    return []


def login_odoo(selected_url, username, password, database_dict):
    """To check whether login is successful or not."""
    selected_db = False
    if database_dict["isTextInputVisible"]:
        selected_db = database_dict["input_text"]
    elif database_dict["isTextMenuVisible"]:
        selected_db = database_dict["selected_db"]
    if not selected_db and database_dict.get("input_text"):
        selected_db = database_dict.get("input_text")
    common = xmlrpc.client.ServerProxy(
        "{}/xmlrpc/2/common".format(selected_url)
    )
    generated_uid = common.authenticate(selected_db, username, password, {})
    if generated_uid:
        models = xmlrpc.client.ServerProxy(
            "{}/xmlrpc/2/object".format(selected_url),
        )
        user_name = models.execute_kw(
            selected_db,
            generated_uid,
            password,
            "res.users",
            "read",
            [generated_uid],
            {"fields": ["name"]},
        )
        return {
            "result": "pass",
            "name_of_user": user_name[0]["name"],
            "database": selected_db,
            "uid": generated_uid,
        }
    return {"result": "fail"}


def get_model_id(database, odoo_uid, password, model, models):
    """To get Model ID based on model name."""
    record_model = models.execute_kw(
        database,
        odoo_uid,
        password,
        "mail.activity",
        "default_get",
        [["res_model", "res_model_id"]],
        {"context": {"default_res_model": model}},
    )
    if record_model.get("res_model_id"):
        return record_model.get("res_model_id")
    return False


def get_audit_logs(
    database,
    odoo_uid,
    password,
    model,
    models,
    last_modified=False,
):
    """To fetch audit logs in case of unlink records."""
    model_id = get_model_id(
        database, odoo_uid, password, "auditlog.rule", models
    )
    if model_id:
        record_model = get_model_id(
            database, odoo_uid, password, model, models
        )
        audit_log_rule = False
        try:
            audit_log_rule = models.execute_kw(
                database,
                odoo_uid,
                password,
                "auditlog.rule",
                "search",
                [
                    [
                        ["model_id", "=", record_model],
                        ["log_unlink", "=", True],
                        ["state", "=", "subscribed"],
                    ]
                ],
            )
        except Exception:
            audit_log_rule = False
        if audit_log_rule:
            audit_log_domain = [
                ["method", "=", "unlink"],
                ["model_id", "=", record_model],
            ]
            if last_modified:
                formatted_date = datetime.strptime(
                    last_modified[:-1], "%Y-%m-%dT%H:%M:%S.%f"
                )
                audit_log_domain.append(
                    [
                        "create_date",
                        ">=",
                        formatted_date.strftime("%Y-%m-%d %H:%M:%S"),
                    ]
                )
            record_sets = models.execute_kw(
                database,
                odoo_uid,
                password,
                "auditlog.log",
                "search_read",
                [audit_log_domain],
                {"fields": ["res_id"]},
            )
            return [rec.get("res_id") for rec in record_sets]
    return []


def fetch_projects(
    selected_url, username, password, database_dict, last_modified=False
):
    """To fetch projects from Odoo ERP to the app."""
    response = login_odoo(selected_url, username, password, database_dict)
    if response.get("result") == "fail":
        return

    models = xmlrpc.client.ServerProxy(
        "{}/xmlrpc/2/object".format(selected_url),
    )
    fetch_all_records = False
    existing_projects = []
    res_model = "project.project"
    database = response.get("database")
    odoo_uid = response.get("uid")

    domain = []
    if last_modified:
        write_date = datetime.strptime(
            last_modified[:-1], "%Y-%m-%dT%H:%M:%S.%f"
        )
        domain.append(
            [
                "write_date",
                ">=",
                write_date.strftime("%Y-%m-%d %H:%M:%S"),
            ]
        )
    try:
        projects = models.execute_kw(
            database,
            odoo_uid,
            password,
            res_model,
            "search_read",
            [domain],
            {"order": "parent_id desc"},
        )
    except Exception:
        projects = models.execute_kw(
            database,
            odoo_uid,
            password,
            res_model,
            "search_read",
            [domain],
        )
        for project in projects:
            project.update({"parent_id": False})

    deleted_records = get_audit_logs(
        database, odoo_uid, password, res_model, models, last_modified
    )
    if not deleted_records:
        fetch_all_records = True
        existing_projects = models.execute_kw(
            database, odoo_uid, password, res_model, "search", [[]]
        )
    return {
        "projects": projects,
        "existing_projects": existing_projects,
        "fetch_all_records": fetch_all_records,
        "deleted_records": deleted_records,
    }


def fetch_activity_type(
    selected_url, username, password, database_dict, last_modified=False
):
    """To fetch activity types."""
    response = login_odoo(selected_url, username, password, database_dict)
    models = xmlrpc.client.ServerProxy(
        "{}/xmlrpc/2/object".format(selected_url),
    )
    domain = []
    res_model = "mail.activity.type"
    database = response.get("database")
    odoo_uid = response.get("uid")
    if last_modified:
        formatted_date = datetime.strptime(
            last_modified[:-1],
            "%Y-%m-%dT%H:%M:%S.%f",
        )
        domain.append(
            ["write_date", ">=", formatted_date.strftime("%Y-%m-%d %H:%M:%S")]
        )
    activity_types = models.execute_kw(
        database, odoo_uid, password, res_model, "search_read", [domain]
    )
    return activity_types


def create_timesheets(
    selected_url, username, password, database_dict, timesheet_entries
):
    """To synchronize created timesheets."""
    response = login_odoo(selected_url, username, password, database_dict)
    models = xmlrpc.client.ServerProxy(
        "{}/xmlrpc/2/object".format(selected_url),
    )
    records_list = []
    res_model = "account.analytic.line"
    database = response.get("database")
    odoo_uid = response.get("uid")
    fetch_all_records = False
    existing_projects = []

    try:
        model_id = get_model_id(
            database,
            odoo_uid,
            password,
            res_model,
            models,
        )
        field_ids = models.execute_kw(
            database,
            odoo_uid,
            password,
            "ir.model.fields",
            "search_read",
            [[["model_id", "=", model_id]]],
            {"fields": ["name"]},
        )
    except Exception:
        field_ids = []
    fields_list = list(map(lambda field: field.get("name"), field_ids))
    date_field = "date" if "date_time" not in fields_list else "date_time"
    for timesheet in timesheet_entries:
        record_date = datetime.strptime(
            timesheet.get("record_date"), "%m/%d/%Y"
        ).strftime("%Y-%m-%d")
        vals = timesheet.get("unit_amount").split(":")
        t, hours = divmod(float(vals[0]), 24)
        t, minutes = divmod(float(vals[1]), 60)
        minutes = minutes / 60.0
        unit_amount = hours + minutes

        timesheet_dict = {
            date_field: record_date,
            "project_id": int(timesheet.get("project_id")),
            "task_id": int(timesheet.get("task_id")),
            "name": timesheet.get("name"),
            "unit_amount": unit_amount,
        }
        odoo_record_id = timesheet.get("odoo_record_id")
        if isinstance(odoo_record_id, (int, float)):
            try:
                models.execute_kw(
                    database,
                    odoo_uid,
                    password,
                    res_model,
                    "write",
                    [[int(odoo_record_id)], timesheet_dict],
                )
            except Exception:
                pass
        else:
            try:
                odoo_record_id = models.execute_kw(
                    database,
                    odoo_uid,
                    password,
                    res_model,
                    "create",
                    [timesheet_dict],
                )
            except Exception:
                odoo_record_id = False
        records_list.append(
            {
                "local_record_id": timesheet.get("local_record_id"),
                "odoo_record_id": odoo_record_id,
            }
        )

    deleted_records = get_audit_logs(
        database,
        odoo_uid,
        password,
        res_model,
        models,
    )
    if not deleted_records:
        fetch_all_records = True
        existing_projects = models.execute_kw(
            database, odoo_uid, password, res_model, "search", [[]]
        )
    return {
        "fetchedTimesheets": records_list,
        "fetch_all_records": fetch_all_records,
        "existing_records": existing_projects,
        "deleted_records": deleted_records,
    }


def create_activities(
    selected_url, username, password, database_dict, activity_entries
):
    """To synchronize activities."""
    response = login_odoo(selected_url, username, password, database_dict)
    models = xmlrpc.client.ServerProxy(
        "{}/xmlrpc/2/object".format(selected_url),
    )
    records_list = []
    res_model = "mail.activity"
    database = response.get("database")
    odoo_uid = response.get("uid")

    for activity in activity_entries:
        if not activity.get("due_date"):
            continue
        date_deadline = datetime.strptime(
            activity.get("due_date"), "%m/%d/%Y"
        ).strftime("%Y-%m-%d")
        model = "res.partner"
        res_id = False
        link_id = int(activity.get("link_id", 0))
        link_map = {
            1: ("project.project", int(activity.get("project_id"))),
            2: ("project.task", int(activity.get("task_id"))),
            3: (
                activity.get("res_model", False),
                int(activity.get("res_id") if activity.get("res_id") else 0),
            ),
        }
        if link_id in link_map:
            model, res_id = link_map[link_id]
        else:
            user_name = models.execute_kw(
                database,
                odoo_uid,
                password,
                "res.users",
                "read",
                [int(activity.get("user_id"))],
                {"fields": ["partner_id"]},
            )
            res_id = user_name[0]["partner_id"][0]
        model_id = get_model_id(database, odoo_uid, password, model, models)
        activity_dict = {
            "date_deadline": date_deadline,
            "activity_type_id": int(activity.get("activity_type_id")),
            "summary": activity.get("summary"),
            "note": activity.get("notes"),
            "user_id": int(activity.get("user_id")),
            "res_model_id": model_id,
            "res_id": res_id,
        }
        odoo_record_id = activity.get("odoo_record_id")
        if not isinstance(odoo_record_id, (int, float)):
            odoo_record_id = models.execute_kw(
                database,
                odoo_uid,
                password,
                res_model,
                "create",
                [activity_dict],
            )
            records_list.append(
                {
                    "local_record_id": activity.get("local_record_id"),
                    "odoo_record_id": odoo_record_id,
                }
            )
            if (
                "state" in activity
                and activity.get("state") == "done"
                and odoo_record_id
            ):
                try:
                    models.execute_kw(
                        database,
                        odoo_uid,
                        password,
                        res_model,
                        "action_done",
                        [[int(odoo_record_id)]],
                    )
                except Exception:
                    pass
        else:
            models.execute_kw(
                database,
                odoo_uid,
                password,
                res_model,
                "write",
                [[int(odoo_record_id)], activity_dict],
            )
            if "state" in activity and activity.get("state") == "done":
                models.execute_kw(
                    database,
                    odoo_uid,
                    password,
                    res_model,
                    "action_done",
                    [[int(odoo_record_id)]],
                )
    return records_list


def create_update_tasks(
    selected_url, username, password, database_dict, tasks, last_modified=False
):
    """To Synchronize tasks."""
    response = login_odoo(selected_url, username, password, database_dict)
    models = xmlrpc.client.ServerProxy(
        "{}/xmlrpc/2/object".format(selected_url),
    )
    records_sync = []
    res_model = "project.task"
    database = response.get("database")
    odoo_uid = response.get("uid")

    domain = []
    if last_modified:
        formatted_date = datetime.strptime(
            last_modified[:-1],
            "%Y-%m-%dT%H:%M:%S.%f",
        )
        domain.append(
            ["write_date", ">=", formatted_date.strftime("%Y-%m-%d %H:%M:%S")]
        )
    fetched_tasks = models.execute_kw(
        database,
        odoo_uid,
        password,
        res_model,
        "search_read",
        [domain],
        {"order": "parent_id"},
    )
    for task in tasks:
        project_id = task.get("project_id")
        if (
            isinstance(task.get("sub_project_id"), (int, float))
            and task.get("sub_project_id") != 0
        ):
            project_id = task.get("sub_project_id")

        def get_format_date(date):
            if date is not None and date != "mm/dd/yy" and not isinstance(date, (int, float)):
                try:
                    return datetime.strptime(date, "%m/%d/%Y").strftime("%Y-%m-%d")
                except ValueError:
                    datetime.strptime(date, "%Y-%m-%d")
                    return date
            return False
        prepared_record = {
            "name": task.get("name"),
            "project_id": int(project_id),
            "display_project_id": int(project_id),
            "parent_id": int(task.get("parent_id")),
            "date_start": get_format_date(task.get("date_start")),
            "date_end": get_format_date(task.get("date_end")),
            "date_deadline": get_format_date(task.get("deadline")),
            "planned_hours": task.get("initial_planned_hours"),
            "priority": str(int(task.get("favorites"))),
            "description": task.get("description"),
        }
        if task.get("user_id"):
            prepared_record.update(
                {
                    "user_ids": [
                        (6, 0, [int(task.get("user_id"))]),
                    ]
                }
            )
        odoo_record_id = task.get("odoo_record_id")
        if not isinstance(odoo_record_id, (int, float)):
            try:
                record_id = models.execute_kw(
                    database,
                    odoo_uid,
                    password,
                    res_model,
                    "create",
                    [prepared_record],
                )
            except Exception:
                prepared_record.pop("date_start")
                try:
                    record_id = models.execute_kw(
                        database,
                        odoo_uid,
                        password,
                        res_model,
                        "create",
                        [prepared_record],
                    )
                except Exception:
                    record_id = False
                    pass
            records_sync.append(
                {
                    "local_record_id": task.get("local_record_id"),
                    "odoo_record_id": record_id,
                }
            )
        else:
            matched_list = list(
                filter(
                    lambda ml: ml.get("id") == int(odoo_record_id),
                    fetched_tasks,
                )
            )
            task_last_date = datetime.strptime(
                task.get("last_modified"), "%Y-%m-%dT%H:%M:%S.%fZ"
            )
            if matched_list and matched_list[0].get(
                "write_date"
            ) > task_last_date.strftime("%Y-%m-%d %H:%M:%S"):
                pass
            else:
                try:
                    models.execute_kw(
                        database,
                        odoo_uid,
                        password,
                        res_model,
                        "write",
                        [int(odoo_record_id), prepared_record],
                    )
                except Exception:
                    prepared_record.pop("date_start")
                    try:
                        models.execute_kw(
                            database,
                            odoo_uid,
                            password,
                            res_model,
                            "write",
                            [int(odoo_record_id), prepared_record],
                        )
                    except Exception:
                        pass

            records_sync.append(
                {
                    "local_record_id": task.get("local_record_id"),
                    "odoo_record_id": int(odoo_record_id),
                }
            )
    existing_tasks = []
    fetch_all_records = False
    deleted_records = get_audit_logs(
        database, odoo_uid, password, res_model, models, last_modified
    )
    if not deleted_records:
        fetch_all_records = True
        existing_tasks = models.execute_kw(
            database, odoo_uid, password, res_model, "search", [[]]
        )

    return {
        "settled_tasks": records_sync,
        "updated_tasks": {
            "fetchedTasks": fetched_tasks,
            "existing_tasks": existing_tasks,
            "fetch_all_records": fetch_all_records,
            "deleted_records": deleted_records,
        },
    }


def fetch_contacts(
    selected_url, username, password, database_dict, last_modified=False
):
    """To synchronize users."""
    response = login_odoo(selected_url, username, password, database_dict)
    models = xmlrpc.client.ServerProxy(
        "{}/xmlrpc/2/object".format(selected_url),
    )
    domain = []
    res_model = "res.users"
    database = response.get("database")
    odoo_uid = response.get("uid")

    if last_modified:
        formatted_date = datetime.strptime(
            last_modified[:-1],
            "%Y-%m-%dT%H:%M:%S.%f",
        )
        domain.append(
            ["write_date", ">=", formatted_date.strftime("%Y-%m-%d %H:%M:%S")]
        )

    contacts = models.execute_kw(
        database,
        odoo_uid,
        password,
        res_model,
        "search_read",
        [domain],
        {"fields": ["name", "share", "active"]},
    )
    return contacts


def fetch_activities(
    selected_url,
    username,
    password,
    database_dict,
    last_modified=False,
    previous_activities=[],
):
    """To fetch activities."""
    response = login_odoo(selected_url, username, password, database_dict)
    models = xmlrpc.client.ServerProxy(
        "{}/xmlrpc/2/object".format(selected_url),
    )
    res_model = "mail.activity"
    database = response.get("database")
    odoo_uid = response.get("uid")

    domain = ["|", ["user_id", "=", odoo_uid], ["create_uid", "=", odoo_uid]]
    if last_modified:
        formatted_date = datetime.strptime(
            last_modified[:-1],
            "%Y-%m-%dT%H:%M:%S.%f",
        )
        domain.insert(
            0,
            [
                "write_date",
                ">=",
                formatted_date.strftime("%Y-%m-%d %H:%M:%S"),
            ],
        )
    activities = models.execute_kw(
        database,
        odoo_uid,
        password,
        res_model,
        "search_read",
        [domain],
        {
            "fields": [
                "date_deadline",
                "activity_type_id",
                "summary",
                "note",
                "res_model",
                "res_id",
                "user_id",
            ]
        },
    )
    prev_activities = []
    if previous_activities:
        prev_activities = list(
            map(
                lambda prev: int(prev.get("odoo_record_id")),
                list(
                    filter(
                        lambda act: act.get("odoo_record_id")
                        and act.get("odoo_record_id") is not None,
                        previous_activities,
                    )
                ),
            )
        )
    activities_search = models.execute_kw(
        database, odoo_uid, password, res_model, "search", [[]]
    )
    done_activities = []
    for activity in prev_activities:
        if activity not in activities_search:
            done_activities.append(activity)
    return {"activities_list": activities, "done_activities": done_activities}
