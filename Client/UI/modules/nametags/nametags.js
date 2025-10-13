document.addEventListener("DOMContentLoaded", function(event) {
	// Inserts the nametag
	const body = document.querySelector(`body`);

	body.insertAdjacentHTML("afterbegin", `
		<div id="name_tag">
			Player
		</div>
	`);
});

// Register for ShowNameTag custom event (from Lua)
function ShowNameTag(enable, player_name) {
	if (enable)
	{
		document.getElementById("name_tag").style.display = "block";
		document.getElementById("name_tag").innerHTML = player_name;
	}
	else
		document.getElementById("name_tag").style.display = "none";
}

Events.Subscribe("ShowNameTag", ShowNameTag);