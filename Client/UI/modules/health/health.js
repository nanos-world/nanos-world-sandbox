document.addEventListener("DOMContentLoaded", function(event) {
	// Inserts the scoreboard
	const body = document.querySelector(`body`);

	body.insertAdjacentHTML("afterbegin", `
		<!-- Health container (black background) -->
		<div id="health_container">
			<img src="modules/health/health.png">
			<!-- Health value -->
			<span id="health_current">100</span>
		</div>
	`);
});

// Register for UpdateHealth custom event (from Lua)
function UpdateHealth(health) {
	// Overrides the HTML content of the SPAN with the new health value
	document.getElementById("health_current").innerHTML = health;

	// Bonus: make the background red when health below 25
	document.getElementById("health_container").style.backgroundColor = health <= 25 ? "#ff05053d" : "#0000003d";
}

Events.Subscribe("UpdateHealth", UpdateHealth);