document.addEventListener("DOMContentLoaded", function(event) {
	// Inserts the scoreboard
	const body = document.querySelector(`body`);

	body.insertAdjacentHTML("afterbegin", `
		<div id="tutorials">
			<div id="tutorial_header">
				<div id="tutorial_header_content">
					<div id="tutorial_title">
						Tool
					</div>
					<div id="tutorial_description">
						Description
					</div>
				</div>
			</div>
			<div id="tutorial_body">
				<!-- <span class="tutorial"><img src="..." class="tutorial_key"> Attach Something</span> -->
				<!-- <span class="tutorial"><img src="..." class="tutorial_key"> Do Another Thing</span> -->
			</div>
		</div>
	`);
});

const Tutorials = {
	has_tutorial: false
}

Tutorials.ToggleTutorial = function(has_tutorial, title, description, tutorial_list) {
	Tutorials.has_tutorial = has_tutorial;

	if (has_tutorial) {
		const tutorial_body = document.getElementById("tutorial_body");
		tutorial_body.innerHTML = "";

		const tutorial_title = document.getElementById("tutorial_title");
		tutorial_title.textContent = title;

		const tutorial_description = document.getElementById("tutorial_description");
		tutorial_description.textContent = description;

		for (let tutorial in tutorial_list) {
			let image = tutorial_list[tutorial].image;
			let text = tutorial_list[tutorial].text;

			const tutorial_item_image = document.createElement("img");
			tutorial_item_image.classList.add("tutorial_key");
			tutorial_item_image.src = image;

			const tutorial_item_text = document.createElement("span");
			tutorial_item_text.textContent = text;

			const tutorial_item = document.createElement("span");
			tutorial_item.classList.add("tutorial");
			tutorial_item.appendChild(tutorial_item_image);
			tutorial_item.appendChild(tutorial_item_text);

			tutorial_body.appendChild(tutorial_item);
		}
	}

	Tutorials.SetVisibility(has_tutorial);
}

Tutorials.SetVisibility = function(is_visible) {
	const tutorials = document.getElementById("tutorials");

	if (is_visible && !ContextMenu.is_visible && !SpawnMenu.is_visible)
		tutorials.style.display = "block";
	else
		tutorials.style.display = "none";
}

Events.Subscribe("ToggleTutorial", Tutorials.ToggleTutorial);