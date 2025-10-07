// Aux for debouncing
let DebounceTimeout = null;


document.addEventListener("DOMContentLoaded", function(event) {
	// Inserts the scoreboard
	const body = document.querySelector(`body`);

	body.insertAdjacentHTML("afterbegin", `
		<div id="context_menu">
			<div id="context_menu_header">context menu <span id="context_menu_close">X</span></div>
				<div id="context_menu_items">
				</div>
			</div>
		</div>
		<div id="context_menu_selector">
			<div id="context_menu_selector_background"></div>
			<div id="context_menu_selector_list"></div>
		</div>
	`);

	// Context Menu close button
	document.getElementById("context_menu_close").addEventListener("click", function(e) {
		ToggleContextMenuVisibility(false);
		Events.Call("CloseContextMenu");
	});

	// Context Menu Selector Background
	document.getElementById("context_menu_selector_background").addEventListener("click", function(e) {
		ToggleContextMenuSelectorVisibility(false);
	});

	// AddContextMenuItems("cu", "lambe", [
	// 	{ id: "ae1", type: "checkbox", label: "my label", callback_event: "MyEvent" },
	// 	{ id: "ae2", type: "button", label: "press me" },
	// 	{ id: "ae3", type: "range", label: "slide me", min: 0, max: 1440, value: 720, auto_update_label: true },
	// 	{ id: "ae4", type: "select_image", label: "Balloon", callback_event: "MyEvent", selected: "opt1", options: [
	// 		{ id: "opt1", name: "option 1", image: "./images/nanosworld_empty.webp" },
	// 		{ id: "opt2", name: "option 2", image: "./images/nanosworld_empty.webp" },
	// 		{ id: "opt3", name: "option 3", image: "./images/nanosworld_empty.webp" },
	// 	]},
	// ]);
});

function RemoveContextMenuItems(id) {
	document.getElementById(`category_${id}`).remove();
}

function AddContextMenuItems(id, title, items) {
	const context_menu_items = document.getElementById("context_menu_items");

	const context_menu_category = document.createElement("div");
	context_menu_category.classList.add("context_menu_category");
	context_menu_category.id = `category_${id}`;

	const divider = document.createElement("span");
	divider.classList.add("divider");
	divider.innerText = title;
	context_menu_category.append(divider);

	items.forEach(item => {
		const context_menu_item = document.createElement("div");
		context_menu_item.classList.add("context_menu_item");
		context_menu_item.id = `item_${item.id}`;

		switch (item.type) {
			case "button":
			{
				const button = document.createElement("button");
				button.innerText = item.label;
				button.addEventListener("click", function() {
					Events.Call("ClickSound");
					Events.Call(item.callback_event);
				});

				context_menu_item.classList.add("context_menu_item_button");
				context_menu_item.append(button);
				break;
			}
			case "checkbox":
			{
				const input = document.createElement("input");
				input.type = "checkbox";
				input.addEventListener("change", function(e) {
					Events.Call("ClickSound");
					Events.Call(item.callback_event, e.target.checked);
				});

				const label = document.createElement("label");
				label.innerText = item.label;

				context_menu_item.classList.add("context_menu_item_checkbox");
				context_menu_item.append(input);
				context_menu_item.append(label);
				break;
			}
			case "range":
			{
				const label = document.createElement("label");
				label.innerText = `${item.label}\n(${item.value})`;

				const input = document.createElement("input");
				input.type = "range";
				input.min = item.min;
				input.max = item.max;
				input.value = item.value;
				input.addEventListener("input", function(e) {
					// Debounce
					clearTimeout(DebounceTimeout);

					// After some time, apply the setting
					DebounceTimeout = setTimeout(function() {
						if (item.auto_update_label) {
							label.innerText = `${item.label}\n(${e.target.value})`;
						}

						Events.Call(item.callback_event, parseInt(e.target.value));
					}, 100);
				});

				context_menu_item.classList.add("context_menu_item_range");
				context_menu_item.append(input);
				context_menu_item.append(label);
				break;
			}
			case "select_image":
			{
				const selected = item.options.find(element => element.id == item.selected);

				const img = document.createElement("img");
				img.src = selected.image;
				img.addEventListener("click", function(e) {
					Events.Call("ClickSound");
					ToggleContextMenuSelectorVisibility(true, item);
				});

				const label = document.createElement("label");
				label.innerText = `${item.label}\n(${selected.name})`;

				context_menu_item.classList.add("context_menu_item_select_image");
				context_menu_item.append(img);
				context_menu_item.append(label);
				break;
			}
			case "color":
			{
				const input = document.createElement("input");
				input.type = "color";
				input.value = item.value;
				input.addEventListener("change", function(e) {
					Events.Call("ClickSound");
					Events.Call(item.callback_event, e.target.value);
				});

				const label = document.createElement("label");
				label.innerText = item.label;

				context_menu_item.classList.add("context_menu_item_color");
				context_menu_item.append(input);
				context_menu_item.append(label);
				break;
			}
			case "select":
			{
				const select = document.createElement("select");
				select.addEventListener("change", function(e) {
					Events.Call("ClickSound");
					Events.Call(item.callback_event, e.target.value);
				});

				item.options.forEach(option => {
					const option_element = document.createElement("option");
					option_element.value = option.id;
					option_element.text = option.name;

					if (item.selected == option.id)
						option_element.selected = true;

					select.append(option_element);
				});

				const label = document.createElement("label");
				label.innerText = item.label;

				context_menu_item.classList.add("context_menu_item_select");
				context_menu_item.append(select);
				context_menu_item.append(label);
				break;
			}
		}

		context_menu_category.append(context_menu_item);
	});

	context_menu_items.append(context_menu_category);
}

// Sets a Context Menu Item Label
function SetContextMenuLabel(id, text) {
	const context_menu_item = document.getElementById(`item_${id}`);
	const label = context_menu_item.getElementsByTagName("label")[0];
	label.innerText = text;
}

// Sets a Context Menu Item Value into an input
function SetContextMenuValue(id, value) {
	const context_menu_item = document.getElementById(`item_${id}`);

	const input = context_menu_item.getElementsByTagName("input")[0];
	if (input) {
		input.value = value;
		return;
	}

	const select = context_menu_item.getElementsByTagName("select")[0];
	if (select) {
		select.value = value;
		return;
	}

	// TODO add other types
}

// Toggles Context Menu Visibility
function ToggleContextMenuVisibility(is_visible) {
	const context_menu = document.getElementById("context_menu");
	context_menu.style.display = is_visible ? "block" : "none";

	if (!is_visible) {
		ToggleContextMenuSelectorVisibility(false);
	}
}

// Handles Context Menu Selector Item click
function ContextMenuSelectorItemClick(e) {
	const option_data = JSON.parse(e.target.dataset.option_data);

	const context_menu_selector = document.getElementById("context_menu_selector");

	const context_menu_item = document.getElementById(`item_${context_menu_selector.dataset.id}`);
	const img = context_menu_item.getElementsByTagName("img")[0];
	const label = context_menu_item.getElementsByTagName("label")[0];

	img.src = option_data.image;
	label.innerText = `${context_menu_selector.dataset.label}\n(${option_data.name})`;

	Events.Call("ClickSound");
	ToggleContextMenuSelectorVisibility(false);
	Events.Call(context_menu_selector.dataset.callback_event, option_data.id);
}

// Toggles Context Menu Selector Visibility
function ToggleContextMenuSelectorVisibility(is_visible, item) {
	const context_menu_selector = document.getElementById("context_menu_selector");
	context_menu_selector.style.display = is_visible ? "block" : "none";

	if (is_visible) {
		context_menu_selector.dataset.callback_event = item.callback_event;
		context_menu_selector.dataset.id = item.id;
		context_menu_selector.dataset.label = item.label;

		const context_menu_selector_list = document.getElementById("context_menu_selector_list");
		context_menu_selector_list.innerHTML = "";

		item.options.forEach(option => {
			const context_menu_selector_item = document.createElement("span");
			context_menu_selector_item.classList.add("context_menu_selector_item");
			context_menu_selector_item.dataset.option_data = JSON.stringify(option);
			context_menu_selector_item.addEventListener("click", ContextMenuSelectorItemClick);
			context_menu_selector_item.addEventListener("mouseenter", e => Events.Call("HoverSound", 1));

			const context_menu_selector_item_image = document.createElement("span");
			context_menu_selector_item_image.classList.add("context_menu_selector_item_image");
			context_menu_selector_item_image.style["background-image"] = `url('${option.image}'), url('./modules/context-menu/images/nanosworld_empty.webp')`;

			const context_menu_selector_item_name = document.createElement("span");
			context_menu_selector_item_name.classList.add("context_menu_selector_item_name");
			context_menu_selector_item_name.innerText = option.name;

			context_menu_selector_item.append(context_menu_selector_item_image);
			context_menu_selector_item.append(context_menu_selector_item_name);
			context_menu_selector_list.append(context_menu_selector_item);
		});
	}
}

Events.Subscribe("ToggleContextMenuVisibility", ToggleContextMenuVisibility);
Events.Subscribe("AddContextMenuItems", AddContextMenuItems);
Events.Subscribe("RemoveContextMenuItems", RemoveContextMenuItems);
Events.Subscribe("SetContextMenuLabel", SetContextMenuLabel);
Events.Subscribe("SetContextMenuValue", SetContextMenuValue);



{/* <div id="context_menu">
	<div id="context_menu_header">context menu <span id="context_menu_close">X</span></div>
	<div id="context_menu_items">
		<div class="context_menu_category">
			<span class="divider">Time</span>
			<div class="context_menu_item" id="context_menu_time_of_day">
				<span class="context_menu_label">Time of Day (<span id="context_menu_time_of_day_value">9:45</span>)</span>
				<input type="range" min="0" max="1440" value="720" id="time_of_day_slide">
			</div>

			<div class="context_menu_item">
				<input type="checkbox" id="context_menu_lock_time_of_day">
				<label for="context_menu_lock_time_of_day" id="context_menu_lock_time_of_day_label">Lock Time of the Day</label>
			</div>
		</div>

		<div class="context_menu_category">
			<span class="divider">Respawn</span>

			<!-- Button -->
			<div class="context_menu_item context_menu_item_button">
				<button id="context_menu_respawn_button">Respawn</button>
			</div>
		</div>

		<div class="context_menu_category">
			<span class="divider">Input Range</span>

			<!-- Input Range -->
			<div class="context_menu_item context_menu_item_range">
				<input type="range" min="0" max="1440" value="720">
				<label>Time of Day big text really big</label>
			</div>
		</div>

		<div class="context_menu_category">
			<span class="divider">Input Checkbox</span>

			<!-- Input Checkbox -->
			<div class="context_menu_item context_menu_item_checkbox">
				<input type="checkbox" >
				<label>Lock Time of the Day</label>
			</div>
		</div>

		<div class="context_menu_category">
			<span class="divider">Select Image</span>

			<div class="context_menu_item context_menu_item_select_image">
				<img src="" id="balloon_asset_selected" />
				<label>Balloon Asset</label>
			</div>
		</div>
	</div>
</div> */}