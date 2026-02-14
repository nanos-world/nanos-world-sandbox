// Aux for debouncing
const DebounceHandler = {
	Timeout: null,
	Run: function(callback, delay) {
		clearTimeout(this.Timeout);
		this.Timeout = setTimeout(callback, delay);
	}
};

const ContextMenu = {
	is_visible: false,

	// Helper to prevent input events when hovering the context menu elements
	is_hovering_context_menu: false,
	is_hovering_selector: false,
	UpdateHovering: function() {
		Events.Call("ContextMenu_SetHovering", this.is_hovering_context_menu || this.is_hovering_selector);
	}
}

document.addEventListener("DOMContentLoaded", function(event) {
	// Inserts the context menu
	const body = document.querySelector(`body`);

	body.insertAdjacentHTML("afterbegin", `
		<div id="context_menu">
			<div id="context_menu_inner">
				<div id="context_menu_header">context menu <span id="context_menu_close">X</span></div>
				<div id="context_menu_items">
				</div>
			</div>
		</div>
		<div id="context_menu_selector">
			<div id="context_menu_selector_background"></div>
			<div id="context_menu_selector_list"></div>
		</div>
		<div id="context_menu_hovering_entity">
			<span id="context_menu_hovering_entity_label"></span>
			<span id="context_menu_hovering_entity_info"></span>
		</div>
	`);

	// Context Menu close button
	document.getElementById("context_menu_close").addEventListener("click", function(e) {
		ContextMenu.ToggleContextMenuVisibility(false);
		Events.Call("CloseContextMenu");
	});

	// Context Menu Selector Background
	document.getElementById("context_menu_selector_background").addEventListener("click", function(e) {
		ContextMenu.ToggleContextMenuSelectorVisibility(false);
	});

	// Context Menu Hovering events
	document.getElementById("context_menu_inner").addEventListener("mouseenter", function(e) {
		ContextMenu.is_hovering_context_menu = true;
		ContextMenu.UpdateHovering();
	});

	document.getElementById("context_menu_inner").addEventListener("mouseleave", function(e) {
		ContextMenu.is_hovering_context_menu = false;
		ContextMenu.UpdateHovering();
	});

	document.getElementById("context_menu_selector").addEventListener("mouseenter", function(e) {
		ContextMenu.is_hovering_selector = true;
		ContextMenu.UpdateHovering();
	});

	document.getElementById("context_menu_selector").addEventListener("mouseleave", function(e) {
		ContextMenu.is_hovering_selector = false;
		ContextMenu.UpdateHovering();
	});

	// ContextMenu.AddContextMenuItems("id", "title", [
	// 	{ id: "ae1", type: "checkbox", label: "my label" },
	// 	{ id: "ae2", type: "button", label: "press me" },
	// 	{ id: "ae3", type: "range", label: "slide me", min: 0, max: 1440, value: 720, step: 1 },
	// 	{ id: "ae4", type: "select_image", label: "Balloon", value: "opt1", options: [
	// 		{ id: "opt1", name: "option 1", image: "./images/nanosworld_empty.webp" },
	// 		{ id: "opt2", name: "option 2", image: "./images/nanosworld_empty.webp" },
	// 		{ id: "opt3", name: "option 3", image: "./images/nanosworld_empty.webp" },
	// 	]},
	// ]);
});

ContextMenu.RemoveContextMenuItems = function(id) {
	const element = document.getElementById(`category_${id}`);
	if (element)
		element.remove();
}

ContextMenu.AddContextMenuItems = function(id, title, items, color) {
	const context_menu_items = document.getElementById("context_menu_items");

	// Tries getting existing
	let context_menu_category = context_menu_items.querySelector(`#category_${id}`);

	if (!context_menu_category)
	{
		context_menu_category = document.createElement("div");
		context_menu_category.classList.add("context_menu_category");
		context_menu_category.id = `category_${id}`;

		const divider = document.createElement("span");
		divider.classList.add("divider");
		divider.innerText = title;
		context_menu_category.append(divider);

		context_menu_items.prepend(context_menu_category);
	}

	if (color) {
		context_menu_category.style.border = `2px solid ${color}`;
	}

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
					Events.Call("ContextMenu_Callback", item.id);
				});

				context_menu_item.classList.add("context_menu_item_button");
				context_menu_item.append(button);
				break;
			}
			case "checkbox":
			{
				const switch_input = document.createElement("label");
				switch_input.classList.add("switch");

				const switch_slider = document.createElement("span");
				switch_slider.classList.add("slider");

				const input = document.createElement("input");
				input.type = "checkbox";
				input.checked = item.value;
				input.addEventListener("change", function(e) {
					Events.Call("ClickSound");
					Events.Call("ContextMenu_Callback", item.id, e.target.checked);
				});

				switch_input.append(input);
				switch_input.append(switch_slider);

				const label = document.createElement("label");
				label.innerText = item.label;

				context_menu_item.classList.add("context_menu_item_checkbox");
				context_menu_item.append(label);
				context_menu_item.append(switch_input);
				break;
			}
			case "range":
			{
				let min = item.min || 0;
				let max = item.max || 1;
				let step = item.step || 1;
				let value = item.value || 0;

				const label = document.createElement("label");
				label.innerText = item.label;

				const input_container = document.createElement("div");
				input_container.classList.add("context_menu_item_container");

				const range_input = document.createElement("input");
				range_input.type = "range";
				range_input.min = min;
				range_input.max = max;
				range_input.step = step;
				range_input.value = value;

				const text_input = document.createElement("input");
				text_input.type = "number";
				text_input.value = value;
				text_input.min = min;
				text_input.max = max;
				text_input.step = step;
				text_input.onwheel = function(e) {}; // So Mouse Wheel can be detected by the input

				range_input.addEventListener("input", function(e) {
					DebounceHandler.Run(function() {
						// Updates text
						text_input.value = e.target.value;

						// Calls callback
						Events.Call("ContextMenu_Callback", item.id, parseFloat(e.target.value));
					}, 100);
				});

				text_input.addEventListener("change", function(e) {
					if (e.target.value < min) e.target.value = min;
					if (e.target.value > max) e.target.value = max;

					// Updates range
					range_input.value = e.target.value;

					// Calls callback
					Events.Call("ContextMenu_Callback", item.id, parseFloat(e.target.value));
				});

				input_container.append(text_input);
				input_container.append(range_input);

				context_menu_item.classList.add("context_menu_item_range");
				context_menu_item.append(label);
				context_menu_item.append(input_container);
				break;
			}
			case "select_image":
			{
				const selected = item.options.find(element => element.id == item.value) || { id: "", name: "None", image: "modules/spawn-menu/images/nanosworld_empty.webp" };

				const input_container = document.createElement("div");
				input_container.classList.add("context_menu_item_select_image_container");

				input_container.addEventListener("click", function(e) {
					Events.Call("ClickSound");
					ContextMenu.ToggleContextMenuSelectorVisibility(true, item);
				});

				const img = document.createElement("img");
				img.src = selected.image;

				const img_label = document.createElement("span");
				img_label.innerText = selected.name;

				const label = document.createElement("label");
				label.innerText = item.label;

				input_container.append(img);
				input_container.append(img_label);

				context_menu_item.classList.add("context_menu_item_select_image");
				context_menu_item.append(label);
				context_menu_item.append(input_container);
				break;
			}
			case "color":
			{
				const input_container = document.createElement("div");
				input_container.classList.add("context_menu_item_select_image_container");

				const color_input = document.createElement("input");
				color_input.type = "color";
				color_input.value = item.value;

				const color_label = document.createElement("span");
				color_label.innerText = item.value.toUpperCase();

				color_input.addEventListener("input", function(e) {
					DebounceHandler.Run(function() {
						Events.Call("ClickSound");
						Events.Call("ContextMenu_Callback", item.id, e.target.value);
						color_label.innerText = e.target.value.toUpperCase();
					}, 100);
				});

				input_container.addEventListener("click", function(e) {
					color_input.click();
				});

				const label = document.createElement("label");
				label.innerText = item.label;

				input_container.append(color_input);
				input_container.append(color_label);

				context_menu_item.classList.add("context_menu_item_color");
				context_menu_item.append(label);
				context_menu_item.append(input_container);
				break;
			}
			case "select":
			{
				const select = document.createElement("select");
				select.addEventListener("change", function(e) {
					Events.Call("ClickSound");
					Events.Call("ContextMenu_Callback", item.id, e.target.value);
				});

				item.options.forEach(option => {
					const option_element = document.createElement("option");
					option_element.value = option.id;
					option_element.text = option.name;

					if (item.value == option.id)
						option_element.selected = true;

					select.append(option_element);
				});

				const label = document.createElement("label");
				label.innerText = item.label;

				context_menu_item.classList.add("context_menu_item_select");
				context_menu_item.append(label);
				context_menu_item.append(select);
				break;
			}
			case "text":
			{
				let input = null;
				if (item.multiline) {
					input = document.createElement("textarea");
				} else {
					input = document.createElement("input");
					input.type = "text";
				}

				input.value = item.value;
				input.placeholder = item.placeholder || "enter text...";
				input.addEventListener("change", function(e) {
					Events.Call("ClickSound");
					Events.Call("ContextMenu_Callback", item.id, e.target.value);
				});

				const label = document.createElement("label");
				label.innerText = item.label;

				context_menu_item.classList.add("context_menu_item_text");
				context_menu_item.append(label);
				context_menu_item.append(input);
				break;
			}
			default:
				console.error(`Unknown Context Menu Item Type: ${item.type}`);
		}

		context_menu_category.append(context_menu_item);
	});
}

// Sets the Hovering Entity info
ContextMenu.SetHoverEntity = function(has_entity, label, spawned_by, spawned_by_time) {
	const context_menu_hovering_entity = document.getElementById("context_menu_hovering_entity");
	context_menu_hovering_entity.style.display = has_entity ? "block" : "none";

	if (has_entity) {
		const context_menu_hovering_entity_label = document.getElementById("context_menu_hovering_entity_label");
		context_menu_hovering_entity_label.innerText = label;

		const context_menu_hovering_entity_info = document.getElementById("context_menu_hovering_entity_info");
		if (spawned_by && spawned_by_time) {
			context_menu_hovering_entity_info.innerText = `${spawned_by}\n${new Date(spawned_by_time).toLocaleString("en-GB")}`;
		} else {
			context_menu_hovering_entity_info.innerText = "";
		}
	}
}

// Sets a Context Menu Item Label
ContextMenu.SetContextMenuLabel = function(id, text) {
	const context_menu_item = document.getElementById(`item_${id}`);
	const label = context_menu_item.getElementsByTagName("label")[0];
	label.innerText = text;
}

// Sets a Context Menu Item Value into an input
ContextMenu.SetContextMenuValue = function(id, value) {
	const context_menu_item = document.getElementById(`item_${id}`);

	context_menu_item.querySelectorAll("input").forEach(input => {
		input.value = value;
	});

	const select = context_menu_item.getElementsByTagName("select")[0];
	if (select) {
		select.value = value;
		return;
	}

	// TODO add other types
}

// Toggles Context Menu Visibility
ContextMenu.ToggleContextMenuVisibility = function(is_visible) {
	const context_menu = document.getElementById("context_menu");
	context_menu.style.display = is_visible ? "flex" : "none";

	ContextMenu.is_visible = is_visible;

	if (!is_visible) {
		ContextMenu.ToggleContextMenuSelectorVisibility(false);
	}

	// Show/Hide the Tutorials
	if (Tutorials.has_tutorial)
		Tutorials.SetVisibility(!is_visible);
}

// TODO: move context_menu_selector to inside the selector, so it handles it's lifespan
// Handles Context Menu Selector Item click
ContextMenu.ContextMenuSelectorItemClick = function(e) {
	const option_data = JSON.parse(e.target.dataset.option_data);

	const context_menu_selector = document.getElementById("context_menu_selector");

	const context_menu_item = document.getElementById(`item_${context_menu_selector.dataset.id}`);

	if (!context_menu_item) {
		// Note: this error will not show up if notifications/debug mode are disabled
		console.error("No element found! Was it removed from context menu?");
		ContextMenu.ToggleContextMenuSelectorVisibility(false);
		return;
	}

	const img = context_menu_item.getElementsByTagName("img")[0];
	const label = context_menu_item.getElementsByTagName("label")[0];
	const span_label = context_menu_item.getElementsByTagName("span")[0];

	img.src = option_data.image;
	label.innerText = context_menu_selector.dataset.label;
	span_label.innerText = option_data.name;

	Events.Call("ClickSound");
	ContextMenu.ToggleContextMenuSelectorVisibility(false);
	Events.Call("ContextMenu_Callback", context_menu_selector.dataset.id, option_data.id);
}

// Toggles Context Menu Selector Visibility
ContextMenu.ToggleContextMenuSelectorVisibility = function(is_visible, item) {
	const context_menu_selector = document.getElementById("context_menu_selector");
	context_menu_selector.style.display = is_visible ? "block" : "none";

	if (is_visible) {
		context_menu_selector.dataset.id = item.id;
		context_menu_selector.dataset.label = item.label;

		const context_menu_selector_list = document.getElementById("context_menu_selector_list");
		context_menu_selector_list.innerHTML = "";

		item.options.forEach(option => {
			const context_menu_selector_item = document.createElement("span");
			context_menu_selector_item.classList.add("context_menu_selector_item");
			context_menu_selector_item.dataset.option_data = JSON.stringify(option);
			context_menu_selector_item.addEventListener("click", ContextMenu.ContextMenuSelectorItemClick);
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

Events.Subscribe("ToggleContextMenuVisibility", ContextMenu.ToggleContextMenuVisibility);
Events.Subscribe("AddContextMenuItems", ContextMenu.AddContextMenuItems);
Events.Subscribe("RemoveContextMenuItems", ContextMenu.RemoveContextMenuItems);
Events.Subscribe("SetContextMenuLabel", ContextMenu.SetContextMenuLabel);
Events.Subscribe("SetContextMenuValue", ContextMenu.SetContextMenuValue);
Events.Subscribe("SetHoverEntity", ContextMenu.SetHoverEntity);



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