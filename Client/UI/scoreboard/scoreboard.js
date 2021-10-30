document.addEventListener("DOMContentLoaded", function(event) {
	// Inserts the scoreboard
	const body = document.querySelector(`body`);

	body.insertAdjacentHTML("afterbegin", `
		<div id="scoreboard">
			<table>
				<thead>
					<tr id="scoreboard_header">
						<th>ID</th>
						<th>player</th>
						<th>ping</th>
					</tr>
				</thead>
				<tbody id="scoreboard_tbody">
					<!-- <tr id="scoreboard_entry_id1"><td class="scoreboard_id">1</td><td class="scoreboard_name">SyedMuhammad</td><td class="scoreboard_ping">100</td></tr> -->
				</tbody>
			</table>
		</div>
	`);
});

function ToggleScoreboard(enable) {
	const scoreboard = document.querySelector("#scoreboard");

	if (enable)
		scoreboard.style.display = "block";
	else
		scoreboard.style.display = "none";
}

function UpdatePlayer(id, active, name, ping) {
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
		if (!existing_scoreboard_entry)
			return;

		existing_scoreboard_entry.remove();
	}
}

Events.Subscribe("UpdatePlayer", UpdatePlayer);
Events.Subscribe("ToggleScoreboard", ToggleScoreboard);