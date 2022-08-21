document.addEventListener("DOMContentLoaded", function(event) {
	// Inserts the popup
	const body = document.querySelector(`body`);

	body.insertAdjacentHTML("afterbegin", `
        <div id="popup_prompt">
            <div id="popup_text">Hello please type</div>
            <!-- <a id="popup_close">X</a> -->
            <form id ="popup_form">
                <input id="popup_input" />
            </form>
        </div>
	`);

	const popup_input = document.getElementById("popup_input");
	popup_input.addEventListener("blur", (e) => {
		if (!popup_callback_event)
			return;

		const _popup_callback_event = popup_callback_event;
		ClosePopUpPrompt();
		Events.Call(_popup_callback_event, false);
	});

	const popup_form = document.getElementById("popup_form");
	popup_form.addEventListener("submit", function(e) {
		e.preventDefault();

		const _popup_input_value = document.getElementById("popup_input").value;
		const _popup_callback_event = popup_callback_event;

		ClosePopUpPrompt();

		Events.Call(_popup_callback_event, true, _popup_input_value);
	});
});

let popup_callback_event = null;

function ClosePopUpPrompt() {
	const popup_prompt = document.getElementById("popup_prompt");
	popup_prompt.style.display = "none";

	popup_callback_event = null;
}

function ShowPopUpPrompt(text, callback_event) {
	const popup_text = document.getElementById("popup_text");
	popup_text.innerHTML = text;

	const popup_prompt = document.getElementById("popup_prompt");
	popup_prompt.style.display = "block";

	const popup_input = document.getElementById("popup_input");
	popup_input.value = "";
	popup_input.focus();

	popup_callback_event = callback_event;
}

Events.Subscribe("ShowPopUpPrompt", ShowPopUpPrompt);
Events.Subscribe("ClosePopUpPrompt", ClosePopUpPrompt);