document.addEventListener("DOMContentLoaded", function(event) {
	// Inserts the voice
	const body = document.querySelector("body");

	body.insertAdjacentHTML("afterbegin", `
        <div id="voice_chats">
            <!-- <span class="voice_chat SyedMuhammad">Player</span> -->
        </div>
	`);
});

// Registers for ToggleVoice from Scripting
function ToggleVoice(name, enable) {
	const existing_span = document.querySelector(`.voice_chat#${name}`);

	if (enable) {
		if (existing_span)
			return;

		const span = document.createElement("span");
		span.classList.add("voice_chat");
		span.id = name;
		span.innerHTML = name;

		document.getElementById("voice_chats").prepend(span);
	} else {
		if (!existing_span)
			return;

		existing_span.remove();
	}
}

Events.Subscribe("ToggleVoice", ToggleVoice);