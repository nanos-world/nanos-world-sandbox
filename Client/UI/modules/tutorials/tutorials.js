document.addEventListener("DOMContentLoaded", function(event) {
	// Inserts the scoreboard
	const body = document.querySelector(`body`);

	body.insertAdjacentHTML("afterbegin", `
		<div id="tutorials">
			<div id="tutorial_title">
				Tool
			</div>
			<div id="tutorial_body">
				<!-- <span class="tutorial"><img src="..." class="tutorial-key"> Attach Something</span> -->
				<!-- <span class="tutorial"><img src="..." class="tutorial-key"> Do Another Thing</span> -->
			</div>
		</div>
	`);
});

function ToggleTutorial(is_visible, title, tutorial_list) {
	const tutorials = document.getElementById("tutorials");
	
	if (is_visible) {
		const tutorial_body = document.getElementById("tutorial_body");
		tutorial_body.innerHTML = "";

		const tutorial_title = document.getElementById("tutorial_title");
		tutorial_title.innerHTML = title;

		for (let tutorial in tutorial_list) {
			let image = tutorial_list[tutorial].image;
			let text = tutorial_list[tutorial].text;

			const tutorial_item_image = document.createElement("img");
			tutorial_item_image.classList.add("tutorial_key");
			tutorial_item_image.src = image;

			const tutorial_item = document.createElement("span");
			tutorial_item.classList.add("tutorial");
			tutorial_item.appendChild(tutorial_item_image);
			tutorial_item.innerHTML += text;

			tutorial_body.appendChild(tutorial_item);
		}

		tutorials.style.display = "block";
	} else {
		tutorials.style.display = "none";
	}
}

Events.Subscribe("ToggleTutorial", ToggleTutorial);