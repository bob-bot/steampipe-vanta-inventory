dashboard "unsupported_apps_using_slack" {
  title = "Employee Computers with Unsupported Apps & Browsers for Slack"
  
  tags = {
    service = "OS Asset Inventory"
  }

  text {
    value = "The following list are for employees with unsupported Applications & Browsers to connect with Slack starting March 1st, 2023."
  }

  container {
    width = 6
    card {
      sql   = query.vanta_count_employees_slack_apps_need_updated.sql
      width = 4
    }
      table {
      title = "List of slack applications to be updated, Slack version <= 4.23"
      sql = query.vanta_list_apps_need_updated_for_slack.sql
    }
  }

  container {
    width = 6
    card {
      sql   = query.vanta_count_employees_slack_browsers_need_updated.sql
      width = 4
    }
      table {
      title = "List of browsers to be updated, browser versions <= Edge 94, Chrome 93, Firefox 91, Safari 14"
      sql = query.vanta_list_browsers_need_updated_for_slack.sql
    }
  }

table {
    title = "Combined list of slack applications and browsers to be updated"
    sql = query.vanta_list_apps_browsers_need_updated_for_slack.sql
  }

}

# Card Queries

query "vanta_count_employees_slack_apps_need_updated" {
  sql = <<-EOQ
  select
      count(*) as "value",
      '# employees to update their Slack App' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
  from
    vanta_computer,
    jsonb_array_elements_text(endpoint_applications) as app
  where
    app SIMILAR TO 'Slack [0-9]%'
    and string_to_array(split_part(app, ' ', 2), '.') :: int [] < string_to_array('4.24', '.') :: int []
  EOQ
}

query "vanta_count_employees_slack_browsers_need_updated" {
  sql = <<-EOQ
with count_devices as (
select owner_name
from
    vanta_computer,
    jsonb_array_elements_text(endpoint_applications) as app
where
    app similar to 'Safari [0-9]%'
    and string_to_array(split_part(app, ' ', 2), '.') :: int [] < string_to_array('15.0', '.') :: int []

UNION

select owner_name
from
    vanta_computer,
    jsonb_array_elements_text(endpoint_applications) as app
where
    app SIMILAR TO 'Microsoft Edge [0-9]%'
    and string_to_array(split_part(app, ' ', 3), '.') :: int [] < string_to_array('95', '.') :: int []

UNION

select owner_name
from
  vanta_computer,
  jsonb_array_elements_text(endpoint_applications) as app
where
  (app SIMILAR TO 'Firefox [0-9]%'
  and string_to_array(split_part(app, ' ', 2), '.') :: int [] < string_to_array('95', '.') :: int []) 
  or (app SIMILAR TO 'Mozilla Firefox [0-9]%'
  and string_to_array(split_part(app, ' ', 3), '.') :: int [] < string_to_array('95', '.') :: int [])
  
UNION

select owner_name
from
  vanta_computer,
  jsonb_array_elements_text(endpoint_applications) as app
where
  (app SIMILAR TO 'Chrome [0-9]%'
  and string_to_array(split_part(app, ' ', 2), '.') :: int [] < string_to_array('94', '.') :: int []) 
  or (app SIMILAR TO 'Google Chrome [0-9]%'
  and string_to_array(split_part(app, ' ', 3), '.') :: int [] < string_to_array('94', '.') :: int [])
)
  select
      count(*) as "value",
      '# employees to update their browsers' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
  from
    count_devices
  EOQ
}

# Table Queries

query "vanta_list_apps_need_updated_for_slack" {
  sql = <<-EOQ
select
    owner_name,
    hostname,
    serial_number,
    app as application
from
    vanta_computer,
    jsonb_array_elements_text(endpoint_applications) as app
where
    app SIMILAR TO 'Slack [0-9]%'
    and string_to_array(split_part(app, ' ', 2), '.') :: int [] < string_to_array('4.24', '.') :: int []
    order by owner_name;
  EOQ
}


query "vanta_list_browsers_need_updated_for_slack" {
  sql = <<-EOQ
select
    owner_name,
    hostname,
    serial_number,
    app as application
from
    vanta_computer,
    jsonb_array_elements_text(endpoint_applications) as app
where
    app similar to 'Safari [0-9]%'
    and string_to_array(split_part(app, ' ', 2), '.') :: int [] < string_to_array('15.0', '.') :: int []

UNION

select
    owner_name,
    hostname,
    serial_number,
    app as application
from
    vanta_computer,
    jsonb_array_elements_text(endpoint_applications) as app
where
    app SIMILAR TO 'Microsoft Edge [0-9]%'
    and string_to_array(split_part(app, ' ', 3), '.') :: int [] < string_to_array('95', '.') :: int []

UNION

select
  owner_name,
  hostname,
  serial_number,
  app as application
from
  vanta_computer,
  jsonb_array_elements_text(endpoint_applications) as app
where
  (app SIMILAR TO 'Firefox [0-9]%'
  and string_to_array(split_part(app, ' ', 2), '.') :: int [] < string_to_array('95', '.') :: int []) 
  or (app SIMILAR TO 'Mozilla Firefox [0-9]%'
  and string_to_array(split_part(app, ' ', 3), '.') :: int [] < string_to_array('95', '.') :: int [])
  
UNION

select
  owner_name,
  hostname,
  serial_number,
  app as application
from
  vanta_computer,
  jsonb_array_elements_text(endpoint_applications) as app
where
  (app SIMILAR TO 'Chrome [0-9]%'
  and string_to_array(split_part(app, ' ', 2), '.') :: int [] < string_to_array('94', '.') :: int []) 
  or (app SIMILAR TO 'Google Chrome [0-9]%'
  and string_to_array(split_part(app, ' ', 3), '.') :: int [] < string_to_array('94', '.') :: int [])
  
  order by owner_name;
  EOQ
}



query "vanta_list_apps_browsers_need_updated_for_slack" {
  sql = <<-EOQ
select
    owner_name,
    hostname,
    serial_number,
    app as application
from
    vanta_computer,
    jsonb_array_elements_text(endpoint_applications) as app
where
    app SIMILAR TO 'Slack [0-9]%'
    and string_to_array(split_part(app, ' ', 2), '.') :: int [] < string_to_array('4.24', '.') :: int []
    
UNION

select
    owner_name,
    hostname,
    serial_number,
    app as application
from
    vanta_computer,
    jsonb_array_elements_text(endpoint_applications) as app
where
    app similar to 'Safari [0-9]%'
    and string_to_array(split_part(app, ' ', 2), '.') :: int [] < string_to_array('15.0', '.') :: int []

UNION

select
    owner_name,
    hostname,
    serial_number,
    app as application
from
    vanta_computer,
    jsonb_array_elements_text(endpoint_applications) as app
where
    app SIMILAR TO 'Microsoft Edge [0-9]%'
    and string_to_array(split_part(app, ' ', 3), '.') :: int [] < string_to_array('95', '.') :: int []

UNION

select
  owner_name,
  hostname,
  serial_number,
  app as application
from
  vanta_computer,
  jsonb_array_elements_text(endpoint_applications) as app
where
  (app SIMILAR TO 'Firefox [0-9]%'
  and string_to_array(split_part(app, ' ', 2), '.') :: int [] < string_to_array('95', '.') :: int []) 
  or (app SIMILAR TO 'Mozilla Firefox [0-9]%'
  and string_to_array(split_part(app, ' ', 3), '.') :: int [] < string_to_array('95', '.') :: int [])
  
UNION

select
  owner_name,
  hostname,
  serial_number,
  app as application
from
  vanta_computer,
  jsonb_array_elements_text(endpoint_applications) as app
where
  (app SIMILAR TO 'Chrome [0-9]%'
  and string_to_array(split_part(app, ' ', 2), '.') :: int [] < string_to_array('94', '.') :: int []) 
  or (app SIMILAR TO 'Google Chrome [0-9]%'
  and string_to_array(split_part(app, ' ', 3), '.') :: int [] < string_to_array('94', '.') :: int [])
  
  order by owner_name;
  EOQ
}
