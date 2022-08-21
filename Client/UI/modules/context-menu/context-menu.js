document.addEventListener("DOMContentLoaded", function(event) {
	// Inserts the scoreboard
	const body = document.querySelector(`body`);

	body.insertAdjacentHTML("afterbegin", `
		<div id="context_menu">
			<div id="context_menu_header">context menu <span id="context_menu_close">X</span></div>
			<div class="context_menu_item" id="context_menu_time_of_day">
				<span class="context_menu_label">Time of Day (<span id="context_menu_time_of_day_value">9:45</span>)</span>
				<input type="range" min="0" max="1440" value="720" id="time_of_day_slide">
			</div>

			<input type="checkbox" id="context_menu_lock_time_of_day">
			<label for="context_menu_lock_time_of_day" id="context_menu_lock_time_of_day_label">Lock Time of the Day</label>

			<button id="context_menu_respawn_button">Respawn</button>
		</div>
	`);

	// Context Menu Time of Day Slide
	document.getElementById("time_of_day_slide").addEventListener("input", function(e) {
		// Debounce
		if (!EnabledChangeTimeOfDay)
			return;

		EnabledChangeTimeOfDay = false;

		// After some time, apply the setting
		setTimeout(function() {
			const value = e.target.value;
			const hours = Math.trunc(value / 60);
			const minutes = value % 60;

			SetTimeOfDayLabel(hours, minutes);
			Events.Call("ChangeTimeOfDay", hours, minutes);
			
			// Enables it again
			EnabledChangeTimeOfDay = true;
		}, 33);
	});

	// Context Menu Lock time of Day
	document.getElementById("context_menu_lock_time_of_day").addEventListener("change", function(e) {
		Events.Call("LockTimeOfDay", e.target.checked);
	});

	// Context Menu close button
	document.getElementById("context_menu_close").addEventListener("click", function(e) {
		ToggleContextMenuVisibility(false);
		Events.Call("CloseContextMenu");
	});

	// Context Menu Keybinding input, on click select all text
	document.querySelectorAll("#context_menu_keybindings input").forEach(input => input.addEventListener("click", function(e) {
		this.select();
	}));

	// Context Menu Respawn Button
	document.getElementById("context_menu_respawn_button").addEventListener("click", function() {
		Events.Call("RespawnButton");
	});
});

// Aux for debouncing
let EnabledChangeTimeOfDay = true;

function ToggleContextMenuVisibility(is_visible, hours, minutes) {
	const context_menu = document.getElementById("context_menu");

	if (is_visible)
	{
		// Sets current time
		document.getElementById("time_of_day_slide").value = hours * 60 + minutes;
		SetTimeOfDayLabel(hours, minutes);

		context_menu.style.display = "block";
	}
	else
	{
		context_menu.style.display = "none";
	}
}

function SetTimeOfDayLabel(hours, minutes) {
	document.getElementById("context_menu_time_of_day_value").innerHTML = `${('0' + hours).slice(-2)}:${('0' + minutes).slice(-2)}`;
}

Events.Subscribe("ToggleContextMenuVisibility", ToggleContextMenuVisibility);

Events.Subscribe("ToggleSpawnMenuVisibility", function(is_visible) {
	const spawn_menu = document.getElementById("spawn_menu");

	if (is_visible)
		spawn_menu.style.display = "block";
	else
		spawn_menu.style.display = "none";
});
