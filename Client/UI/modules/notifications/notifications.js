document.addEventListener("DOMContentLoaded", function(event) {
	// Inserts the scoreboard
	const body = document.querySelector(`body`);

	body.insertAdjacentHTML("afterbegin", `
		<div id="notifications">
			<!-- <span class="notification">My Awesome Notification!</span>	 -->
		</div>
	`);
});

// Registers for Notifications from Scripting
function AddNotification(message, time) {
	const span = document.createElement("span");
	span.classList.add("notification");
	span.innerHTML = message;

	document.getElementById("notifications").prepend(span);

	setTimeout(function(span) {
		span.remove()
	}, time, span);
}

Events.Subscribe("AddNotification", AddNotification);