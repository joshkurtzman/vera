var VistaAlarm = (function (api) {
		// example of unique identifier for this plugin...
		var uuid = 'B971F6C4-F315-4E2E-AD08-F029A9777517';
		 
		var myModule = {};
		 
		var vap = {
			device : 0,
			PANEL_SID : "urn:micasaverde-com:serviceId:VistaAlarmPanel1",
			zones : {},
			labels : {}
			};
			

		function updateZoneLabels() {
			var zone = "";
			var labelsRaw = "";

			for (zone in vap.labels) {
				labelsRaw += ";" + zone + "," + vap.labels[zone] ;
			}
			labelsRaw = labelsRaw.substring(1); // Remove the first semicolon(;).

			set_device_state(vap.device, vap.PANEL_SID, "ZoneInfo", labelsRaw, 0);
			showSettings(vap.device);
			
		}

		function addLabel() {
			var zone = "";
			var label = "";

			zone = document.getElementById("vista_zone_no").value;
			label = document.getElementById("vista_zone_label").value;

			if (zone.match(/^(\d+)$/) === null || label === "") {
				return;
			}

			vap.labels[zone] = label;
			vap.zones[zone] = zone;

			updateZoneLabels();
		}

		function removeLabel(zone) {
			delete vap.labels[zone];
			delete vap.zones[zone];
			updateZoneLabels();
		}

		//*****************************************************************************
		// showCheatSheet
		//  input  : the device number
		//  output : nothing
		//*****************************************************************************
		function showSettings(device) {
			var html = "";
			var labelsRaw = "";
			var labelsSplit = [];
			var captures = "";
			var i;

			vap.device = device;

			labelsRaw = get_device_state(vap.device, vap.PANEL_SID, "ZoneInfo", 0) || "";

			html += '<table style="width:90%; border-collapse:collapse; border:1px solid #8BB0D6; margin-left:5%">';
			html += '<tr>';
			html += '<th style="width:50px; text-align:center; border:1px solid #8BB0D6">Zone #</th>';
			html += '<th style="text-align:center; border:1px solid #8BB0D6">Label</th>';
			html += '<th style="width:90px; text-align:center; border:1px solid #8BB0D6">Action</th>';
			html += '</tr>';

			if (labelsRaw !== "") {
				labelsSplit = labelsRaw.split(';');
				for (i = 0; i < labelsSplit.length; i++) {
					captures = labelsSplit[i].split(',');
					vap.zones[captures[0]] = captures[0];
					vap.labels[captures[0]] = captures[1];
				}

				for (zone in vap.labels) {
					html += '<tr>';
					html += '<td style="border:1px solid #8BB0D6; padding-right:10px; text-align:right">' + zone + '</td>';
					html += '<td style="border:1px solid #8BB0D6; padding-left:10px">' + vap.labels[zone] + '</td>';
					html += '<td style="border:1px solid #8BB0D6; text-align:center"><input type="button" class="btnNormal_c" value="Remove" onclick="VistaAlarm.removeLabel(\'' + zone + '\')" /></td>';
					html += '</tr>';
				}
			}

			html += '<tr>';
			html += '<td style="border:1px solid #8BB0D6; text-align:center"><input type="text" maxlength="3" id="vista_zone_no" style="width:30px" /></td>';
			html += '<td style="border:1px solid #8BB0D6; text-align:center"><input type="text" id="vista_zone_label" style="width:90%" /></td>';

			html += '<td style="border:1px solid #8BB0D6; text-align:center"><input type="button" class="btnNormal_c" value="Add" onclick="VistaAlarm.addLabel()" /></td>';
			html += '</tr>';
			html += '</table>';

			api.setCpanelContent(html);
		} 
	 
		myModule = {
				uuid: uuid,
				showSettings: showSettings,
				removeLabel:  removeLabel,
				addLabel: addLabel
			};
			
	return myModule;
})(api);

