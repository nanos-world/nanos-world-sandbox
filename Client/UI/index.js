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

// Register for UpdateWeaponAmmo custom event (from Lua)
function UpdateWeaponAmmo(enable, clip, bag) {
	if (enable)
		document.getElementById("weapon_ammo_container").style.display = "block";
	else
		document.getElementById("weapon_ammo_container").style.display = "none";

	// Using JQuery, overrides the HTML content of these SPANs with the new Ammo values
	document.getElementById("weapon_ammo_clip").innerHTML = clip;
	document.getElementById("weapon_ammo_bag").innerHTML = bag;
}

// Register for UpdateHealth custom event (from Lua)
function UpdateHealth(health) {
	// Overrides the HTML content of the SPAN with the new health value
	document.getElementById("health_current").innerHTML = health;

	// Bonus: make the background red when health below 25
	document.getElementById("health_container").style.backgroundColor = health <= 25 ? "#ff05053d" : "#0000003d";
}


let current_category = "";
let current_tab = "";

let spawn_menu_data = {};
let tabs = {};


function SpawnItemClick(e) {
	const item_id = e.target.dataset.item_id;
	const group = e.target.dataset.group;
	Events.Call("SpawnItem", group, current_tab, item_id);
}

function ItemHover(label, enter, is_spawn_item) {
	const label_element = document.getElementById("label");

	if (enter) {
		label_element.style.opacity = 1; 
		label_element.innerHTML = label;
		Events.Call("HoverSound", is_spawn_item ? 1 : 0.9);
	} else {
		label_element.style.opacity = 0; 
	}
}

function TabClick(tab_element) {
	const new_tab = tab_element.dataset.tab_id;

	// TODO fix workaround for patterns
	if (current_tab == "weapons")
		ToggleOptions(false);
	else if (new_tab == "weapons")
		ToggleOptions(true);

	current_tab = new_tab;

	// Clears Categories List
	document.getElementById("spawn_categories").innerHTML = "";

	if (tabs[current_tab]) {
		for (let category in tabs[current_tab].categories) {
			const category_data = tabs[current_tab].categories[category];
			DisplayCategory(category_data.id, category_data.label, category_data.image_active, category_data.image_inactive);
		}
	}

	// Adds "all" category
	DisplayCategory("all", "All", "images/categories/infinity.png", "images/categories/infinity-disabled.png");

	// Forces click on first category
	CategoryClick(document.querySelectorAll(".spawn_category")[0]);

	const old_tab_active = document.querySelector(".tab.active");
	if (old_tab_active) {
		old_tab_active.classList.remove("active");
		const old_tab_image = old_tab_active.querySelector("img");
		old_tab_image.src = old_tab_active.dataset.image_inactive;
	}

	tab_element.classList.add("active");

	const tab_image = tab_element.querySelector("img");
	tab_image.src = tab_element.dataset.image_active;
}

function CategoryClick(category_item) {
	const new_category = category_item.dataset.category_id;

	current_category = new_category;

	RefreshSpawnMenu();

	const old_category_active = document.querySelector(".spawn_category.active");
	if (old_category_active) {
		old_category_active.classList.remove("active");
		old_category_active.style["background-image"] = `url('${old_category_active.dataset.image_inactive}')`;
	}

	category_item.classList.add("active");
	category_item.style["background-image"] = `url('${category_item.dataset.image_active}')`;

	Events.Call("ClickSound");
}

function AddCategory(tab_id, id, label, image_active, image_inactive) {
	if (!tabs[tab_id])
		tabs[tab_id] = { categories: [] };

	tabs[tab_id].categories.push({
		id: id,
		label: label,
		image_active: image_active,
		image_inactive: image_inactive,
	});
}

function DisplayCategory(id, name, image_active, image_inactive) {
	const category = document.createElement("span");
	category.classList.add("spawn_category");
	category.addEventListener("click", e => CategoryClick(e.target));
	category.addEventListener("mouseenter", e => ItemHover("Category: " + e.target.dataset.category_name, true));
	category.addEventListener("mouseleave", e => ItemHover(false, false));

	category.dataset.category_id = id;
	category.dataset.category_name = name;
	category.dataset.image_active = image_active;
	category.dataset.image_inactive = image_inactive;

	category.style["background-image"] = `url('${image_inactive}')`;

	document.getElementById("spawn_categories").appendChild(category);
}

function AddTab(id, name, image_active, image_inactive) {
	const tab = document.createElement("span");
	tab.classList.add("tab");
	tab.addEventListener("click", e => TabClick(e.target));
	tab.addEventListener("mouseenter", e => ItemHover("Tab: " + e.target.dataset.tab_name, true));
	tab.addEventListener("mouseleave", e => ItemHover(false, false));

	const tab_image = document.createElement("img");
	tab_image.src = image_inactive;

	const tab_name = document.createElement("span");
	tab_name.classList.add("tab_name");
	tab_name.innerHTML = name;

	tab.appendChild(tab_image);
	tab.appendChild(tab_name);

	tab.dataset.tab_id = id;
	tab.dataset.tab_name = name;
	tab.dataset.image_active = image_active;
	tab.dataset.image_inactive = image_inactive;

	document.getElementById("tabs").appendChild(tab);
}

function RefreshSpawnMenu() {
	// Clears Spawn List
	document.getElementById("spawn_list").innerHTML = "";

	// Loads all items
	for (let group in spawn_menu_data) {
		for (let group_item in spawn_menu_data[group][current_tab]) {
			const item = spawn_menu_data[group][current_tab][group_item];

			// Filter category
			if (current_category != "all" && item.sub_category != current_category)
				continue;

			AddItem(group, item.id, item.name, item.image);
		}
	}
}

function ToggleOptions(enable) {
	const spawn_list = document.getElementById("spawn_list");
	const spawn_options = document.getElementById("spawn_options");

	if (enable) {
		spawn_options.style.display = "block";
		spawn_list.style.right = "200px";
	} else {
		spawn_options.style.display = "none";
		spawn_list.style.right = "0";
	}
}

function SelectOption(element, force_no_event) {
	const texture_path = element.dataset.texture;

	const old_option_selected = document.querySelector(".spawn_option_checkbox_item.selected");
	if (old_option_selected)
		old_option_selected.classList.remove("selected");

	element.classList.add("selected");

	if (!force_no_event)
		Events.Call("SelectOption", texture_path);
}

function AddOption(name, texture, texture_thumbnail) {
	// Todo this is completely bad, it's just an workaround for now, we must make it generic
	
	const option_checkbox_item = document.createElement("span");
	option_checkbox_item.classList.add("spawn_option_checkbox_item");
	option_checkbox_item.style.backgroundImage = `url('${texture_thumbnail || texture}'), url("./images/empty-set.png")`;

	option_checkbox_item.dataset.name = name;
	option_checkbox_item.dataset.texture = texture;

	option_checkbox_item.addEventListener("click", e => SelectOption(e.target));
	option_checkbox_item.addEventListener("mouseenter", e => ItemHover("Pattern: " + e.target.dataset.name, true, true));
	option_checkbox_item.addEventListener("mouseleave", e => ItemHover(false, false, true));

	document.querySelector(".spawn_option_checkbox").appendChild(option_checkbox_item);
}

function ToggleTutorial(is_visible, title, tutorial_list) {
	const tutorials = document.getElementById("tutorials");
	
	if (is_visible) {
		const tutorial_body = document.getElementById("tutorial_body");
		tutorial_body.innerHTML = "";

		const tutorial_title = document.getElementById("tutorial_title");
		tutorial_title.innerHTML = title;

		const tutorial_list_json = JSON.parse(tutorial_list);

		for (let tutorial in tutorial_list_json) {
			let image = tutorial_list_json[tutorial].image;
			let text = tutorial_list_json[tutorial].text;

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

document.addEventListener("DOMContentLoaded", function(event) {
	setTimeout(function() {
		// Selects the first tab
		TabClick(document.querySelectorAll(".tab")[0]);
	}, 1000);

	// Configure options - WORKAROUND FOR NOW
	AddOption("None", "");

	for (let i = 0; i < PatternList.length; i++) {
		AddOption(`Pattern #${i}`, `assets://nanos-world/Textures/Pattern/${PatternList[i]}`, `assets://nanos-world/Textures/Pattern/Thumbnails/${PatternList[i]}`);
	}

	SelectOption(document.querySelectorAll(".spawn_option_checkbox_item")[0], true);

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

function AddItem(group, item_id, item_name, image) {
	if (!image) image = "images/nanosworld_empty.png";

	const spawn_item = document.createElement("span");
	spawn_item.classList.add("spawn_item");
	spawn_item.addEventListener("click", SpawnItemClick);
	spawn_item.addEventListener("mouseenter", e => ItemHover(e.target.dataset.item_id, true, true));
	spawn_item.addEventListener("mouseleave", e => ItemHover(false, false, true));

	const spawn_item_image = document.createElement("span");
	spawn_item_image.classList.add("spawn_item_image");

	const spawn_item_name = document.createElement("span");
	spawn_item_name.classList.add("spawn_item_name");

	spawn_item.dataset.group = group;
	spawn_item.dataset.item_id = item_id;
	
	spawn_item_image.style["background-image"] = `url('${image}'), url('images/nanosworld_empty.png')`;
	spawn_item_name.innerHTML = item_name;

	spawn_item.appendChild(spawn_item_image);
	spawn_item.appendChild(spawn_item_name);

	document.getElementById("spawn_list").appendChild(spawn_item);
}

function AddSpawnMenuGroup(group, group_data) {
	spawn_menu_data[group] = JSON.parse(group_data);

	RefreshSpawnMenu();
}

function SetTimeOfDayLabel(hours, minutes) {
	document.getElementById("context_menu_time_of_day_value").innerHTML = `${('0' + hours).slice(-2)}:${('0' + minutes).slice(-2)}`;
}

// Aux for debouncing
let EnabledChangeTimeOfDay = true;

document.addEventListener("DOMContentLoaded", function() {
	// Context Menu Time of Day Slide
	document.getElementById("time_of_day_slide").addEventListener("input", function(e) {
		// Debounce
		if (!EnabledChangeTimeOfDay)
			return;

		EnabledChangeTimeOfDay = false;

		// After some time, apply the setting
		setTimeout(function() {
			const value = e.target.value;
			const hours = Math.trunc(value / 60);
			const minutes = value % 60;

			SetTimeOfDayLabel(hours, minutes);
			Events.Call("ChangeTimeOfDay", hours, minutes);
			
			// Enables it again
			EnabledChangeTimeOfDay = true;
		}, 33);
	});

	// Context Menu Lock time of Day
	document.getElementById("context_menu_lock_time_of_day").addEventListener("change", function(e) {
		Events.Call("LockTimeOfDay", e.target.checked);
	});

	// Context Menu close button
	document.getElementById("context_menu_close").addEventListener("click", function(e) {
		ToggleContextMenuVisibility(false);
		Events.Call("CloseContextMenu");
	});

	// Context Menu Keybinding input, on click select all text
	document.querySelectorAll("#context_menu_keybindings input").forEach(input => input.addEventListener("click", function(e) {
		this.select();
	}));

	// Context Menu Respawn Button
	document.getElementById("context_menu_respawn_button").addEventListener("click", function() {
		Events.Call("RespawnButton");
	});
});

function ToggleContextMenuVisibility(is_visible, hours, minutes) {
	const context_menu = document.getElementById("context_menu");

	if (is_visible)
	{
		// Sets current time
		document.getElementById("time_of_day_slide").value = hours * 60 + minutes;
		SetTimeOfDayLabel(hours, minutes);

		context_menu.style.display = "block";
	}
	else
	{
		context_menu.style.display = "none";
	}
}

Events.Subscribe("ToggleContextMenuVisibility", ToggleContextMenuVisibility);

Events.Subscribe("ToggleSpawnMenuVisibility", function(is_visible) {
	const spawn_menu = document.getElementById("spawn_menu");

	if (is_visible)
		spawn_menu.style.display = "block";
	else
		spawn_menu.style.display = "none";
});

Events.Subscribe("AddSpawnMenuGroup", AddSpawnMenuGroup);
Events.Subscribe("AddTab", AddTab);
Events.Subscribe("AddCategory", AddCategory);
Events.Subscribe("ToggleVoice", ToggleVoice);
Events.Subscribe("AddNotification", AddNotification);
Events.Subscribe("UpdateWeaponAmmo", UpdateWeaponAmmo);
Events.Subscribe("UpdateHealth", UpdateHealth);
Events.Subscribe("ShowPopUpPrompt", ShowPopUpPrompt);
Events.Subscribe("ClosePopUpPrompt", ClosePopUpPrompt);
Events.Subscribe("ToggleTutorial", ToggleTutorial);


// TODO fix pattern workaround, move to Lua?
const PatternList = [
	"T_80s_Pattern.jpg",
	"T_Chochip_Pattern.jpg",
	"T_Cracks_Pattern.jpg",
	"T_Desert_Marpat_Pattern.jpg",
	"T_Hexagon_Glow_Pattern.jpg",
	"T_Hexagon_Pattern.jpg",
	"T_Ink_Pattern.jpg",
	"T_LeafSpray_Pattern.jpg",
	"T_Net01_Pattern.jpg",
	"T_Stripes_Pattern.jpg",
	"T_Urban_Marpat_Pattern.jpg",
	"T_W90_Pattern.jpg",
	"T_W90K_Pattern.jpg",
	"T_Wood_Marpat_Pattern.jpg",
	"T_Murica_Pattern.jpg",
	"T_Watermelon_Pattern.jpg",
	"T_Infernoo.jpg",
	"T_Pattern_001.jpg",
	"T_Pattern_002.jpg",
	"T_Pattern_003.jpg",
	"T_Pattern_004.jpg",
	"T_Pattern_005.jpg",
	"T_Pattern_006.jpg",
	"T_Pattern_007.jpg",
	"T_Pattern_008.jpg",
	"T_Pattern_009.jpg",
	"T_Pattern_010.jpg",
	"T_Pattern_011.jpg",
	"T_Pattern_012.jpg",
	"T_Pattern_013.jpg",
	"T_Pattern_014.jpg",
	"T_Pattern_015.jpg",
	"T_Pattern_016.jpg",
	"T_Pattern_017.jpg",
	"T_Pattern_018.jpg",
	"T_Pattern_019.jpg",
	"T_Pattern_020.jpg",
	"T_Pattern_021.jpg",
	"T_Pattern_022.jpg",
	"T_Pattern_023.jpg",
	"T_Pattern_024.jpg",
	"T_Pattern_025.jpg",
	"T_Pattern_026.jpg",
	"T_Pattern_027.jpg",
	"T_Pattern_028.jpg",
	"T_Pattern_029.jpg",
	"T_Pattern_030.jpg",
	"T_Pattern_031.jpg",
	"T_Pattern_032.jpg",
	"T_Pattern_033.jpg",
	"T_Pattern_034.jpg",
	"T_Pattern_035.jpg",
	"T_Pattern_036.jpg",
	"T_Pattern_037.jpg",
	"T_Pattern_038.jpg",
	"T_Pattern_039.jpg",
	"T_Pattern_040.jpg",
	"T_Pattern_041.jpg",
	"T_Pattern_042.jpg",
	"T_Pattern_043.jpg",
	"T_Pattern_044.jpg",
	"T_Pattern_045.jpg",
	"T_Pattern_046.jpg",
	"T_Pattern_047.jpg",
	"T_Pattern_048.jpg",
	"T_Pattern_049.jpg",
	"T_Pattern_050.jpg",
	"T_Pattern_051.jpg",
	"T_Pattern_052.jpg",
	"T_Pattern_053.jpg",
	"T_Pattern_054.jpg",
	"T_Pattern_055.jpg",
	"T_Pattern_056.jpg",
	"T_Pattern_057.jpg",
	"T_Pattern_058.jpg",
	"T_Pattern_059.jpg",
	"T_Pattern_060.jpg",
	"T_Pattern_061.jpg",
	"T_Pattern_062.jpg",
	"T_Pattern_063.jpg",
	"T_Pattern_064.jpg",
	"T_Pattern_065.jpg",
	"T_Pattern_066.jpg",
	"T_Pattern_067.jpg",
	"T_Pattern_068.jpg",
	"T_Pattern_069.jpg",
	"T_Pattern_070.jpg",
	"T_Pattern_071.jpg",
	"T_Pattern_072.jpg",
	"T_Pattern_073.jpg",
	"T_Pattern_074.jpg",
	"T_Pattern_075.jpg",
	"T_Pattern_076.jpg",
	"T_Pattern_077.jpg",
	"T_Pattern_078.jpg",
	"T_Pattern_079.jpg",
	"T_Pattern_080.jpg",
	"T_Pattern_081.jpg",
	"T_Pattern_082.jpg",
	"T_Pattern_083.jpg",
	"T_Pattern_084.jpg",
	"T_Pattern_085.jpg",
	"T_Pattern_086.jpg",
	"T_Pattern_087.jpg",
	"T_Pattern_088.jpg",
	"T_Pattern_089.jpg",
	"T_Pattern_090.jpg",
	"T_Pattern_091.jpg",
	"T_Pattern_092.jpg",
	"T_Pattern_093.jpg",
	"T_Pattern_094.jpg",
	"T_Pattern_095.jpg",
	"T_Pattern_096.jpg",
	"T_Pattern_097.jpg",
	"T_Pattern_098.jpg",
	"T_Pattern_099.jpg",
	"T_Pattern_100.jpg",
	"T_Pattern_101.jpg",
	"T_Pattern_102.jpg",
	"T_Pattern_103.jpg",
	"T_Pattern_104.jpg",
	"T_Pattern_105.jpg",
	"T_Pattern_106.jpg",
	"T_Pattern_107.jpg",
	"T_Pattern_108.jpg",
	"T_Pattern_109.jpg",
	"T_Pattern_110.jpg",
	"T_Pattern_111.jpg",
	"T_Pattern_112.jpg",
	"T_Pattern_113.jpg",
	"T_Pattern_114.jpg",
	"T_Pattern_115.jpg",
	"T_Pattern_116.jpg",
	"T_Pattern_117.jpg"
]