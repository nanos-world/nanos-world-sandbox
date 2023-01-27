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
					<!-- <tr id="scoreboard_entry_id1">
						<td>1</td>
						<td>
							<span class="player_image"></span>
							<span class="player_name">SyedMuhammad</span>
						</td>
						<td class="scoreboard_ping">100</td>
					</tr> -->
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

// TODO one method to update, another to create/remove
function UpdatePlayer(id, active, image, name, ping) {
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
		scoreboard_entry_td_id.innerHTML = id;
		scoreboard_entry_tr.appendChild(scoreboard_entry_td_id);

		const scoreboard_image = document.createElement("span");
		scoreboard_image.className = "player_image";
		scoreboard_image.style["background-image"] = `url('${image}'), url('./modules/scoreboard/nanosworld_empty.webp')`;

		const scoreboard_name = document.createElement("span");
		scoreboard_name.className = "player_name";
		scoreboard_name.innerHTML = name;

		const scoreboard_entry_td_player = document.createElement("td");
		scoreboard_entry_td_player.appendChild(scoreboard_image);
		scoreboard_entry_td_player.appendChild(scoreboard_name);

		scoreboard_entry_tr.appendChild(scoreboard_entry_td_player);

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