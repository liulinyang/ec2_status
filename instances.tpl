<!DOCTYPE html>
<html lang="en">
<head>
    <title>QA AWS EC2 Instances Usage Report</title>
<style type="text/css">
body {font-family:Arial, sans-serif;font-size:14px;color:#333}
.tg  {border-collapse:collapse;border-spacing:0;border-color:#ccc;margin:0px auto;}
.tg td{font-family:Arial, sans-serif;font-size:14px;padding:10px 5px;border-style:solid;border-width:1px;overflow:hidden;word-break:normal;border-color:#ccc;color:#333;background-color:#fff;}
.tg th{font-family:Arial, sans-serif;font-size:14px;font-weight:normal;padding:10px 5px;border-style:solid;border-width:1px;overflow:hidden;word-break:normal;border-color:#ccc;color:#333;background-color:#f0f0f0;}
.tg .tg-9hbo{font-weight:bold;vertical-align:top}
.tg .tg-b7b8{background-color:#f9f9f9;vertical-align:top}
.tg .tg-yw4l{vertical-align:top}
.tg .tg-9w9z{background-color:#f9f9f9;color:#cb0000;vertical-align:top}
th.tg-sort-header::-moz-selection { background:transparent; }th.tg-sort-header::selection      { background:transparent; }th.tg-sort-header { cursor:pointer; }table th.tg-sort-header:after {  content:'';  float:right;  margin-top:7px;  border-width:0 4px 4px;  border-style:solid;  border-color:#404040 transparent;  visibility:hidden;  }table th.tg-sort-header:hover:after {  visibility:visible;  }table th.tg-sort-desc:after,table th.tg-sort-asc:after,table th.tg-sort-asc:hover:after {  visibility:visible;  opacity:0.4;  }table th.tg-sort-desc:after {  border-bottom:none;  border-width:4px 4px 0;  }</style>

</head>
<body>

<p>
Hi All,
</p>

<p> Below are the running ec2/RDS/ElasticSearch instances in AWS {{account}} account. Please be ware of the <span style="color:red">red</span> items. The instace would be marked in red if it matchs one of below criteria.</p>
<div style="font-size:14px;">
<ul>
	<li>it doesn't have 'owner' tag</li>
	<li>it doesn't have 'keep' tag and 'running days' > 5 days, unless it's owner is 'stg', which means it's in {{ account }} STG Environment.</li>
</ul>
</div>

<h4> RDS Instance Status </h4>
	<table id="tg-oiQCN" class="tg">
	<tr>
		<th class="tg-9hbo">No</th>
		<th class="tg-9hbo">Instance ID</th>
		<th class="tg-9hbo">Type</th>
		<th class="tg-9hbo">Storage(G)</th>
		<th class="tg-9hbo">Engine</th>
		<th class="tg-9hbo">Running Days</th>
		<th class="tg-9hbo">Keep</th>
		<th class="tg-9hbo">Owner</th>
		<th class="tg-9hbo">Region</th>
	</tr>
    {% for idx, i in rds_instances %}
	<tr>
		{% if i['flag'] == 'X' %}
			<td class="{{ td_class['warning'] }}"> {{ idx }} </td>
			<td class="{{ td_class['warning'] }}"> {{ i['instance_id'] }} </td>
			<td class="{{ td_class['warning'] }}"> {{ i['instance_type'] }} </td>
			<td class="{{ td_class['warning'] }}"> {{ i['storage'] }} </td>
			<td class="{{ td_class['warning'] }}"> {{ i['engine_version'] }} </td>
			<td class="{{ td_class['warning'] }}"> {{ i['running'] }} </td>
			<td class="{{ td_class['warning'] }}"> {{ i['keep'] }} </td>
			<td class="{{ td_class['warning'] }}"> {{ i['owner'] }} </td>
			<td class="{{ td_class['warning'] }}"> {{ i['region'] }} </td>
		{% elif idx%2 == 0 %}
			<td class="{{ td_class['even'] }}"> {{ idx }} </td>
			<td class="{{ td_class['even'] }}"> {{ i['instance_id'] }} </td>
			<td class="{{ td_class['even'] }}"> {{ i['instance_type'] }} </td>
			<td class="{{ td_class['even'] }}"> {{ i['storage'] }} </td>
			<td class="{{ td_class['even'] }}"> {{ i['engine_version'] }} </td>
			<td class="{{ td_class['even'] }}"> {{ i['running'] }} </td>
			<td class="{{ td_class['even'] }}"> {{ i['keep'] }} </td>
			<td class="{{ td_class['even'] }}"> {{ i['owner'] }} </td>
			<td class="{{ td_class['even'] }}"> {{ i['region'] }} </td>
		{% else %}
			<td class="{{ td_class['odd'] }}"> {{ idx }} </td>
			<td class="{{ td_class['odd'] }}"> {{ i['instance_id'] }} </td>
			<td class="{{ td_class['odd'] }}"> {{ i['instance_type'] }} </td>
			<td class="{{ td_class['odd'] }}"> {{ i['storage'] }} </td>
			<td class="{{ td_class['odd'] }}"> {{ i['engine_version'] }} </td>
			<td class="{{ td_class['odd'] }}"> {{ i['running'] }} </td>
			<td class="{{ td_class['odd'] }}"> {{ i['keep'] }} </td>
			<td class="{{ td_class['odd'] }}"> {{ i['owner'] }} </td>
			<td class="{{ td_class['odd'] }}"> {{ i['region'] }} </td>
		{% endif %}
	</tr>
    {% endfor %}
	</table>

<h4> ElasticSearch Domain Status </h4>
	<table id="tg-oiQCN" class="tg">
	<tr>
		<th class="tg-9hbo">No</th>
		<th class="tg-9hbo">Instance ID</th>
		<th class="tg-9hbo">Type</th>
		<th class="tg-9hbo">Instance Count</th>
		<th class="tg-9hbo">Master Instance Type</th>
		<th class="tg-9hbo">Master Instance Count</th>
		<th class="tg-9hbo">EBS Storage(G)</th>
		<th class="tg-9hbo">Role</th>
		<th class="tg-9hbo">Running Days</th>
		<th class="tg-9hbo">Keep</th>
		<th class="tg-9hbo">Owner</th>
		<th class="tg-9hbo">Region</th>
	</tr>
    {% for idx, i in es_instances %}
	<tr>
		{% if i['flag'] == 'X' %}
			<td class="{{ td_class['warning'] }}"> {{ idx }} </td>
			<td class="{{ td_class['warning'] }}"> {{ i['instance_id'] }} </td>
			<td class="{{ td_class['warning'] }}"> {{ i['instance_type'] }} </td>
			<td class="{{ td_class['warning'] }}"> {{ i['instance_count'] }} </td>
			<td class="{{ td_class['warning'] }}"> {{ i['master_instance_type'] }} </td>
			<td class="{{ td_class['warning'] }}"> {{ i['master_instance_count'] }} </td>
			<td class="{{ td_class['warning'] }}"> {{ i['storage'] }} </td>
			<td class="{{ td_class['warning'] }}"> {{ i['role'] }} </td>
			<td class="{{ td_class['warning'] }}"> {{ i['running'] }} </td>
			<td class="{{ td_class['warning'] }}"> {{ i['keep'] }} </td>
			<td class="{{ td_class['warning'] }}"> {{ i['owner'] }} </td>
			<td class="{{ td_class['warning'] }}"> {{ i['region'] }} </td>
		{% elif idx%2 == 0 %}
			<td class="{{ td_class['even'] }}"> {{ idx }} </td>
			<td class="{{ td_class['even'] }}"> {{ i['instance_id'] }} </td>
			<td class="{{ td_class['even'] }}"> {{ i['instance_type'] }} </td>
			<td class="{{ td_class['even'] }}"> {{ i['instance_count'] }} </td>
			<td class="{{ td_class['even'] }}"> {{ i['master_instance_type'] }} </td>
			<td class="{{ td_class['even'] }}"> {{ i['master_instance_count'] }} </td>
			<td class="{{ td_class['even'] }}"> {{ i['storage'] }} </td>
			<td class="{{ td_class['even'] }}"> {{ i['role'] }} </td>
			<td class="{{ td_class['even'] }}"> {{ i['running'] }} </td>
			<td class="{{ td_class['even'] }}"> {{ i['keep'] }} </td>
			<td class="{{ td_class['even'] }}"> {{ i['owner'] }} </td>
			<td class="{{ td_class['even'] }}"> {{ i['region'] }} </td>
		{% else %}
			<td class="{{ td_class['odd'] }}"> {{ idx }} </td>
			<td class="{{ td_class['odd'] }}"> {{ i['instance_id'] }} </td>
			<td class="{{ td_class['odd'] }}"> {{ i['instance_type'] }} </td>
			<td class="{{ td_class['odd'] }}"> {{ i['instance_count'] }} </td>
			<td class="{{ td_class['odd'] }}"> {{ i['master_instance_type'] }} </td>
			<td class="{{ td_class['odd'] }}"> {{ i['master_instance_count'] }} </td>
			<td class="{{ td_class['odd'] }}"> {{ i['storage'] }} </td>
			<td class="{{ td_class['odd'] }}"> {{ i['role'] }} </td>
			<td class="{{ td_class['odd'] }}"> {{ i['running'] }} </td>
			<td class="{{ td_class['odd'] }}"> {{ i['keep'] }} </td>
			<td class="{{ td_class['odd'] }}"> {{ i['owner'] }} </td>
			<td class="{{ td_class['odd'] }}"> {{ i['region'] }} </td>
		{% endif %}
	</tr>
    {% endfor %}
	</table>

<h4> EC2 Instance Status </h4>
	<table id="tg-oiQCN" class="tg">
	<tr>
		<th class="tg-9hbo">No</th>
		<th class="tg-9hbo">Instance ID</th>
		<th class="tg-9hbo">Type</th>
		<th class="tg-9hbo">Name</th>
		<th class="tg-9hbo">Role</th>
		<th class="tg-9hbo">Running Days</th>
		<th class="tg-9hbo">Keep</th>
		<th class="tg-9hbo">Owner</th>
		<th class="tg-9hbo">Region</th>
	</tr>
    {% for idx, i in ec2_instances %}
	<tr>
		{% if i['flag'] == 'X' %}
			<td class="{{ td_class['warning'] }}"> {{ idx }} </td>
			<td class="{{ td_class['warning'] }}"> {{ i['instance_id'] }} </td>
			<td class="{{ td_class['warning'] }}"> {{ i['instance_type'] }} </td>
			<td class="{{ td_class['warning'] }}"> {{ i['name'] }} </td>
			<td class="{{ td_class['warning'] }}"> {{ i['role'] }} </td>
			<td class="{{ td_class['warning'] }}"> {{ i['running'] }} </td>
			<td class="{{ td_class['warning'] }}"> {{ i['keep'] }} </td>
			<td class="{{ td_class['warning'] }}"> {{ i['owner'] }} </td>
			<td class="{{ td_class['warning'] }}"> {{ i['region'] }} </td>
		{% elif idx%2 == 0 %}
			<td class="{{ td_class['even'] }}"> {{ idx }} </td>
			<td class="{{ td_class['even'] }}"> {{ i['instance_id'] }} </td>
			<td class="{{ td_class['even'] }}"> {{ i['instance_type'] }} </td>
			<td class="{{ td_class['even'] }}"> {{ i['name'] }} </td>
			<td class="{{ td_class['even'] }}"> {{ i['role'] }} </td>
			<td class="{{ td_class['even'] }}"> {{ i['running'] }} </td>
			<td class="{{ td_class['even'] }}"> {{ i['keep'] }} </td>
			<td class="{{ td_class['even'] }}"> {{ i['owner'] }} </td>
			<td class="{{ td_class['even'] }}"> {{ i['region'] }} </td>
		{% else %}
			<td class="{{ td_class['odd'] }}"> {{ idx }} </td>
			<td class="{{ td_class['odd'] }}"> {{ i['instance_id'] }} </td>
			<td class="{{ td_class['odd'] }}"> {{ i['instance_type'] }} </td>
			<td class="{{ td_class['odd'] }}"> {{ i['name'] }} </td>
			<td class="{{ td_class['odd'] }}"> {{ i['role'] }} </td>
			<td class="{{ td_class['odd'] }}"> {{ i['running'] }} </td>
			<td class="{{ td_class['odd'] }}"> {{ i['keep'] }} </td>
			<td class="{{ td_class['odd'] }}"> {{ i['owner'] }} </td>
			<td class="{{ td_class['odd'] }}"> {{ i['region'] }} </td>
		{% endif %}
	</tr>
    {% endfor %}
	</table>


<p>
Kevin
</p>
</body>
</html>
