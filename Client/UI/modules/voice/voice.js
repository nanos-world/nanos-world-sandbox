document.addEventListener("DOMContentLoaded", function(event) {
	// Inserts the voice
	const body = document.querySelector("body");

	body.insertAdjacentHTML("afterbegin", `
		<div id="voice_chats">
			<!-- <span id="player-1234-5678" class="voice_chat"> -->
				<!-- <span class="voice_chat_player">Player</span> -->
			<!-- </span> -->
		</div>
	`);
});

// Registers for ToggleVoice from Scripting
function ToggleVoice(id, enable, name, image_url) {
	const existing_span = document.querySelector(`.voice_chat#player-${id}`);

	if (enable) {
		if (existing_span)
			return;

		const span = document.createElement("span");
		span.classList.add("voice_chat");
		span.id = `player-${id}`;

		const span_name = document.createElement("span");
		span_name.classList.add("voice_chat_name");
		span_name.innerHTML = name;

		const img = document.createElement("img");
		img.classList.add("voice_chat_image");
		img.src = image_url;

		span.appendChild(img);
		span.appendChild(span_name);
		document.getElementById("voice_chats").prepend(span);
	} else {
		if (!existing_span)
			return;

		existing_span.remove();
	}
}

Events.Subscribe("ToggleVoice", ToggleVoice);