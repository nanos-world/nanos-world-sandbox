document.addEventListener("DOMContentLoaded", function(event) {
	// Inserts the speedometer
	const body = document.querySelector(`body`);

	body.insertAdjacentHTML("afterbegin", `
		<!-- Speedometer container (black background) -->
		<div id="speedometer_container">
			<!-- Speed Icon -->
			<img src="modules/speedometer/speedometer.png">
			<!-- Speed value -->
			<span id="speedometer_speed">30</span>
			<span class="speedometer_label">km/h</span>
			<!-- Gear value -->
			<!-- <span id="speedometer_gear">1</span> -->
			<!-- RPM value -->
			<!-- <span id="speedometer_rpm">1</span> -->
		</div>
	`);
});

const Speedometer = {
	timer: null,
	target_speed: 0,
	current_speed: 0,
}

// Register for UpdateSpeedometer custom event (from Lua)
function UpdateSpeedometer(enable, speed, gear, rpm) {
	if (enable)
	{
		document.getElementById("speedometer_container").style.display = "flex";

		Speedometer.target_speed = speed;

		// // 0 means switching
		// if (gear != 0)
		// {
		// 	// negative means reverse
		// 	if (gear < 0)
		// 		gear = "R";

		// 	document.getElementById("speedometer_gear").textContent = gear;
		// }

		// document.getElementById("speedometer_rpm").textContent = rpm;

		if (Speedometer.timer == null)
		{
			// Smoothly updates the speedometer towards the target
			Speedometer.timer = setInterval(function() {
				Speedometer.current_speed = Speedometer.current_speed * 0.7 + Speedometer.target_speed * 0.3;
				document.getElementById("speedometer_speed").textContent = Math.round(Speedometer.current_speed);
			}, 33)
		}

	}
	else
	{
		document.getElementById("speedometer_container").style.display = "none";

		if (Speedometer.timer)
		{
			clearInterval(Speedometer.timer);
			Speedometer.timer = null;
		}
	}
}

Events.Subscribe("UpdateSpeedometer", UpdateSpeedometer);