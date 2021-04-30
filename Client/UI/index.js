// Registers for ToggleVoice from Scripting
Events.Subscribe("ToggleVoice", function(name, enable) {
	const existing_span = document.querySelector(`.voice_chat#${name}`);

	if (enable) {
		if (existing_span)
			return;

		const span = document.createElement("span");
		span.classList.add("voice_chat");
		span.id = name;
		span.innerHTML = name;

		document.querySelector("#voice_chats").prepend(span);
	} else {
		existing_span.remove();
	}
});

// Registers for Notifications from Scripting
Events.Subscribe("AddNotification", function(message, time) {
	const span = document.createElement("span");
	span.classList.add("notification");
	span.innerHTML = message;

	document.querySelector("#notifications").prepend(span);

	setTimeout(function(span) {
		span.remove()
	}, time, span);
});

// Register for UpdateWeaponAmmo custom event (from Lua)
Events.Subscribe("UpdateWeaponAmmo", function(enable, clip, bag) {
	if (enable)
		document.querySelector("#weapon_ammo_container").style.display = "block";
	else
		document.querySelector("#weapon_ammo_container").style.display = "none";

	// Using JQuery, overrides the HTML content of these SPANs with the new Ammo values
	document.querySelector("#weapon_ammo_clip").innerHTML = clip;
	document.querySelector("#weapon_ammo_bag").innerHTML = bag;
});

// Register for UpdateHealth custom event (from Lua)
Events.Subscribe("UpdateHealth", function(health) {
	// Overrides the HTML content of the SPAN with the new health value
	document.querySelector("#health_current").innerHTML = health;

	// Bonus: make the background red when health below 25
	document.querySelector("#health_container").style.backgroundColor = health <= 25 ? "#ff05053d" : "#0000003d";
});

Events.Subscribe("ToggleScoreboard", function(enable) {
	const scoreboard = document.querySelector("#scoreboard");

	if (enable)
		scoreboard.style.display = "block";
	else
		scoreboard.style.display = "none";
});

Events.Subscribe("UpdatePlayer", function(id, active, name, ping) {
	const existing_scoreboard_entry = document.querySelector(`#scoreboard_entry_id${id}`);

	if (active) {
		if (existing_scoreboard_entry) {
			const scoreboard_ping = existing_scoreboard_entry.querySelector("td.scoreboard_ping");
			scoreboard_ping.innerHTML = ping;
			return;
		}

		const scoreboard_entry_tr = document.createElement("tr");
		scoreboard_entry_tr.id = `scoreboard_entry_id${id}`;

		const scoreboard_entry_td_id = document.createElement("td");
		scoreboard_entry_td_id.className = "scoreboard_id";
		scoreboard_entry_td_id.innerHTML = id;
		scoreboard_entry_tr.appendChild(scoreboard_entry_td_id);
		
		const scoreboard_entry_td_name = document.createElement("td");
		scoreboard_entry_td_name.className = "scoreboard_name";
		scoreboard_entry_td_name.innerHTML = name;
		scoreboard_entry_tr.appendChild(scoreboard_entry_td_name);
		
		const scoreboard_entry_td_ping = document.createElement("td");
		scoreboard_entry_td_ping.className = "scoreboard_ping";
		scoreboard_entry_td_ping.innerHTML = ping;
		scoreboard_entry_tr.appendChild(scoreboard_entry_td_ping);

		document.querySelector("#scoreboard_tbody").prepend(scoreboard_entry_tr);
	} else {
		existing_scoreboard_entry.remove();
	}
});